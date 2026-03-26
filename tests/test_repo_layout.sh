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

bash -n "$ROOT_DIR/setup.sh"
bash -n "$ROOT_DIR/lib/common.sh"

echo "repo layout smoke test passed"
