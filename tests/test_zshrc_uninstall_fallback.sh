#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

export HOME="$TMP_HOME/home"
export XDG_STATE_HOME="$TMP_HOME/state"
mkdir -p "$HOME" "$XDG_STATE_HOME"

# shellcheck source=/dev/null
source "$ROOT_DIR/lib/common.sh"

backup_dir="$STATE_DIR/backups/20260326_000000"
mkdir -p "$backup_dir"
printf '%s\n' "restored zshrc" > "$backup_dir/$(backup_key_for_path "$HOME/.zshrc")"

restore_or_create_minimal_zshrc "$backup_dir"
grep -qxF "restored zshrc" "$HOME/.zshrc"

rm -f "$HOME/.zshrc"
rm -rf "$STATE_DIR/backups"

restore_or_create_minimal_zshrc
grep -q "terminal-setup uninstall" "$HOME/.zshrc"
grep -q "autoload -Uz compinit" "$HOME/.zshrc"
grep -q "compinit" "$HOME/.zshrc"
grep -q "PROMPT='%n@%m:%~ %# '" "$HOME/.zshrc"

echo "zshrc uninstall fallback test passed"
