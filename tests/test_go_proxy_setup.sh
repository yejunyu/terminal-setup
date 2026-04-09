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
export TEST_GO_CALLS_FILE="$calls_file"

go() {
  if [[ "$1" == "env" && "$2" == "GO111MODULE" ]]; then
    printf '\n'
    return 0
  fi

  if [[ "$1" == "env" && "$2" == "GOPROXY" ]]; then
    printf '%s\n' "https://proxy.golang.org,direct"
    return 0
  fi

  if [[ "$1" == "env" && "$2" == "-w" ]]; then
    printf '%s\n' "$3" >> "$TEST_GO_CALLS_FILE"
    return 0
  fi

  return 1
}

configure_go_proxy

grep -q "GO111MODULE=on" "$calls_file"
grep -q "GOPROXY=https://goproxy.cn,direct" "$calls_file"

echo "go proxy setup test passed"
