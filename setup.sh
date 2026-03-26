#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

OS_NAME="$(uname -s)"

prepare_run

case "$OS_NAME" in
  Darwin)
    if ! xcode-select -p >/dev/null 2>&1; then
      warn "Xcode Command Line Tools not found"
      warn "Run: xcode-select --install"
    fi

    install_homebrew

    brew_install \
      git curl zsh neovim go \
      bat eza fd ripgrep fzf btop zoxide jq \
      lazygit git-delta yazi zellij fnm

    brew_install_casks \
      wezterm \
      font-martian-mono-nerd-font \
      font-jetbrains-mono-nerd-font \
      font-cascadia-mono \
      font-noto-sans-mono-cjk-sc
    ;;
  Linux)
    ensure_linux_prereqs

    install_homebrew

    brew_install \
      git curl zsh neovim go unzip fontconfig \
      bat eza fd ripgrep fzf btop zoxide jq \
      lazygit git-delta yazi zellij fnm

    brew tap wezterm/wezterm-linuxbrew
    brew_install wezterm
    install_linux_fonts_best_effort
    ;;
  *)
    die "Unsupported operating system: $OS_NAME"
    ;;
esac

install_oh_my_zsh
install_p10k
install_bun

copy_with_backup "$CONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc"
copy_with_backup "$CONFIG_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"

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
