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
  refs=$(grep -ohE '\$REPO_ROOT/(skills|adapters)[^"]*' "$REPO_ROOT/$script" | sed 's|\$REPO_ROOT/||' | sort -u)
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
mkdir -p "$FAKE_REPO/.github"

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

check_count "claude code" "$FAKE_HOME/.claude/commands"          '*.md'
check_count "opencode"    "$FAKE_HOME/.config/opencode/commands" '*.md'
check_count "gemini cli"  "$FAKE_HOME/.gemini/commands"          '*.toml'
check_count "cursor"      "$FAKE_REPO/.cursor/rules"             '*.mdc'

if [[ -s "$FAKE_REPO/.github/copilot-instructions.md" ]]; then
  ok "codex/copilot: instructions written"
else
  bad "codex/copilot: instructions missing or empty"
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
check_setting qa cases_per_ac
check_setting qa include_negative_cases
check_setting qa batch_by
check_setting distribute diagrams
check_setting distribute branch_info
check_setting distribute task_title_max_words
check_setting dev require_tests

[[ $SETTINGS_MISSING -eq 0 ]] && ok "all 10 settings are read by their owning skill"

# The template ships defaults commented out. An active settings: or rules: key
# would silently pin every new project instead of running on defaults.
if grep -qE '^settings:|^rules:' "$PROJECT_YML" 2>/dev/null; then
  bad "template has an active settings:/rules: key — defaults must stay commented"
else
  ok "template ships settings and rules commented out"
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
