#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

grep -q 'WSL_INTEROP' "$ROOT_DIR/setup.sh"
grep -q 'install_wsl_prereqs' "$ROOT_DIR/setup.sh"
grep -q 'install_wsl_prereqs' "$ROOT_DIR/lib/common.sh"
grep -q 'install_fnm' "$ROOT_DIR/lib/common.sh"
grep -q 'leaving Windows WezTerm config' "$ROOT_DIR/setup.sh"
grep -q 'WSL 本身不会安装 Linux WezTerm' "$ROOT_DIR/README.md"
grep -q '不修改 WSL 内的 `~/.wezterm.lua`，不安装 Linux 字体' "$ROOT_DIR/README.md"
grep -q 'https://github.com/subframe7536/maple-font' "$ROOT_DIR/README.md"

echo "WSL layout smoke test passed"
