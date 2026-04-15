#!/usr/bin/env bash
# SpecOS v3 — installer
# Detects installed agents and copies skills to the correct locations.
# Creates symlinks: CLAUDE.md → AGENTS.md, .cursorrules → AGENTS.md
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
  echo "SpecOS v3 supports macOS and Linux only. Windows is out of scope for v3."
  exit 1
fi

echo ""
info "Installing SpecOS v${SPECOS_VERSION} on ${OS}..."
echo ""

# --- Symlinks ---
create_symlinks() {
  # CLAUDE.md → AGENTS.md
  if [[ -L "$REPO_ROOT/CLAUDE.md" ]]; then
    info "CLAUDE.md symlink already exists — skipped"
  elif [[ -e "$REPO_ROOT/CLAUDE.md" ]]; then
    warn "CLAUDE.md exists as a real file — skipped (manual review needed)"
  else
    ln -s "AGENTS.md" "$REPO_ROOT/CLAUDE.md"
    success "Created symlink: CLAUDE.md → AGENTS.md"
  fi

  # .cursorrules → AGENTS.md
  if [[ -L "$REPO_ROOT/.cursorrules" ]]; then
    info ".cursorrules symlink already exists — skipped"
  elif [[ -e "$REPO_ROOT/.cursorrules" ]]; then
    warn ".cursorrules exists as a real file — skipped (manual review needed)"
  else
    ln -s "AGENTS.md" "$REPO_ROOT/.cursorrules"
    success "Created symlink: .cursorrules → AGENTS.md"
  fi
}

# --- Agent installers ---

install_claude_code() {
  if [[ -d "$HOME/.claude" ]]; then
    local commands_dir="$HOME/.claude/commands"
    info "Claude Code detected"
    mkdir -p "$commands_dir"
    cp -f "$REPO_ROOT/adapters/claude-code/"*.md "$commands_dir/"
    success "Skills installed → $commands_dir"
    return 0
  fi
  return 1
}

install_opencode() {
  if [[ -d "$HOME/.opencode" ]]; then
    local commands_dir="$HOME/.opencode/commands"
    info "OpenCode detected"
    mkdir -p "$commands_dir"
    cp -f "$REPO_ROOT/adapters/opencode/"*.md "$commands_dir/"
    success "Skills installed → $commands_dir"
    return 0
  fi
  return 1
}

install_cursor() {
  local is_installed=false
  command -v cursor &>/dev/null && is_installed=true
  [[ -d "$HOME/.cursor" ]] && is_installed=true
  [[ -d "/Applications/Cursor.app" ]] && is_installed=true

  if [[ "$is_installed" == "true" ]]; then
    local rules_dir="$REPO_ROOT/.cursor/rules"
    info "Cursor detected"
    mkdir -p "$rules_dir"
    cp -f "$REPO_ROOT/adapters/cursor/"*.mdc "$rules_dir/"
    success "Skills installed → .cursor/rules/"
    return 0
  fi
  return 1
}

install_windsurf() {
  local is_installed=false
  command -v windsurf &>/dev/null && is_installed=true
  [[ -d "$HOME/.windsurf" ]] && is_installed=true
  [[ -d "/Applications/Windsurf.app" ]] && is_installed=true

  if [[ "$is_installed" == "true" ]]; then
    local rules_dir="$REPO_ROOT/.windsurf/rules"
    info "Windsurf detected"
    mkdir -p "$rules_dir"
    cp -f "$REPO_ROOT/adapters/generic/AGENTS-specos-section.md" "$rules_dir/specos.md"
    success "Skills installed → .windsurf/rules/specos.md"
    return 0
  fi
  return 1
}

install_codex() {
  # GitHub Copilot Coding Agent / OpenAI Codex — uses .github/copilot-instructions.md
  if [[ -d "$REPO_ROOT/.github" ]] || command -v gh &>/dev/null; then
    local instructions="$REPO_ROOT/.github/copilot-instructions.md"
    info "GitHub/Codex environment detected"
    mkdir -p "$REPO_ROOT/.github"
    cp -f "$REPO_ROOT/adapters/generic/AGENTS-specos-section.md" "$instructions"
    success "Skills installed → .github/copilot-instructions.md"
    return 0
  fi
  return 1
}

install_generic() {
  warn "No known agents detected. Writing generic adapter."
  cp -f "$REPO_ROOT/adapters/generic/AGENTS-specos-section.md" "$REPO_ROOT/SPECOS-SECTION.md"
  warn "Append SPECOS-SECTION.md to your AGENTS.md for Kiro, Antigravity, or any compatible agent."
  success "Generic section written → SPECOS-SECTION.md"
}

# --- Main ---
create_symlinks

echo ""
info "Detecting installed agents..."
echo ""

INSTALLED=0

install_claude_code && INSTALLED=$((INSTALLED + 1)) || true
install_opencode    && INSTALLED=$((INSTALLED + 1)) || true
install_cursor      && INSTALLED=$((INSTALLED + 1)) || true
install_windsurf    && INSTALLED=$((INSTALLED + 1)) || true
install_codex       && INSTALLED=$((INSTALLED + 1)) || true

if [[ $INSTALLED -eq 0 ]]; then
  install_generic
fi

echo ""
success "SpecOS v${SPECOS_VERSION} installed."
echo ""
echo "  Next: run /specos-init in your AI agent to configure this project."
echo "  Then: run /specos-start to begin your first session."
echo ""
