#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

export HOME="$TMP_DIR/home"
export XDG_STATE_HOME="$TMP_DIR/state"
mkdir -p "$HOME" "$XDG_STATE_HOME"

# shellcheck source=/dev/null
source "$ROOT_DIR/lib/common.sh"

calls_file="$TMP_DIR/calls.txt"
export TEST_FONT_CALLS_FILE="$calls_file"

brew() {
  if [[ "$1" == "list" && "$2" == "--cask" && "$3" == "font-already-there" ]]; then
    return 0
  fi

  if [[ "$1" == "list" && "$2" == "--cask" ]]; then
    return 1
  fi

  if [[ "$1" == "install" && "$2" == "--cask" && "$3" == "font-fails" ]]; then
    printf 'fail:%s\n' "$3" >> "$TEST_FONT_CALLS_FILE"
    return 1
  fi

  if [[ "$1" == "install" && "$2" == "--cask" ]]; then
    printf 'install:%s\n' "$3" >> "$TEST_FONT_CALLS_FILE"
    return 0
  fi

  return 0
}

brew_install_font_casks_best_effort \
  font-already-there \
  font-fails \
  font-succeeds

! grep -q "install:font-already-there" "$calls_file"
grep -q "fail:font-fails" "$calls_file"
grep -q "install:font-succeeds" "$calls_file"

echo "best effort font install test passed"
