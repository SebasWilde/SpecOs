#!/usr/bin/env bash
# SpecOS v3 — release verification
#
# SpecOS is a framework, not a product project. It has no runtime and no
# test cases — but install.sh and update.sh are real code, and the contracts
# between them and skills/ are real. This script checks those.
#
# Run before every release. Exits non-zero on the first hard failure.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

PASS=0; FAIL=0
ok()   { echo -e "  ${GREEN}pass${NC}  $1"; PASS=$((PASS+1)); }
bad()  { echo -e "  ${RED}FAIL${NC}  $1"; FAIL=$((FAIL+1)); }
head_() { echo -e "\n${BLUE}$1${NC}"; }

SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

# --- 1. Every skill is installable ------------------------------------------

head_ "Skills"

SKILLS=("$REPO_ROOT"/skills/*.md)
SKILL_COUNT=${#SKILLS[@]}

if [[ $SKILL_COUNT -gt 0 ]]; then
  ok "$SKILL_COUNT skills found in skills/"
else
  bad "no skills found in skills/"
fi

# Line 3 of each skill is extracted verbatim by install.sh as the Gemini
# command description. A blank line 3, or a Markdown separator, silently
# ships a broken command. This contract is invisible from the skill file.
for f in "${SKILLS[@]}"; do
  name=$(basename "$f" .md)
  line3=$(sed -n '3p' "$f")
  if [[ -z "${line3// }" ]]; then
    bad "$name: line 3 is blank — Gemini description would be empty"
  elif [[ "$line3" == "---"* || "$line3" == "#"* ]]; then
    bad "$name: line 3 is '$line3' — not a usable Gemini description"
  elif [[ "$line3" == *'"'* ]]; then
    bad "$name: line 3 contains a double quote — breaks the generated TOML"
  else
    ok "$name: line 3 is a valid description"
  fi
done

# --- 2. Installer paths all resolve -----------------------------------------

head_ "Installer source paths"

for script in install.sh update.sh; do
  refs=$(grep -ohE '\$REPO_ROOT/(skills|adapters|scripts)[^"]*' "$REPO_ROOT/$script" | sed 's|\$REPO_ROOT/||' | sort -u)
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    dir=$(dirname "$p")
    if [[ -e "$REPO_ROOT/$dir" ]]; then
      ok "$script → $p"
    else
      bad "$script → $p does not exist"
    fi
  done <<< "$refs"
done

# --- 3. No adapter duplicates a skill ---------------------------------------
# skills/ is the single source. An adapter may delegate, be generated, or be a
# shared section — it may never be a copy, because copies drift silently.

head_ "Single source rule"

DUPES=0
while IFS= read -r adapter; do
  base=$(basename "$adapter")
  skill="$REPO_ROOT/skills/$base"
  [[ -f "$skill" ]] || continue
  # A delegator is short and points at skills/. A copy is neither.
  if ! grep -q "skills/" "$adapter" && [[ $(wc -l < "$adapter") -gt 20 ]]; then
    bad "adapters/$(basename "$(dirname "$adapter")")/$base duplicates skills/$base"
    DUPES=$((DUPES+1))
  fi
done < <(find "$REPO_ROOT/adapters" -name '*.md' -not -name 'README.md' -not -name 'AGENTS-specos-section.md')

[[ $DUPES -eq 0 ]] && ok "no adapter duplicates a skill"

# Cursor delegates per skill — a missing .mdc means that skill is unreachable
# in Cursor, which nothing else would reveal.
for f in "${SKILLS[@]}"; do
  name=$(basename "$f" .md)
  if [[ -f "$REPO_ROOT/adapters/cursor/$name.mdc" ]]; then
    ok "cursor: $name.mdc present"
  else
    bad "cursor: $name.mdc missing — skill unreachable in Cursor"
  fi
done

# --- 4. Full install into a clean HOME --------------------------------------

head_ "Install into a clean HOME"

FAKE_HOME="$SANDBOX/home"
FAKE_REPO="$SANDBOX/repo"
mkdir -p "$FAKE_HOME/.claude" "$FAKE_HOME/.config/opencode" "$FAKE_HOME/.gemini" "$FAKE_HOME/.cursor"
cp -R "$REPO_ROOT" "$FAKE_REPO"
rm -rf "$FAKE_REPO/.git"
mkdir -p "$FAKE_REPO/.github" "$FAKE_REPO/.cursor/rules" "$FAKE_HOME/.claude/commands" "$FAKE_HOME/.gemini/commands"

# A machine that installed an older SpecOS still holds the retired skill. cp never
# deletes, so install.sh has to.
for stale in "$FAKE_HOME/.claude/commands/specos-lead-parallel.md" \
             "$FAKE_HOME/.gemini/commands/specos-lead-parallel.toml" \
             "$FAKE_REPO/.cursor/rules/specos-lead-parallel.mdc"; do
  echo "stale" > "$stale"
done

if (cd "$FAKE_REPO" && HOME="$FAKE_HOME" bash install.sh >"$SANDBOX/install.log" 2>&1); then
  ok "install.sh completed"
else
  bad "install.sh exited non-zero — see below"
  tail -20 "$SANDBOX/install.log"
fi

check_count() {
  local label="$1" dir="$2" pattern="$3"
  local n
  n=$(find "$dir" -name "$pattern" 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$n" -eq "$SKILL_COUNT" ]]; then
    ok "$label: $n/$SKILL_COUNT"
  else
    bad "$label: $n/$SKILL_COUNT"
  fi
}

STALE_LEFT=0
for stale in "$FAKE_HOME/.claude/commands/specos-lead-parallel.md" \
             "$FAKE_HOME/.gemini/commands/specos-lead-parallel.toml" \
             "$FAKE_REPO/.cursor/rules/specos-lead-parallel.mdc"; do
  [[ -e "$stale" ]] && { bad "install.sh left retired skill ${stale##*/}"; STALE_LEFT=$((STALE_LEFT+1)); }
