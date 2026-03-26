# Zshrc Uninstall Fallback Design

**Date:** 2026-03-26

## Goal

Prevent `setup.sh uninstall` from leaving the machine without a usable `~/.zshrc` when the user did not have a pre-install backup to restore.

## Problem

The current uninstall flow restores a previous `.zshrc` when a backup exists, but otherwise deletes the installed `.zshrc`. That leaves users with a bare `zsh` session and no local shell config file at all.

## Chosen Approach

- Keep the existing backup-and-restore behavior when a previous `.zshrc` backup exists.
- Add a dedicated fallback path for `.zshrc` only.
- When no backup exists, write a minimal `~/.zshrc` instead of removing the file.

## Rejected Alternatives

### 1. Keep deleting `.zshrc`

Rejected because it is technically valid but too aggressive for an uninstall flow that intentionally keeps `zsh` installed and active.

### 2. Never touch `.zshrc` during uninstall

Rejected because it would leave references to removed `oh-my-zsh`, `powerlevel10k`, and plugin paths, which creates a broken shell startup experience.

## Minimal Fallback Content

The generated fallback `.zshrc` should be deliberately small and safe:

- a short comment explaining it was created by `terminal-setup uninstall`
- `autoload -Uz compinit`
- `compinit`
- a basic prompt such as `%n@%m:%~ %# `

No framework-specific references should remain.

## Scope

- Apply this fallback only to `.zshrc`
- Keep `.wezterm.lua` and `~/.config/nvim` on the existing restore-or-remove behavior
- Keep uninstall preserving `zsh`, fonts, and wallpaper

## Test Strategy

- Add a focused shell test that sources `lib/common.sh`
- Verify that restoring `.zshrc` from backup still works
- Verify that, with no backup present, uninstall writes a minimal fallback `.zshrc`

## Documentation

- Update the README uninstall section to say:
  - old `.zshrc` is restored when available
  - otherwise a minimal `.zshrc` is generated
