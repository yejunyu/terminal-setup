#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

OS_NAME="$(uname -s)"
IS_WSL=0
if [[ "$OS_NAME" == "Linux" ]] && { [[ -n "${WSL_INTEROP:-}" ]] || grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null; }; then
  IS_WSL=1
fi
ACTION="${1:-}"
SKIP_WEZTERM_INSTALL=0

COMMON_FORMULAE=(
  git
  curl
  zsh
  neovim
  go
  tree-sitter
  bat
  eza
  fd
  ripgrep
  fzf
  btop
  zoxide
  jq
  lazygit
  git-delta
  yazi
  zellij
  fnm
)

UNINSTALL_FORMULAE=(
  neovim
  go
  tree-sitter
  bat
  eza
  fd
  ripgrep
  fzf
  btop
  zoxide
  jq
  lazygit
  git-delta
  yazi
  zellij
  fnm
)

BREW_CASKS=(
  codex
)

MAC_FONT_CASKS=(
  font-maple-mono-nf-cn
)

usage() {
  cat <<'EOF'
Usage:
  bash setup.sh install [--skip-wezterm-install]
  bash setup.sh uninstall
EOF
}

run_install() {
  prepare_run

  case "$OS_NAME" in
    Darwin)
      if ! xcode-select -p >/dev/null 2>&1; then
        warn "Xcode Command Line Tools not found"
        warn "Run: xcode-select --install"
      fi

      install_homebrew
      brew_install "${COMMON_FORMULAE[@]}"
      brew_install_casks "${BREW_CASKS[@]}"
      brew_install_font_casks_best_effort "${MAC_FONT_CASKS[@]}"
      ;;
    Linux)
      if [[ "$IS_WSL" -eq 1 ]]; then
        install_wsl_prereqs
        install_homebrew
        brew_install "${COMMON_FORMULAE[@]}" unzip fontconfig
      else
        install_linux_prereqs
        install_homebrew
        brew_install "${COMMON_FORMULAE[@]}" unzip fontconfig
        brew_install_casks "${BREW_CASKS[@]}"
        [[ "$SKIP_WEZTERM_INSTALL" -eq 1 ]] || brew_install wezterm
        install_linux_fonts_best_effort
      fi
      ;;
    *)
      die "Unsupported operating system: $OS_NAME"
      ;;
  esac

  configure_go_proxy
  install_oh_my_zsh
  install_zsh_plugins
  install_p10k
  install_bun

  copy_with_backup "$CONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc"
  if [[ "$IS_WSL" -eq 1 ]]; then
    info "WSL detected: leaving Windows WezTerm config and fonts to the Windows host"
  else
    copy_with_backup "$CONFIG_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"
    copy_wallpaper
  fi

  configure_default_zsh
  configure_fnm_node
  install_nvim_config

  cat <<'EOF'
Setup complete.

Next steps:
1. exec zsh
2. p10k configure
3. nvim
EOF
}

run_uninstall() {
  local previous_backup_dir=""

  prepare_run
  previous_backup_dir="$(find_latest_backup_dir "$BACKUP_DIR" || true)"

  info "Interactive uninstall preserves zsh, Ubuntu system packages, and Windows-side fonts."

  if confirm_action "Remove Neovim, Go, CLI tools, and fnm from Homebrew/Linuxbrew?"; then
    case "$OS_NAME:$IS_WSL" in
      Darwin:0)
        brew_uninstall_formulae "${UNINSTALL_FORMULAE[@]}"
        ;;
      Linux:*)
        brew_uninstall_formulae "${UNINSTALL_FORMULAE[@]}"
        ;;
      *)
        die "Unsupported operating system: $OS_NAME"
        ;;
    esac
  else
    info "Skipped brew-managed package removal"
  fi

  if confirm_action "Remove Oh My Zsh, p10k, managed Zsh plugins, then restore ~/.zshrc or create a minimal fallback?"; then
    [[ -e "$HOME/.zshrc" ]] && backup_path "$HOME/.zshrc"
    remove_zsh_plugins
    remove_oh_my_zsh
    restore_or_create_minimal_zshrc "$previous_backup_dir"
  else
    info "Skipped shell customization removal"
  fi

  if confirm_action "Remove bun and fnm runtime directories, including installed Node versions?"; then
    remove_bun_runtime
    remove_fnm_runtime
  else
    info "Skipped bun and fnm runtime removal"
  fi

  if confirm_action "Restore or remove ~/.wezterm.lua?"; then
    [[ -e "$HOME/.wezterm.lua" ]] && backup_path "$HOME/.wezterm.lua"
    restore_or_remove_path "$HOME/.wezterm.lua" "$previous_backup_dir"
  else
    info "Skipped WezTerm config removal"
  fi

  if confirm_action "Restore or remove ~/.config/nvim?"; then
    [[ -e "$HOME/.config/nvim" ]] && backup_path "$HOME/.config/nvim"
    restore_or_remove_path "$HOME/.config/nvim" "$previous_backup_dir"
  else
    info "Skipped Neovim config removal"
  fi

  if confirm_action "Uninstall Homebrew/Linuxbrew itself? This also removes any remaining brew-managed packages."; then
    uninstall_homebrew
    remove_terminal_setup_brew_profile_block
  else
    info "Skipped Homebrew/Linuxbrew uninstall"
  fi

  cat <<'EOF'
Uninstall flow finished.

Preserved:
- zsh
- fonts
- wallpaper
EOF
}

case "$ACTION" in
  install)
    shift
    while [[ "$#" -gt 0 ]]; do
      case "$1" in
        --skip-wezterm-install)
          SKIP_WEZTERM_INSTALL=1
          ;;
        *)
          usage
          exit 1
          ;;
      esac
      shift
    done
    run_install
    ;;
  uninstall)
    run_uninstall
    ;;
  -h|--help)
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac
