#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$ROOT_DIR/configs"
ASSET_DIR="$ROOT_DIR/assets"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/terminal-setup"
RUN_ID="${RUN_ID:-$(date +%Y%m%d_%H%M%S)}"
BACKUP_DIR="$STATE_DIR/backups/$RUN_ID"
TERMINAL_SETUP_CONFIG_DIR="$HOME/.config/terminal-setup"
WALLPAPER_DEST="$TERMINAL_SETUP_CONFIG_DIR/wallpaper.jpg"

BREW_GIT_REMOTE="${HOMEBREW_BREW_GIT_REMOTE:-https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git}"
BREW_CORE_GIT_REMOTE="${HOMEBREW_CORE_GIT_REMOTE:-}"
BREW_API_DOMAIN="${HOMEBREW_API_DOMAIN:-https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api}"
BREW_BOTTLE_DOMAIN="${HOMEBREW_BOTTLE_DOMAIN:-https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles}"
OH_MY_ZSH_REMOTE="${OH_MY_ZSH_REMOTE:-https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git}"
P10K_REMOTE="${P10K_REMOTE:-https://github.com/romkatv/powerlevel10k.git}"
ZSH_AUTOSUGGESTIONS_REMOTE="${ZSH_AUTOSUGGESTIONS_REMOTE:-https://gitee.com/zsh-users/zsh-autosuggestions.git}"
ZSH_SYNTAX_HIGHLIGHTING_REMOTE="${ZSH_SYNTAX_HIGHLIGHTING_REMOTE:-https://gitee.com/zsh-users/zsh-syntax-highlighting.git}"
NVIM_REMOTE="${NVIM_REMOTE:-https://github.com/yejunyu/mynvim.git}"
BUN_INSTALL_URL="${BUN_INSTALL_URL:-https://bun.sh/install}"
GO111MODULE_VALUE="${GO111MODULE_VALUE:-on}"
GOPROXY_VALUE="${GOPROXY_VALUE:-https://goproxy.cn,direct}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
ok() { echo -e "${GREEN}[ OK ]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
die() { echo -e "${RED}[ERR ]${NC} $*" >&2; exit 1; }

require_os() {
  [[ "$(uname -s)" == "$1" ]] || die "This script only supports $1"
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

prepare_run() {
  mkdir -p "$BACKUP_DIR"
  info "Backup directory: $BACKUP_DIR"
}

backup_key_for_path() {
  local path="$1"
  echo "$path" | sed "s#${HOME}#HOME#g; s#[/ ]#_#g"
}

backup_path() {
  local path="$1"
  [[ -e "$path" ]] || return 0

  local safe_name
  safe_name="$(backup_key_for_path "$path")"
  mkdir -p "$BACKUP_DIR"
  mv "$path" "$BACKUP_DIR/$safe_name"
  warn "Backed up $path -> $BACKUP_DIR/$safe_name"
}

copy_with_backup() {
  local src="$1"
  local dest="$2"
  [[ -f "$src" ]] || die "Source file does not exist: $src"
  [[ -e "$dest" ]] && backup_path "$dest"
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  ok "Wrote $dest"
}

copy_wallpaper() {
  local src="$ASSET_DIR/wallpaper.jpg"
  [[ -f "$src" ]] || die "Wallpaper asset does not exist: $src"
  mkdir -p "$TERMINAL_SETUP_CONFIG_DIR"
  cp "$src" "$WALLPAPER_DEST"
  ok "Installed wallpaper to $WALLPAPER_DEST"
}

ensure_line() {
  local file="$1"
  local line="$2"
  touch "$file"
  grep -qxF "$line" "$file" 2>/dev/null || printf '%s\n' "$line" >> "$file"
}

ensure_block_once() {
  local file="$1"
  local marker="$2"
  local content="$3"
  touch "$file"
  grep -qF "$marker" "$file" 2>/dev/null || printf '\n%s\n%s\n' "$marker" "$content" >> "$file"
}

find_latest_backup_dir() {
  local exclude="${1:-}"
  local candidate

  [[ -d "$STATE_DIR/backups" ]] || return 1

  while IFS= read -r candidate; do
    [[ -n "$exclude" && "$candidate" == "$exclude" ]] && continue
    printf '%s\n' "$candidate"
    return 0
  done < <(find "$STATE_DIR/backups" -mindepth 1 -maxdepth 1 -type d | sort -r)

  return 1
}

restore_or_remove_path() {
  local path="$1"
  local backup_dir="${2:-}"
  local backup_target=""

  if [[ -n "$backup_dir" ]]; then
    backup_target="$backup_dir/$(backup_key_for_path "$path")"
  fi

  if [[ -n "$backup_target" && -e "$backup_target" ]]; then
    mkdir -p "$(dirname "$path")"
    mv "$backup_target" "$path"
    ok "Restored $path from $backup_dir"
    return 0
  fi

  if [[ -e "$path" ]]; then
    rm -rf "$path"
    ok "Removed $path"
  else
    warn "No backup found for $path; nothing to restore"
  fi
}

write_minimal_zshrc() {
  mkdir -p "$HOME"
  cat > "$HOME/.zshrc" <<'EOF'
# Minimal zsh config restored by terminal-setup uninstall.
autoload -Uz compinit
compinit
PROMPT='%n@%m:%~ %# '
EOF
  ok "Wrote minimal ~/.zshrc"
}

restore_or_create_minimal_zshrc() {
  local backup_dir="${1:-}"
  local path="$HOME/.zshrc"
  local backup_target=""

  if [[ -n "$backup_dir" ]]; then
    backup_target="$backup_dir/$(backup_key_for_path "$path")"
  fi

  if [[ -n "$backup_target" && -e "$backup_target" ]]; then
    mkdir -p "$(dirname "$path")"
    mv "$backup_target" "$path"
    ok "Restored $path from $backup_dir"
    return 0
  fi

  write_minimal_zshrc
}

confirm_action() {
  local prompt="$1"
  local reply

  while true; do
    printf '%s [y/N] ' "$prompt"
    if ! read -r reply; then
      return 1
    fi

    case "$reply" in
      [Yy]|[Yy][Ee][Ss])
        return 0
        ;;
      ""|[Nn]|[Nn][Oo])
        return 1
        ;;
      *)
        warn "Please answer y or n."
        ;;
    esac
  done
}

