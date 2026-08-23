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

# --- Summary ----------------------------------------------------------------

echo ""
if [[ $FAIL -eq 0 ]]; then
  echo -e "${GREEN}All $PASS checks passed.${NC}"
  exit 0
else
  echo -e "${RED}$FAIL failed${NC}, $PASS passed."
  exit 1
fi
