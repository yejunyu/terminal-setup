# Best-Effort Font Install Design

**Date:** 2026-03-27

## Goal

Prevent the installer from aborting when a font cask is already present or otherwise fails individually, while keeping the rest of the install flow strict.

## Chosen Scope

- Keep `wezterm` installation strict
- Keep normal formula installation strict
- Change only the font install path to best-effort behavior

## Desired Behavior

For the managed font casks:

- `font-martian-mono-nerd-font`
- `font-jetbrains-mono-nerd-font`
- `font-cascadia-mono`
- `font-noto-sans-mono-cjk-sc`

the installer should:

1. try each font one by one
2. skip already installed fonts with an `[ OK ]` message
3. if an individual font install fails, print a `[WARN]` message
4. continue with the next font and the rest of the setup

## Why Not Make All Casks Best-Effort

If `wezterm` fails to install, that is a real setup failure and should still stop the script. Fonts are the special case because they are more likely to exist already outside Homebrew or collide with previous manual installs.

## Implementation Shape

- Add a dedicated helper in `lib/common.sh` for font casks
- On macOS:
  - install `wezterm` strictly unless `--skip-wezterm-install` was requested
  - install the four fonts through the new helper
- Linux font handling stays as it is

## Docs and Tests

- README should mention that font casks are installed one by one and skipped on individual failure with a warning
- Add a focused shell test for the helper contract at the function level
