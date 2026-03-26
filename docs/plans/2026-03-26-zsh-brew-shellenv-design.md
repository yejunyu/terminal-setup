# Zsh Brew Shellenv Bootstrap Design

**Date:** 2026-03-26

## Goal

Make the generated `~/.zshrc` usable in non-login `zsh` shells by ensuring Homebrew/Linuxbrew binaries are available before alias definitions and plugin setup rely on them.

## Problem

The installer persists Homebrew shellenv lines in profile files such as `.zprofile`, but some interactive `zsh` sessions start as non-login shells and read `.zshrc` without reading `.zprofile`. In that case, aliases like `ll -> eza` can fail with `command not found`.

## Chosen Fix

- Add a Homebrew/Linuxbrew shellenv bootstrap block near the top of `configs/zsh/.zshrc`
- Place it before plugin loading and before aliases
- Keep the install order unchanged

## Why Not Reorder Install Steps

The repo already installs brew formulae before copying `.zshrc`. Changing the order would not fix shells that start without the Homebrew PATH.

## Shellenv Block

The `.zshrc` block should check these candidates in order:

- `/opt/homebrew/bin/brew`
- `/usr/local/bin/brew`
- `$HOME/.linuxbrew/bin/brew`
- `/home/linuxbrew/.linuxbrew/bin/brew`

When one exists, it should run:

```bash
eval "$(<brew-path> shellenv)"
```

## Scope

- Update only the generated repo `.zshrc`
- Update README to explain why brew-installed commands are available in non-login `zsh`
- Keep alias definitions unchanged
- Keep install order unchanged

## Test Strategy

- Add a focused test to assert `.zshrc` contains a `brew shellenv` block
- Verify that the shellenv block appears before the first `alias ls=...` line
