#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

require_file() {
  local path="$1"
  [[ -f "$ROOT_DIR/$path" ]] || {
    echo "missing file: $path" >&2
    exit 1
  }
}

require_file "setup.sh"
require_file "lib/common.sh"
require_file "configs/zsh/.zshrc"
require_file "configs/wezterm/.wezterm.lua"
require_file "README.md"
require_file "assets/wallpaper.jpg"
require_file "docs/plans/2026-03-26-terminal-setup-uninstall-design.md"
require_file "docs/plans/2026-03-26-terminal-setup-uninstall.md"
require_file "docs/plans/2026-03-26-zsh-plugin-design.md"
require_file "docs/plans/2026-03-26-zsh-plugin-integration.md"
require_file "docs/plans/2026-03-26-zshrc-uninstall-fallback-design.md"
require_file "docs/plans/2026-03-26-zshrc-uninstall-fallback.md"
require_file "docs/plans/2026-03-26-skip-wezterm-install-design.md"
require_file "docs/plans/2026-03-26-skip-wezterm-install.md"
require_file "docs/plans/2026-03-26-zsh-brew-shellenv-design.md"
require_file "docs/plans/2026-03-26-zsh-brew-shellenv.md"
require_file "tests/test_zshrc_uninstall_fallback.sh"
require_file "tests/test_zshrc_brew_shellenv.sh"

bash -n "$ROOT_DIR/setup.sh"
bash -n "$ROOT_DIR/lib/common.sh"
bash -n "$ROOT_DIR/tests/test_zshrc_uninstall_fallback.sh"
bash -n "$ROOT_DIR/tests/test_zshrc_brew_shellenv.sh"

grep -q "install" "$ROOT_DIR/setup.sh"
grep -q "uninstall" "$ROOT_DIR/setup.sh"
grep -q -- "--skip-wezterm-install" "$ROOT_DIR/setup.sh"
grep -q "wallpaper.jpg" "$ROOT_DIR/configs/wezterm/.wezterm.lua"
grep -q "bash setup.sh install" "$ROOT_DIR/README.md"
grep -q "bash setup.sh uninstall" "$ROOT_DIR/README.md"
grep -q -- "--skip-wezterm-install" "$ROOT_DIR/README.md"
grep -q "extract" "$ROOT_DIR/configs/zsh/.zshrc"
grep -q "zsh-syntax-highlighting" "$ROOT_DIR/configs/zsh/.zshrc"
grep -q "zsh-autosuggestions" "$ROOT_DIR/configs/zsh/.zshrc"
grep -q "zsh-syntax-highlighting" "$ROOT_DIR/README.md"
grep -q "zsh-autosuggestions" "$ROOT_DIR/README.md"
grep -q "minimal fallback \`.zshrc\`" "$ROOT_DIR/README.md"

echo "repo layout smoke test passed"
