#!/usr/bin/env bash
# SpecOS v3 — updater
# Copies the latest skills to all detected agent directories.
# Does NOT touch project files: AGENTS.md, constitution.md, specos-project.yml, specs/
# Works on macOS and Linux. Idempotent — safe to run multiple times.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECOS_VERSION="3.0"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[SpecOS]${NC} $1"; }
success() { echo -e "${GREEN}[SpecOS]${NC} $1"; }
warn()    { echo -e "${YELLOW}[SpecOS]${NC} $1"; }

# --- OS detection ---
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux" ;;
    *)      echo "unsupported" ;;
  esac
}

OS=$(detect_os)
if [[ "$OS" == "unsupported" ]]; then
  echo "SpecOS v3 supports macOS and Linux only."
  exit 1
fi

echo ""
info "Updating SpecOS v${SPECOS_VERSION} skills on ${OS}..."
echo ""

# --- Agent updaters ---

_write_gemini_toml() {
  local skill_file="$1"
  local output_file="$2"
  local description
  description=$(sed -n '3p' "$skill_file")
  printf 'description = "%s"\nprompt = '"'"''"'"''"'"'\n' "$description" > "$output_file"
  cat "$skill_file" >> "$output_file"
  printf "\n'''\n" >> "$output_file"
}

update_gemini() {
  local is_installed=false
  command -v gemini &>/dev/null && is_installed=true
  [[ -d "$HOME/.gemini" ]] && is_installed=true

  if [[ "$is_installed" == "true" ]]; then
    local commands_dir="$HOME/.gemini/commands"
    mkdir -p "$commands_dir"
    for skill_file in "$REPO_ROOT/skills/"*.md; do
      local name
      name=$(basename "$skill_file" .md)
      _write_gemini_toml "$skill_file" "$commands_dir/${name}.toml"
    done
    success "Gemini CLI → $commands_dir"
    return 0
  fi
  return 1
}

update_claude_code() {
  local commands_dir="$HOME/.claude/commands"
  if [[ -d "$HOME/.claude" ]]; then
    mkdir -p "$commands_dir"
    cp -f "$REPO_ROOT/skills/"*.md "$commands_dir/"
    success "Claude Code → $commands_dir"
    return 0
  fi
  return 1
}

update_opencode() {
  local is_installed=false
  [[ -d "$HOME/.opencode" ]] && is_installed=true
  [[ -d "$HOME/.config/opencode" ]] && is_installed=true
  command -v opencode &>/dev/null && is_installed=true

  if [[ "$is_installed" == "true" ]]; then
    local commands_dir="$HOME/.config/opencode/commands"
    mkdir -p "$commands_dir"
    cp -f "$REPO_ROOT/skills/"*.md "$commands_dir/"
    success "OpenCode → $commands_dir"
    return 0
  fi
  return 1
}

update_cursor() {
  local is_installed=false
  command -v cursor &>/dev/null && is_installed=true
  [[ -d "$HOME/.cursor" ]] && is_installed=true
  [[ -d "/Applications/Cursor.app" ]] && is_installed=true

  if [[ "$is_installed" == "true" ]]; then
    local rules_dir="$REPO_ROOT/.cursor/rules"
    mkdir -p "$rules_dir"
    cp -f "$REPO_ROOT/adapters/cursor/"*.mdc "$rules_dir/"
    success "Cursor → .cursor/rules/"
    return 0
  fi
  return 1
}

update_windsurf() {
  local is_installed=false
  command -v windsurf &>/dev/null && is_installed=true
  [[ -d "$HOME/.windsurf" ]] && is_installed=true
  [[ -d "/Applications/Windsurf.app" ]] && is_installed=true

  if [[ "$is_installed" == "true" ]]; then
    local rules_dir="$REPO_ROOT/.windsurf/rules"
    mkdir -p "$rules_dir"
    cp -f "$REPO_ROOT/adapters/generic/AGENTS-specos-section.md" "$rules_dir/specos.md"
    success "Windsurf → .windsurf/rules/specos.md"
    return 0
  fi
  return 1
}

update_codex() {
  local instructions="$REPO_ROOT/.github/copilot-instructions.md"
  if [[ -f "$instructions" ]] && grep -q "SpecOS" "$instructions" 2>/dev/null; then
    cp -f "$REPO_ROOT/adapters/generic/AGENTS-specos-section.md" "$instructions"
    success "GitHub Copilot → .github/copilot-instructions.md"
    return 0
  fi
  return 1
}

# --- Main ---

info "Detecting installed agents..."
echo ""

UPDATED=0

update_claude_code && UPDATED=$((UPDATED + 1)) || true
update_opencode    && UPDATED=$((UPDATED + 1)) || true
update_gemini      && UPDATED=$((UPDATED + 1)) || true
update_cursor      && UPDATED=$((UPDATED + 1)) || true
update_windsurf    && UPDATED=$((UPDATED + 1)) || true
update_codex       && UPDATED=$((UPDATED + 1)) || true

echo ""
if [[ $UPDATED -eq 0 ]]; then
  warn "No installed agents found. Run install.sh first."
else
  success "Skills updated in $UPDATED agent(s)."
fi

echo ""
echo "  Skills updated:"
for f in "$REPO_ROOT/skills/"*.md; do
  echo "  - $(basename "$f")"
done
echo ""
