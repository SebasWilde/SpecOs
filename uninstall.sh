#!/usr/bin/env bash
# SpecOS v3 — uninstaller
# Removes all skills installed by install.sh from detected agent directories.
# Does NOT remove project files: AGENTS.md, constitution.md, specos-project.yml, specs/
# Works on macOS and Linux. Idempotent — safe to run multiple times.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECOS_VERSION="3.0"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${BLUE}[SpecOS]${NC} $1"; }
success() { echo -e "${GREEN}[SpecOS]${NC} $1"; }
warn()    { echo -e "${YELLOW}[SpecOS]${NC} $1"; }
removed() { echo -e "${RED}[SpecOS]${NC} removed: $1"; }

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
info "Uninstalling SpecOS v${SPECOS_VERSION} on ${OS}..."
echo ""

# --- Remove symlinks (only if they point to AGENTS.md) ---
remove_symlinks() {
  # CLAUDE.md
  if [[ -L "$REPO_ROOT/CLAUDE.md" ]]; then
    local target
    target=$(readlink "$REPO_ROOT/CLAUDE.md")
    if [[ "$target" == "AGENTS.md" ]]; then
      rm "$REPO_ROOT/CLAUDE.md"
      removed "CLAUDE.md symlink"
    else
      warn "CLAUDE.md is a symlink but does not point to AGENTS.md — skipped"
    fi
  elif [[ -e "$REPO_ROOT/CLAUDE.md" ]]; then
    warn "CLAUDE.md is a real file, not a SpecOS symlink — skipped"
  fi

  # .cursorrules
  if [[ -L "$REPO_ROOT/.cursorrules" ]]; then
    local target
    target=$(readlink "$REPO_ROOT/.cursorrules")
    if [[ "$target" == "AGENTS.md" ]]; then
      rm "$REPO_ROOT/.cursorrules"
      removed ".cursorrules symlink"
    else
      warn ".cursorrules is a symlink but does not point to AGENTS.md — skipped"
    fi
  elif [[ -e "$REPO_ROOT/.cursorrules" ]]; then
    warn ".cursorrules is a real file, not a SpecOS symlink — skipped"
  fi

  # GEMINI.md
  if [[ -L "$REPO_ROOT/GEMINI.md" ]]; then
    local target
    target=$(readlink "$REPO_ROOT/GEMINI.md")
    if [[ "$target" == "AGENTS.md" ]]; then
      rm "$REPO_ROOT/GEMINI.md"
      removed "GEMINI.md symlink"
    else
      warn "GEMINI.md is a symlink but does not point to AGENTS.md — skipped"
    fi
  elif [[ -e "$REPO_ROOT/GEMINI.md" ]]; then
    warn "GEMINI.md is a real file, not a SpecOS symlink — skipped"
  fi
}

# --- Agent uninstallers ---

uninstall_gemini() {
  local commands_dir="$HOME/.gemini/commands"
  if ls "$commands_dir"/specos-*.toml &>/dev/null 2>&1; then
    info "Gemini CLI skills found"
    rm -f "$commands_dir"/specos-*.toml
    success "Skills removed from $commands_dir"
    return 0
  fi
  return 1
}

uninstall_claude_code() {
  local commands_dir="$HOME/.claude/commands"
  if ls "$commands_dir"/specos-*.md &>/dev/null 2>&1; then
    info "Claude Code skills found"
    rm -f "$commands_dir"/specos-*.md
    success "Skills removed from $commands_dir"
    return 0
  fi
  return 1
}

uninstall_opencode() {
  local removed=false
  local old_dir="$HOME/.opencode/commands"
  local new_dir="$HOME/.config/opencode/commands"

  if ls "$new_dir"/specos-*.md &>/dev/null 2>&1; then
    info "OpenCode skills found (new path)"
    rm -f "$new_dir"/specos-*.md
    success "Skills removed from $new_dir"
    removed=true
  fi

  if ls "$old_dir"/specos-*.md &>/dev/null 2>&1; then
    info "OpenCode skills found (legacy path)"
    rm -f "$old_dir"/specos-*.md
    success "Skills removed from $old_dir"
    removed=true
  fi

  [[ "$removed" == "true" ]] && return 0 || return 1
}

uninstall_cursor() {
  local rules_dir="$REPO_ROOT/.cursor/rules"
  if ls "$rules_dir"/specos-*.mdc &>/dev/null 2>&1; then
    info "Cursor rules found"
    rm -f "$rules_dir"/specos-*.mdc
    success "Skills removed from .cursor/rules/"
    # Remove dir if now empty
    rmdir "$rules_dir" 2>/dev/null || true
    return 0
  fi
  return 1
}

uninstall_windsurf() {
  local rules_file="$REPO_ROOT/.windsurf/rules/specos.md"
  if [[ -f "$rules_file" ]]; then
    info "Windsurf rule found"
    rm -f "$rules_file"
    success "Skills removed from .windsurf/rules/"
    rmdir "$REPO_ROOT/.windsurf/rules" 2>/dev/null || true
    return 0
  fi
  return 1
}

uninstall_copilot() {
  local instructions="$REPO_ROOT/.github/copilot-instructions.md"
  if [[ -f "$instructions" ]] && grep -q "SpecOS" "$instructions" 2>/dev/null; then
    info "GitHub Copilot instructions found (SpecOS content)"
    rm -f "$instructions"
    success "Skills removed from .github/copilot-instructions.md"
    return 0
  fi
  return 1
}

uninstall_generic() {
  if [[ -f "$REPO_ROOT/SPECOS-SECTION.md" ]]; then
    rm -f "$REPO_ROOT/SPECOS-SECTION.md"
    removed "SPECOS-SECTION.md"
  fi
}

# --- Main ---
remove_symlinks

echo ""
info "Detecting installed agents..."
echo ""

REMOVED=0

uninstall_claude_code && REMOVED=$((REMOVED + 1)) || true
uninstall_opencode    && REMOVED=$((REMOVED + 1)) || true
uninstall_gemini      && REMOVED=$((REMOVED + 1)) || true
uninstall_cursor      && REMOVED=$((REMOVED + 1)) || true
uninstall_windsurf    && REMOVED=$((REMOVED + 1)) || true
uninstall_copilot     && REMOVED=$((REMOVED + 1)) || true
uninstall_generic

echo ""
if [[ $REMOVED -eq 0 ]]; then
  warn "No SpecOS skills found in any agent directory. Nothing to remove."
else
  success "SpecOS v${SPECOS_VERSION} uninstalled ($REMOVED agent(s) cleaned)."
fi

echo ""
echo "  Project files were NOT removed:"
echo "  AGENTS.md, constitution.md, specos-project.yml, specs/"
echo ""
echo "  To fully remove SpecOS from a project, delete those files manually."
echo ""
