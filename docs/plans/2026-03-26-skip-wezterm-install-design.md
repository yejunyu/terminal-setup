# Skip WezTerm Install Flag Design

**Date:** 2026-03-26

## Goal

Allow `setup.sh install` to skip the `brew install wezterm` step for server environments that do not need the terminal app, while keeping the rest of the setup unchanged.

## Chosen Behavior

Add an install-only flag:

```bash
bash setup.sh install --skip-wezterm-install
```

This flag changes only the package install step for WezTerm itself:

- macOS: skip `brew install --cask wezterm`
- Linux: skip `brew install wezterm`

## Explicit Non-Goals

This flag does **not** skip:

- writing `~/.wezterm.lua`
- copying the wallpaper
- Linux font installation
- uninstall prompts or uninstall behavior

## Rationale

- The user asked specifically to skip only the brew install of WezTerm.
- Keeping the config and wallpaper steps intact avoids introducing a second mode of behavior across the rest of the repository.
- Uninstall already handles “package not present” safely by checking whether a formula or cask is installed before removing it.

## UX

- `setup.sh --help` should show the new flag in the install usage line.
- README should document the server-oriented example using `--skip-wezterm-install`.

## Test Scope

- Extend the smoke test to assert the new flag appears in:
  - `setup.sh`
  - `README.md`