done
[[ $STALE_LEFT -eq 0 ]] && ok "install.sh removes retired skills from agent directories"

check_count "claude code" "$FAKE_HOME/.claude/commands"          '*.md'
check_count "opencode"    "$FAKE_HOME/.config/opencode/commands" '*.md'
check_count "gemini cli"  "$FAKE_HOME/.gemini/commands"          '*.toml'
check_count "cursor"      "$FAKE_REPO/.cursor/rules"             '*.mdc'

if [[ -s "$FAKE_REPO/.github/copilot-instructions.md" ]]; then
  ok "codex/copilot: instructions written"
else
  bad "codex/copilot: instructions missing or empty"
fi

# The check script ships to ~/.specos/ so /specos-status --check can run it anywhere.
if [[ -x "$FAKE_HOME/.specos/specos-check.sh" ]] && cmp -s "$REPO_ROOT/scripts/specos-check.sh" "$FAKE_HOME/.specos/specos-check.sh"; then
  ok "install.sh deploys specos-check.sh to ~/.specos/ (executable, identical to source)"
else
  bad "install.sh did not deploy an executable, identical specos-check.sh to ~/.specos/"
fi

# Generated TOML must be well-formed, not merely present.
BAD_TOML=0
for t in "$FAKE_HOME"/.gemini/commands/*.toml; do
  [[ -e "$t" ]] || continue
  if ! head -1 "$t" | grep -q '^description = ".\+"$'; then
    bad "gemini: $(basename "$t") has a malformed description line"
    BAD_TOML=$((BAD_TOML+1))
  fi
done
[[ $BAD_TOML -eq 0 ]] && ok "gemini: all descriptions well-formed"

# --- 5. update.sh is idempotent ---------------------------------------------

head_ "Update"

if (cd "$FAKE_REPO" && HOME="$FAKE_HOME" bash update.sh >"$SANDBOX/update.log" 2>&1); then
  ok "update.sh completed"
else
  bad "update.sh exited non-zero — see below"
  tail -20 "$SANDBOX/update.log"
fi

check_count "claude code after update" "$FAKE_HOME/.claude/commands" '*.md'

echo "stale" > "$FAKE_HOME/.claude/commands/specos-lead-parallel.md"
echo "# broken" > "$FAKE_HOME/.specos/specos-check.sh"
(cd "$FAKE_REPO" && HOME="$FAKE_HOME" bash update.sh >"$SANDBOX/update2.log" 2>&1)
if [[ ! -e "$FAKE_HOME/.claude/commands/specos-lead-parallel.md" ]]; then
  ok "update.sh removes retired skills"
else
  bad "update.sh left specos-lead-parallel.md installed"
fi
if cmp -s "$REPO_ROOT/scripts/specos-check.sh" "$FAKE_HOME/.specos/specos-check.sh"; then
  ok "update.sh redeploys specos-check.sh"
else
  bad "update.sh did not redeploy specos-check.sh"
fi

# Every installed skill must match its source — a stale copy means update.sh
# is not actually updating.
DRIFT=0
for f in "${SKILLS[@]}"; do
  name=$(basename "$f")
  installed="$FAKE_HOME/.claude/commands/$name"
  [[ -f "$installed" ]] || continue
  cmp -s "$f" "$installed" || { bad "$name differs from source after update"; DRIFT=$((DRIFT+1)); }
done
[[ $DRIFT -eq 0 ]] && ok "installed skills match skills/ exactly"

head_ "Uninstall"

if (cd "$FAKE_REPO" && HOME="$FAKE_HOME" bash uninstall.sh >"$SANDBOX/uninstall.log" 2>&1); then
  ok "uninstall.sh completed"
else
  bad "uninstall.sh exited non-zero"
fi
LEFT=$(find "$FAKE_HOME/.claude/commands" -name 'specos-*' 2>/dev/null | wc -l | tr -d ' ')
[[ "$LEFT" -eq 0 ]] && ok "uninstall.sh removes every skill" || bad "uninstall.sh left $LEFT skill file(s)"
[[ ! -e "$FAKE_HOME/.specos/specos-check.sh" ]] && ok "uninstall.sh removes specos-check.sh" || bad "uninstall.sh left ~/.specos/specos-check.sh"

# --- 6. Local files stay local ----------------------------------------------

head_ "Local files are ignored"

for f in local-workspace.yml session.md .specos/memory.md; do
  if git -C "$REPO_ROOT" check-ignore -q "$f" 2>/dev/null; then
    ok "$f is gitignored"
  else
    bad "$f is NOT gitignored — it would be committed"
  fi
done

# --- 7. Config file contract ------------------------------------------------
#
# specos-project.yml replaced specos-outputs.yml and specos-standards.yml.
# Three ways this ships broken and nobody notices until a user hits it:
# a template that no longer exists, a skill still reading a deleted file, and
# a setting documented in the spec that no skill actually reads.

head_ "Config"

PROJECT_YML="$REPO_ROOT/specos-project.yml"

if [[ -f "$PROJECT_YML" ]]; then
  ok "specos-project.yml template exists"
else
  bad "specos-project.yml template is missing"
fi

for old in specos-outputs.yml specos-standards.yml; do
  if [[ -f "$REPO_ROOT/$old" ]]; then
    bad "$old still exists — it was merged into specos-project.yml"
  else
    ok "$old is gone"
  fi
done

# A skill may name an old file only when it is talking about the migration:
# specos-start performs it, specos-config redirects to it, specos-status
# reports that it has not happened yet. Any other skill naming one is reading
# a file that no longer exists.
STALE=0
for f in "$REPO_ROOT"/skills/*.md; do
  name=$(basename "$f" .md)
  case "$name" in specos-start|specos-config|specos-status) continue;; esac
  if grep -q "specos-outputs\.yml\|specos-standards\.yml" "$f"; then
    bad "$name still references a merged config file"
    STALE=$((STALE+1))
  fi
done
[[ $STALE -eq 0 ]] && ok "no skill reads a merged config file"

# specos-start must actually carry the migration, not just mention the files.
if grep -q "specos-project.yml" "$REPO_ROOT/skills/specos-start.md" \
   && grep -q "specos-outputs.yml" "$REPO_ROOT/skills/specos-start.md"; then
  ok "specos-start carries the migration"
else
  bad "specos-start does not carry the migration"
fi

# Every setting in the catalog must be read by the skill that owns it.
# A setting documented in the spec but absent from its skill is dead config:
# the user sets it, nothing happens, and nothing reports the problem.
SETTINGS_MISSING=0
check_setting() {
  local skill="$1" key="$2"
  local f="$REPO_ROOT/skills/specos-$skill.md"
  if [[ ! -f "$f" ]]; then
    bad "skills/specos-$skill.md missing (owns $key)"
    SETTINGS_MISSING=$((SETTINGS_MISSING+1)); return
  fi
  grep -q "$key" "$f" || { bad "$skill does not read $key"; SETTINGS_MISSING=$((SETTINGS_MISSING+1)); }
}

check_setting lead max_tasks
check_setting lead max_journeys
check_setting lead require_error_journey
check_setting lead review
check_setting lead suggest_scenarios
check_setting qa cases_per_ac
check_setting qa include_negative_cases
check_setting qa batch_by
check_setting distribute diagrams
check_setting distribute branch_info
check_setting distribute task_title_max_words
check_setting distribute task_detail
check_setting dev require_tests

[[ $SETTINGS_MISSING -eq 0 ]] && ok "all 13 settings are read by their owning skill"

# The template ships defaults commented out. An active settings: or rules: key
# would silently pin every new project instead of running on defaults.
if grep -qE '^settings:|^rules:' "$PROJECT_YML" 2>/dev/null; then
  bad "template has an active settings:/rules: key — defaults must stay commented"
else
  ok "template ships settings and rules commented out"
fi

# --- 8. Spec flow contracts (v2.7) --------------------------------------------
#
# The new flow is spread over many files: a skill pointing at a protocol that
# was renamed, a doc still describing the retired skill, a rule worded two ways.
# None of it fails at install time, so it is checked here.

head_ "Spec flow"

# The retired skill must leave no trace outside the spec's own history.
RETIRED_HITS=$(grep -rIl "lead-parallel" "$REPO_ROOT" --exclude-dir=.git --exclude=verify.sh --exclude-dir=specos-v3 --exclude=install.sh --exclude=update.sh 2>/dev/null | wc -l | tr -d ' ')
if [[ "$RETIRED_HITS" -eq 0 ]]; then ok "no file references specos-lead-parallel"; else bad "$RETIRED_HITS file(s) still reference specos-lead-parallel"; fi

# Every skill is listed wherever skills are listed. Counts and lists drift together.
LIST_MISSING=0
for f in "${SKILLS[@]}"; do
  name=$(basename "$f" .md)
  for doc in README.md CHEATSHEET.md AGENTS.md adapters/generic/AGENTS-specos-section.md skills/specos-help.md; do
    grep -q "/$name\b" "$REPO_ROOT/$doc" || { bad "$doc does not list /$name"; LIST_MISSING=$((LIST_MISSING+1)); }
  done
done
[[ $LIST_MISSING -eq 0 ]] && ok "all $SKILL_COUNT skills are listed in README, CHEATSHEET, AGENTS, generic adapter and help"

if grep -q "The $SKILL_COUNT skills" "$REPO_ROOT/README.md"; then ok "README states $SKILL_COUNT skills"; else bad "README does not say 'The $SKILL_COUNT skills'"; fi
STALE_COUNTS=$(grep -rIn -E "The 12 skills|12 skills|all 10 settings|10 settings across" "$REPO_ROOT/README.md" "$REPO_ROOT/CHEATSHEET.md" "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/skills" "$REPO_ROOT/docs" "$REPO_ROOT/adapters" 2>/dev/null | wc -l | tr -d ' ')
[[ "$STALE_COUNTS" -eq 0 ]] && ok "no stale skill or settings counts" || bad "$STALE_COUNTS stale skill/settings count(s) in docs or skills"

# Rule 4 is worded the same everywhere, and the old wording is gone.
RULE4_BAD=0
for f in constitution.md AGENTS.md skills/specos-init.md skills/specos-lead.md skills/specos-dev.md; do
  if ! tr -d '`*\n' < "$REPO_ROOT/$f" | grep -q "Changes to spec.md require Lead approval"; then
    bad "$f does not carry rule 4 (Changes to spec.md require Lead approval)"; RULE4_BAD=$((RULE4_BAD+1))
  fi
done
[[ $RULE4_BAD -eq 0 ]] && ok "rule 4 is worded identically in constitution, AGENTS, init, lead and dev"
OLD_RULE=$(grep -rIn -E "Only the Lead (role )?modifies|unless the user holds the Lead role|unless the active role is Lead" "$REPO_ROOT/constitution.md" "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/skills" "$REPO_ROOT/adapters" 2>/dev/null | wc -l | tr -d ' ')
[[ "$OLD_RULE" -eq 0 ]] && ok "the old 'only the Lead modifies spec.md' wording is gone" || bad "$OLD_RULE place(s) still use the old rule 4 wording"

# The status field: the contradiction this version removed.
NOSTATUS=$(grep -rIn -i -E "no status field in the spec|no status fields|status fields anywhere|repo presence = approved|presence in the repo means approved" "$REPO_ROOT/AGENTS.md" "$REPO_ROOT/README.md" "$REPO_ROOT/CHEATSHEET.md" "$REPO_ROOT/constitution.md" "$REPO_ROOT/skills" "$REPO_ROOT/docs" 2>/dev/null | wc -l | tr -d ' ')
[[ "$NOSTATUS" -eq 0 ]] && ok "no template says the spec has no status field or that presence alone is approval" || bad "$NOSTATUS place(s) still describe the old 'no status field' approval"
if grep -q "status: draft" "$REPO_ROOT/skills/specos-lead.md" || grep -q "draft" "$REPO_ROOT/skills/specos-lead.md"; then
  ok "specos-lead writes status: draft | approved"
else
  bad "specos-lead does not describe the status field"
fi
grep -q "status: draft | approved" "$REPO_ROOT/AGENTS.md" && ok "AGENTS template documents the status field" || bad "AGENTS template does not document the status field"

# Rule 2 vs specos-lead: lead writes sketches only, never steps.
if grep -q "Sketches suggested by Lead, not reviewed" "$REPO_ROOT/skills/specos-lead.md" \
   && grep -q "Sketches suggested by Lead, not reviewed" "$REPO_ROOT/skills/specos-split.md" \
   && ! grep -qi "without asking" "$REPO_ROOT/skills/specos-lead.md"; then
  ok "lead and split write sketches, not full test cases"
else
  bad "lead or split still writes full testcases (breaks constitution rule 2)"
fi
grep -q "spec-only context\|from the spec alone" "$REPO_ROOT/constitution.md" && ok "constitution rule 2 names the QA invocation as the independent perspective" || bad "constitution rule 2 was not updated"

# The change protocol is defined once, in lead; dev and qa point at it.
for name in dev qa; do
  if grep -q "spec change request" "$REPO_ROOT/skills/specos-$name.md" && grep -q "specos-lead" "$REPO_ROOT/skills/specos-$name.md"; then
    ok "$name points to the spec change request protocol in specos-lead"
  else
    bad "$name does not point to the protocol in specos-lead"
  fi
done
PROTO_COPIES=$(grep -l "Type: clarification" "$REPO_ROOT"/skills/*.md | wc -l | tr -d ' ')
[[ "$PROTO_COPIES" -eq 1 ]] && ok "the change request block is defined in exactly one skill" || bad "the change request block appears in $PROTO_COPIES skills (expected 1)"

# session.md: one schema, written by start, referenced by everyone else.
SCHEMA_BAD=0
for name in lead dev qa split group; do
  grep -q "specos-start" "$REPO_ROOT/skills/specos-$name.md" && grep -qi "whole" "$REPO_ROOT/skills/specos-$name.md" \
    || { bad "$name does not rewrite session.md whole by the specos-start schema"; SCHEMA_BAD=$((SCHEMA_BAD+1)); }
done
for key in "spec_version:" "next:" "open:" "parked:"; do
  grep -q "$key" "$REPO_ROOT/skills/specos-start.md" || { bad "specos-start schema lacks $key"; SCHEMA_BAD=$((SCHEMA_BAD+1)); }
done
OLD_FIELDS=$(grep -ln "task_description:\|spec_path:" "$REPO_ROOT"/skills/*.md | grep -v "specos-start.md\|specos-status.md" | wc -l | tr -d ' ')
[[ "$OLD_FIELDS" -eq 0 ]] || { bad "$OLD_FIELDS skill(s) still write the old session.md fields"; SCHEMA_BAD=$((SCHEMA_BAD+1)); }
[[ $SCHEMA_BAD -eq 0 ]] && ok "every skill rewrites session.md whole using the one schema"

# tasks.md: no SP-XX assignment left in any skill.
if grep -l "SP-XX" "$REPO_ROOT"/skills/*.md >/dev/null 2>&1; then bad "a skill still assigns SP-XX placeholders"; else ok "no skill assigns SP-XX placeholders"; fi
if grep -q "\[new\]" "$REPO_ROOT/skills/specos-lead.md" && grep -q "\[new\]" "$REPO_ROOT/skills/specos-distribute.md"; then
  ok "lead writes and distribute replaces [new]"
else
  bad "lead or distribute does not handle [new]"
fi

# SP- placeholders: distribute asks, it never converts them silently.
if grep -q "SP-" "$REPO_ROOT/skills/specos-distribute.md" && grep -qi "treat them as new" "$REPO_ROOT/skills/specos-distribute.md" \
   && ! grep -q "read as \`\[new\]\`" "$REPO_ROOT/skills/specos-lead.md" "$REPO_ROOT/README.md" "$REPO_ROOT/CHEATSHEET.md"; then
  ok "SP- placeholders are asked about, never silently treated as [new]"
else
  bad "SP- placeholder handling is inconsistent between distribute, lead and the docs"
fi

# v2.8: what the chat shows, how a session closes, and what dev prints.
V28_BAD=0
for name in lead dev qa distribute; do
  grep -q "Never commit or push on your own. When the Lead asks, list the files and the message first." "$REPO_ROOT/skills/specos-$name.md" \
    || { bad "$name does not carry the never-commit line"; V28_BAD=$((V28_BAD+1)); }
done
for k in "every assumption" "Session saved: active =" "Commit message:" "## Decisions" "Purpose:" "(inferred)"; do
  grep -qF "$k" "$REPO_ROOT/skills/specos-lead.md" || { bad "specos-lead lacks: $k"; V28_BAD=$((V28_BAD+1)); }
done
for k in "Commit message:" "type(KEY): Imperative description" "improvement" "Never park it in"; do
  grep -qF "$k" "$REPO_ROOT/skills/specos-dev.md" || { bad "specos-dev lacks: $k"; V28_BAD=$((V28_BAD+1)); }
done
for k in "standard" "link" "Test cases" "Acceptance criteria" "brief"; do
  grep -qF "$k" "$REPO_ROOT/skills/specos-distribute.md" || { bad "specos-distribute lacks: $k"; V28_BAD=$((V28_BAD+1)); }
done
grep -q "ACTIVE task" "$REPO_ROOT/skills/specos-start.md" || { bad "specos-start does not limit open to the active task"; V28_BAD=$((V28_BAD+1)); }
OLD_MODES=$(grep -rIn -E "brief \\?\| full|brief \| full" "$REPO_ROOT/README.md" "$REPO_ROOT/CHEATSHEET.md" "$REPO_ROOT/skills" "$REPO_ROOT/specos-project.yml" "$REPO_ROOT/docs" 2>/dev/null | wc -l | tr -d ' ')
[[ "$OLD_MODES" -eq 0 ]] || { bad "$OLD_MODES place(s) still list task_detail as brief | full"; V28_BAD=$((V28_BAD+1)); }
[[ $V28_BAD -eq 0 ]] && ok "v2.8 contracts: never-commit line, closing summary, commit message, ticket modes, open rule"

# Optional destination: jira-csv must be readable by distribute and settable through config.
JC_BAD=0
for f in skills/specos-distribute.md skills/specos-config.md specos-project.yml README.md; do
  grep -q "jira-csv" "$REPO_ROOT/$f" || { bad "$f does not mention the jira-csv destination"; JC_BAD=$((JC_BAD+1)); }
done
grep -q "Summary,Description,Issue Type,Parent" "$REPO_ROOT/skills/specos-distribute.md" || { bad "distribute does not define the jira-csv columns"; JC_BAD=$((JC_BAD+1)); }
[[ $JC_BAD -eq 0 ]] && ok "jira-csv destination is defined in distribute, config, template and README"

# Token weight: this version set out to make skills lighter, so a skill growing
# past its v2.6 size has to be a decision, not an accident.
# (sizes in bytes at v2.6; +15% tolerated for skills that gained a mode or a command)
check_size() {
  local name="$1" base="$2" f="$REPO_ROOT/skills/specos-$1.md" size limit
  size=$(wc -c < "$f" | tr -d ' '); limit=$(( base + base * 15 / 100 ))
  if [[ "$size" -le "$limit" ]]; then ok "specos-$name is $size bytes (v2.6: $base)"; else bad "specos-$name grew to $size bytes (v2.6: $base, limit $limit)"; fi
}
check_size lead 6482; check_size dev 6440; check_size qa 7223; check_size distribute 9579; check_size start 12180
check_size status 2882; check_size help 1932; check_size init 10675; check_size config 7993; check_size split 3805; check_size group 2347

# --- 9. The check script ----------------------------------------------------

head_ "Check script"

CHECK="$REPO_ROOT/scripts/specos-check.sh"
FIX="$REPO_ROOT/examples/check-fixture"

if bash -n "$CHECK" 2>/dev/null; then ok "specos-check.sh parses"; else bad "specos-check.sh has a syntax error"; fi

CHECK_OUT=$(bash "$CHECK" "$FIX" --session "$FIX/oversized-session.md" 2>&1); CHECK_RC=$?
[[ $CHECK_RC -eq 0 ]] && ok "warnings alone exit 0" || bad "check exited $CHECK_RC without --strict"
bash "$CHECK" "$FIX" --session "$FIX/oversized-session.md" --strict >/dev/null 2>&1; STRICT_RC=$?
[[ $STRICT_RC -eq 1 ]] && ok "--strict exits 1 when there are warnings" || bad "--strict exited $STRICT_RC (expected 1)"

expect() {
  if grep -qF -- "$1" <<< "$CHECK_OUT"; then ok "fixture: $1"; else bad "fixture is missing the warning: $1"; fi
}
expect "specs checked: 5 (groups skipped: 1)"
expect "2 AC(s) have no test case covering them: AC3, AC21b"
expect "task [FK-101] references AC7, which does not exist"
expect "task [FK-102] references AC4, which is retired"
expect "task [FK-103] references AC5, which is [pending]"
expect "TC-02 covers AC9, which does not exist"
expect "1 of 3 test case(s) are sketches (no steps:)"
expect "testcases.md is stamped spec: v1.0, behind the spec at v1.2"
expect "1 [new] task(s) still waiting for a ticket key"
expect "linked path does not exist: specs/missing-feature/spec.md"
expect "spec is v1.2 but CHANGELOG.md has no entry for it"
expect "linked path does not exist: specs/payments/refunds/spec.md"
expect "session.md is 40 lines"
expect "no AC ids found (legacy spec)"
expect "AC1×2, AC2×2 — ids repeated, legacy per-journey numbering?"
expect "info  testcases.md has expanded cases but no spec: stamp"
expect "info  1 legacy SP- placeholder(s)"
expect "info  2 legacy SP- placeholder(s)"
expect "13 warning(s) in 3 spec(s)"

# What must NOT be reported matters as much: the control spec, the legacy spec,
# the group and the old [SP-01] key all parse without a warning.
if grep -q "specs/clean-feature" <<< "$CHECK_OUT"; then bad "the control spec produced output (false positive)"; else ok "the control spec (all AC styles incl. the *(example)* annotation, ranges, AC21b) is silent"; fi
if [[ "$(grep -c 'defined twice' <<< "$CHECK_OUT")" -eq 0 ]]; then ok "repeated AC ids are grouped, not one warning per id"; else bad "repeated AC ids are reported one by one"; fi
if grep -q "warn.*no spec: stamp" <<< "$CHECK_OUT"; then bad "a missing testcases stamp is a warning (should be info)"; else ok "a missing testcases stamp is only info"; fi
if grep -A3 "specs/legacy-feature" <<< "$CHECK_OUT" | grep -q "warn"; then bad "the legacy spec produced a warning (false positive)"; else ok "the legacy spec (checkbox ACs, SP-XX tasks, full testcases) only gets an info line"; fi
if grep -q "specs/payments (" <<< "$CHECK_OUT"; then bad "the group spec was checked"; else ok "group specs are skipped"; fi
if grep -q "specs/payments/checkout" <<< "$CHECK_OUT"; then ok "specs nested two levels deep are checked"; else bad "the nested spec was not checked"; fi
if grep -q "FK-123\|FK-124" <<< "$CHECK_OUT"; then bad "valid [FK-123] tasks were reported"; else ok "[FK-123], [SP-01] and [new] keys parse; AC1–AC3 (en dash) ranges resolve"; fi
if grep -qi "crash\|awk:" <<< "$CHECK_OUT"; then bad "the check script crashed on the fixture"; else ok "no crashes on the fixture"; fi

# session.md `open` is for the active task: more than 3 entries is a warning, 3 or fewer is silent.
OPEN_OUT=$(bash "$CHECK" "$FIX" --session "$FIX/session-open-overflow.md" 2>&1)
if grep -qF "session.md open has 5 entries (max 3, active task only)" <<< "$OPEN_OUT" && grep -qF "13 warning(s) in 3 spec(s)" <<< "$OPEN_OUT"; then
  ok "a session.md with 5 open entries warns (and only that warning is added)"
else
  bad "the open-entries check did not fire as expected"
fi
OK_OUT=$(bash "$CHECK" "$FIX" --session "$FIX/session-ok.md" 2>&1)
if grep -qF "12 warning(s) in 3 spec(s)." <<< "$OK_OUT" && ! grep -q "^session.md" <<< "$OK_OUT"; then
  ok "a session.md with 3 open entries and 3 parked entries is silent"
else
  bad "a valid session.md produced a warning (false positive)"
fi

IMPACT_OUT=$(bash "$CHECK" "$FIX" --impacts payments/checkout 2>&1)
if grep -q "specs/clean-feature/spec.md" <<< "$IMPACT_OUT"; then ok "--impacts lists the specs that link to a feature"; else bad "--impacts did not list clean-feature"; fi

# The canonical example must stay healthy: its only findings are the ones it teaches —
# one sketch QA has not expanded, and one [new] task still waiting for a key.
EXROOT="$SANDBOX/example-root"
mkdir -p "$EXROOT/specs"
cp -R "$REPO_ROOT/examples/feature-tags" "$EXROOT/specs/feature-tags"
EX_OUT=$(bash "$CHECK" "$EXROOT" 2>&1)
EX_WARNS=$(grep -c '^  warn' <<< "$EX_OUT" || true)
if [[ "$EX_WARNS" -eq 2 ]] \
   && grep -qF "1 of 6 test case(s) are sketches (no steps:)" <<< "$EX_OUT" \
   && grep -qF "1 [new] task(s) still waiting for a ticket key" <<< "$EX_OUT"; then
  ok "examples/feature-tags: only the unexpanded sketch and the [new] task are reported"
else
  bad "examples/feature-tags is not as documented ($EX_WARNS warnings, expected 2) — see below"
  echo "$EX_OUT" | sed 's/^/        /'
fi

# --- Summary ----------------------------------------------------------------

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo -e "${GREEN}All $PASS checks passed.${NC}"
  exit 0
else
  echo -e "${RED}$FAIL failed${NC}, $PASS passed."
  exit 1
fi