load_brew_env() {
  local candidate
  for candidate in \
    /opt/homebrew/bin/brew \
    /usr/local/bin/brew \
    "$HOME/.linuxbrew/bin/brew" \
    /home/linuxbrew/.linuxbrew/bin/brew
  do
    if [[ -x "$candidate" ]]; then
      eval "$("$candidate" shellenv)"
      return 0
    fi
  done

  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
    return 0
  fi

  return 1
}

persist_brew_settings() {
  local file
  local targets=()
  local shellenv_block='if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
elif [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
  eval "$("$HOME/.linuxbrew/bin/brew" shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi'

  for file in "$HOME/.zprofile" "$HOME/.profile" "$HOME/.bash_profile"; do
    [[ -f "$file" ]] && targets+=("$file")
  done

  if [[ "${#targets[@]}" -eq 0 ]]; then
    targets+=("$HOME/.zprofile")
  fi

  for file in "${targets[@]}"; do
    ensure_line "$file" "export HOMEBREW_BREW_GIT_REMOTE=\"$BREW_GIT_REMOTE\""
    ensure_line "$file" "export HOMEBREW_API_DOMAIN=\"$BREW_API_DOMAIN\""
    ensure_line "$file" "export HOMEBREW_BOTTLE_DOMAIN=\"$BREW_BOTTLE_DOMAIN\""
    if [[ -n "$BREW_CORE_GIT_REMOTE" ]]; then
      ensure_line "$file" "export HOMEBREW_CORE_GIT_REMOTE=\"$BREW_CORE_GIT_REMOTE\""
    fi
    ensure_block_once "$file" "# terminal-setup: brew shellenv" "$shellenv_block"
  done
}

ensure_linux_prereqs() {
  local missing=()
  local cmd

  for cmd in git curl file ps make; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done

  if ! command -v gcc >/dev/null 2>&1 && ! command -v cc >/dev/null 2>&1; then
    missing+=("gcc-or-cc")
  fi

  if [[ "${#missing[@]}" -eq 0 ]]; then
    return 0
  fi

  cat >&2 <<EOF
[ERR ] Missing Linux prerequisites for Homebrew: ${missing[*]}

Install the required build tools first. Homebrew's current Linux docs recommend:

Debian/Ubuntu:
  sudo apt-get install build-essential procps curl file git

Fedora:
  sudo dnf group install development-tools
  sudo dnf install procps-ng curl file

CentOS Stream / RHEL:
  sudo dnf group install 'Development Tools'
  sudo dnf install procps-ng curl file

Arch Linux:
  sudo pacman -S base-devel procps-ng curl file git
EOF
  exit 1
}

install_homebrew() {
  need_cmd git
  need_cmd curl

  export HOMEBREW_BREW_GIT_REMOTE="$BREW_GIT_REMOTE"
  export HOMEBREW_API_DOMAIN="$BREW_API_DOMAIN"
  export HOMEBREW_BOTTLE_DOMAIN="$BREW_BOTTLE_DOMAIN"
  if [[ -n "$BREW_CORE_GIT_REMOTE" ]]; then
    export HOMEBREW_CORE_GIT_REMOTE="$BREW_CORE_GIT_REMOTE"
  fi

  if ! load_brew_env; then
    local tmp
    tmp="$(mktemp -d)"
    info "Installing Homebrew/Linuxbrew from TUNA mirror..."
    git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/install.git "$tmp/brew-install"
    /bin/bash "$tmp/brew-install/install.sh"
    rm -rf "$tmp"
    load_brew_env || die "brew was installed but shellenv could not be loaded"
  else
    ok "Homebrew already installed"
  fi

  persist_brew_settings
  brew update
}

brew_install() {
  local missing=()
  local pkg

  for pkg in "$@"; do
    brew list "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
  done

  if [[ "${#missing[@]}" -gt 0 ]]; then
    info "Installing formulae: ${missing[*]}"
    brew install "${missing[@]}"
  else
    ok "Requested formulae already installed"
  fi
}

brew_install_casks() {
  local missing=()
  local pkg

  for pkg in "$@"; do
    brew list --cask "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
  done

  if [[ "${#missing[@]}" -gt 0 ]]; then
    info "Installing casks: ${missing[*]}"
    brew install --cask "${missing[@]}"
  else
    ok "Requested casks already installed"
  fi
}

brew_install_font_casks_best_effort() {
  local pkg

  for pkg in "$@"; do
    if brew list --cask "$pkg" >/dev/null 2>&1; then
      ok "Font cask already installed: $pkg"
      continue
    fi

    info "Installing font cask: $pkg"
    if ! brew install --cask "$pkg"; then
      warn "Skipping font cask after install failure: $pkg"
    fi
  done
}

brew_uninstall_formulae() {
  local installed=()
  local pkg

  load_brew_env || {
    warn "Homebrew is unavailable; skipping formula uninstall"
    return 0
  }

  for pkg in "$@"; do
    brew list --formula "$pkg" >/dev/null 2>&1 && installed+=("$pkg")
  done

  if [[ "${#installed[@]}" -gt 0 ]]; then
    info "Removing formulae: ${installed[*]}"
    brew uninstall --force "${installed[@]}"
  else
    ok "Requested formulae are already absent"
  fi
}

brew_uninstall_casks() {
  local installed=()
  local pkg

  load_brew_env || {
    warn "Homebrew is unavailable; skipping cask uninstall"
    return 0
  }

  for pkg in "$@"; do
    brew list --cask "$pkg" >/dev/null 2>&1 && installed+=("$pkg")
  done

  if [[ "${#installed[@]}" -gt 0 ]]; then
    info "Removing casks: ${installed[*]}"
    brew uninstall --cask "${installed[@]}"
  else
    ok "Requested casks are already absent"
  fi
}

install_oh_my_zsh() {
  local target="$HOME/.oh-my-zsh"

  if [[ -d "$target/.git" ]]; then
    info "Updating Oh My Zsh..."
    git -C "$target" remote set-url origin "$OH_MY_ZSH_REMOTE"
    git -C "$target" pull --ff-only || warn "Skipping Oh My Zsh update"
  else
    info "Cloning Oh My Zsh..."
    git clone --depth=1 "$OH_MY_ZSH_REMOTE" "$target"
  fi
}

install_zsh_plugin() {
  local name="$1"
  local remote="$2"
  local target="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$name"

  mkdir -p "$(dirname "$target")"

  if [[ -d "$target/.git" ]]; then
    info "Updating Zsh plugin $name..."
    git -C "$target" remote set-url origin "$remote"
    git -C "$target" pull --ff-only || warn "Skipping update for $name"
  else
    info "Cloning Zsh plugin $name..."
    git clone --depth=1 "$remote" "$target"
  fi
}

install_zsh_plugins() {
  install_zsh_plugin "zsh-autosuggestions" "$ZSH_AUTOSUGGESTIONS_REMOTE"
  install_zsh_plugin "zsh-syntax-highlighting" "$ZSH_SYNTAX_HIGHLIGHTING_REMOTE"
}

install_p10k() {
  local target="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  mkdir -p "$(dirname "$target")"

  if [[ -d "$target/.git" ]]; then
    info "Updating powerlevel10k..."
    git -C "$target" remote set-url origin "$P10K_REMOTE"
    git -C "$target" pull --ff-only || warn "Skipping powerlevel10k update"
  else
    info "Cloning powerlevel10k..."
    git clone --depth=1 "$P10K_REMOTE" "$target"
  fi
}

remove_oh_my_zsh() {
  local removed=0
  local target
  local p10k_path="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

  for target in "$HOME/.oh-my-zsh" "$p10k_path" "$HOME/.p10k.zsh"; do
    if [[ -e "$target" ]]; then
      rm -rf "$target"
      ok "Removed $target"
      removed=1
    fi
  done

  if [[ "$removed" -eq 0 ]]; then
    warn "Oh My Zsh and powerlevel10k are already absent"
  fi
}

remove_zsh_plugins() {
  local removed=0
  local target
  local plugins_root="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

  for target in \
    "$plugins_root/zsh-autosuggestions" \
    "$plugins_root/zsh-syntax-highlighting"
  do
    if [[ -e "$target" ]]; then
      rm -rf "$target"
      ok "Removed $target"
      removed=1
    fi
  done

  if [[ "$removed" -eq 0 ]]; then
    warn "Managed Zsh plugins are already absent"
  fi
}

configure_default_zsh() {
  local zsh_path

  if [[ -x "$(brew --prefix)/bin/zsh" ]]; then
    zsh_path="$(brew --prefix)/bin/zsh"
  else
    zsh_path="$(command -v zsh)"
  fi

  if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
    info "Adding $zsh_path to /etc/shells"
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  if [[ "${SHELL:-}" != "$zsh_path" ]]; then
    info "Changing default shell to $zsh_path"
    chsh -s "$zsh_path"
  else
    ok "Default shell already uses zsh"
  fi
}

install_bun() {
  if command -v bun >/dev/null 2>&1; then
    ok "bun already installed"
    return 0
  fi

  info "Installing bun via official installer..."
  curl -fsSL "$BUN_INSTALL_URL" | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  command -v bun >/dev/null 2>&1 || die "bun installer completed but bun is still unavailable"
  ok "bun installed"
}

configure_go_proxy() {
  if ! command -v go >/dev/null 2>&1; then
    warn "go command not found; skipping Go proxy setup"
    return 0
  fi

  local current_go111module=""
  local current_goproxy=""

  current_go111module="$(go env GO111MODULE 2>/dev/null || true)"
  current_goproxy="$(go env GOPROXY 2>/dev/null || true)"

  if [[ "$current_go111module" != "$GO111MODULE_VALUE" ]]; then
    go env -w "GO111MODULE=$GO111MODULE_VALUE"
  fi

  if [[ "$current_goproxy" != "$GOPROXY_VALUE" ]]; then
    go env -w "GOPROXY=$GOPROXY_VALUE"
  fi

  ok "Configured Go modules and proxy: GO111MODULE=$GO111MODULE_VALUE GOPROXY=$GOPROXY_VALUE"
}

remove_bun_runtime() {
  local removed=0
  local target

  for target in "$HOME/.bun" "$HOME/.cache/bun"; do
    if [[ -e "$target" ]]; then
      rm -rf "$target"
      ok "Removed $target"
      removed=1
    fi
  done

  if [[ "$removed" -eq 0 ]]; then
    warn "bun runtime directories are already absent"
  fi
}

configure_fnm_node() {
  eval "$(fnm env --use-on-cd --shell bash)"
  fnm install --lts
  fnm default lts-latest
  fnm use lts-latest
  ok "Node LTS installed and selected through fnm"
}

remove_fnm_runtime() {
  local removed=0
  local target

  for target in "$HOME/.local/share/fnm" "$HOME/.fnm"; do
    if [[ -e "$target" ]]; then
      rm -rf "$target"
      ok "Removed $target"
      removed=1
    fi
  done

  if [[ "$removed" -eq 0 ]]; then
    warn "fnm runtime directories are already absent"
  fi
}

install_nvim_config() {
  local target="$HOME/.config/nvim"
  mkdir -p "$HOME/.config"

  if [[ -d "$target/.git" ]]; then
    local remote
    remote="$(git -C "$target" remote get-url origin || true)"
    if [[ "$remote" == *"yejunyu/mynvim"* ]]; then
      if git -C "$target" diff --quiet && git -C "$target" diff --cached --quiet; then
        info "Updating existing Neovim config..."
        git -C "$target" pull --ff-only || warn "Skipping Neovim config update"
      else
        warn "Existing Neovim config has local changes; leaving it untouched"
      fi
      return 0
    fi
  fi

  if [[ -e "$target" ]]; then
    backup_path "$target"
  fi

  info "Cloning Neovim config from $NVIM_REMOTE"
  git clone --depth=1 "$NVIM_REMOTE" "$target"
  ok "Neovim config installed"
}

remove_exact_lines() {
  local file="$1"
  shift

  [[ -f "$file" ]] || return 0

  local patterns
  local tmp
  patterns="$(mktemp)"
  tmp="$(mktemp)"

  printf '%s\n' "$@" > "$patterns"
  awk 'NR == FNR { skip[$0] = 1; next } !($0 in skip)' "$patterns" "$file" > "$tmp"
  mv "$tmp" "$file"
  rm -f "$patterns"
}

remove_lines_matching_regex() {
  local file="$1"
  shift

  [[ -f "$file" ]] || return 0

  local patterns
  local tmp
  patterns="$(mktemp)"
  tmp="$(mktemp)"

  printf '%s\n' "$@" > "$patterns"
  awk '
    NR == FNR { patterns[++count] = $0; next }
    {
      for (i = 1; i <= count; i++) {
        if ($0 ~ patterns[i]) {
          next
        }
      }
      print
    }
  ' "$patterns" "$file" > "$tmp"
  mv "$tmp" "$file"
  rm -f "$patterns"
}

remove_terminal_setup_brew_profile_block() {
  local file
  local changed=0

  for file in "$HOME/.zprofile" "$HOME/.profile" "$HOME/.bash_profile"; do
    [[ -f "$file" ]] || continue

    remove_lines_matching_regex \
      "$file" \
      '^export HOMEBREW_BREW_GIT_REMOTE=' \
      '^export HOMEBREW_API_DOMAIN=' \
      '^export HOMEBREW_BOTTLE_DOMAIN=' \
      '^export HOMEBREW_CORE_GIT_REMOTE=' \
      '^# terminal-setup: brew shellenv$' \
      '^if \[\[ -x /opt/homebrew/bin/brew \]\]; then$' \
      '^  eval "\$\(/opt/homebrew/bin/brew shellenv\)"$' \
      '^elif \[\[ -x /usr/local/bin/brew \]\]; then$' \
      '^  eval "\$\(/usr/local/bin/brew shellenv\)"$' \
      '^elif \[\[ -x "\$HOME/.linuxbrew/bin/brew" \]\]; then$' \
      '^  eval "\$\("\$HOME/.linuxbrew/bin/brew" shellenv\)"$' \
      '^elif \[\[ -x /home/linuxbrew/.linuxbrew/bin/brew \]\]; then$' \
      '^  eval "\$\(/home/linuxbrew/.linuxbrew/bin/brew shellenv\)"$' \
      '^fi$'
    changed=1
  done

  if [[ "$changed" -eq 1 ]]; then
    ok "Removed terminal-setup Homebrew profile lines"
  else
    warn "No terminal-setup Homebrew profile lines found"
  fi
}

uninstall_homebrew() {
  local prefix
  local tmp

  load_brew_env || {
    warn "Homebrew is already unavailable"
    return 0
  }

  prefix="$(brew --prefix)"
  tmp="$(mktemp -d)"
  info "Running official Homebrew uninstall script for $prefix"
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh -o "$tmp/uninstall.sh"
  NONINTERACTIVE=1 /bin/bash "$tmp/uninstall.sh" --path "$prefix"
  rm -rf "$tmp"
  ok "Homebrew uninstall finished"
}

install_linux_font_release() {
  local family="$1"
  local match="$2"
  local fonts_dir="${3:-${XDG_DATA_HOME:-$HOME/.local/share}/fonts}"

  if find "$fonts_dir" -maxdepth 1 -type f -iname "$match" | grep -q . 2>/dev/null; then
    ok "Font already present for $family"
    return 0
  fi

  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${family}.zip" -o "$tmp/${family}.zip"
  unzip -oq "$tmp/${family}.zip" -d "$tmp/$family"
  find "$tmp/$family" -type f \( -name '*.ttf' -o -name '*.otf' \) -exec cp {} "$fonts_dir/" \;
  rm -rf "$tmp"
  ok "Installed $family fonts into $fonts_dir"
}

install_linux_fonts_best_effort() {
  local fonts_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
  mkdir -p "$fonts_dir"

  brew_install unzip fontconfig
  install_linux_font_release "MartianMono" "*MartianMono*"
  install_linux_font_release "JetBrainsMono" "*JetBrainsMono*"

  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$fonts_dir"
  fi

  warn "Linux font bootstrap installed the two primary Nerd Fonts. Cascadia Mono and Noto Sans Mono CJK SC may still need manual installation on some distros."
}
