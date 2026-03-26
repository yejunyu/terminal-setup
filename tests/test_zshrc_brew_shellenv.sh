#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$ROOT_DIR/configs/zsh/.zshrc"

shellenv_line="$(rg -n 'brew shellenv' "$TARGET" | head -n1 | cut -d: -f1)"
alias_line="$(rg -n "^alias ls='eza" "$TARGET" | head -n1 | cut -d: -f1)"

[[ -n "$shellenv_line" ]]
[[ -n "$alias_line" ]]
[[ "$shellenv_line" -lt "$alias_line" ]]

echo "zsh brew shellenv test passed"
