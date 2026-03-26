# Terminal Setup Install/Uninstall Design

**Date:** 2026-03-26

## Goal

Extend the existing `terminal-setup` repository so it supports both installation and interactive uninstallation from the same entry script, while also shipping the user's WezTerm wallpaper inside the repository.

## Decisions

- Keep a single entrypoint: `bash setup.sh install` and `bash setup.sh uninstall`
- Keep OS detection inside `setup.sh` with `uname -s`
- Keep `zsh` installed after uninstall
- Keep the default shell as `zsh` after uninstall
- Uninstall `oh-my-zsh` and `powerlevel10k`
- Restore or remove `.zshrc`, `.wezterm.lua`, and `~/.config/nvim`
- Uninstall Homebrew/Linuxbrew at the end when the user confirms it
- Do not delete fonts
- Do not delete the wallpaper file
- Store the wallpaper in the repo as `assets/wallpaper.jpg`
- Install the wallpaper to `~/.config/terminal-setup/wallpaper.jpg`

## Install Flow

1. Parse `install` as the subcommand.
2. Detect the operating system.
3. Create a backup directory for any files that will be replaced.
4. Install Homebrew or Linuxbrew using the TUNA mirror configuration.
5. Install shared packages:
   - `git`
   - `curl`
   - `zsh`
   - `neovim`
   - `go`
   - `bat`
   - `eza`
   - `fd`
   - `ripgrep`
   - `fzf`
   - `btop`
   - `zoxide`
   - `jq`
   - `lazygit`
   - `git-delta`
   - `yazi`
   - `zellij`
   - `fnm`
6. Install platform-specific WezTerm and font dependencies.
7. Install `oh-my-zsh`, `powerlevel10k`, and `bun`.
8. Copy `configs/zsh/.zshrc` to `~/.zshrc`.
9. Copy `configs/wezterm/.wezterm.lua` to `~/.wezterm.lua`.
10. Copy `assets/wallpaper.jpg` to `~/.config/terminal-setup/wallpaper.jpg`.
11. Set the default shell to `zsh`.
12. Install Node LTS through `fnm`.
13. Clone or update `https://github.com/yejunyu/mynvim.git` into `~/.config/nvim`.

## Uninstall Flow

`setup.sh uninstall` will be interactive and confirm each destructive group separately.

### Group 1: Brew-managed packages

Remove these packages when the user confirms:

- `wezterm`
- `neovim`
- `go`
- `bat`
- `eza`
- `fd`
- `ripgrep`
- `fzf`
- `btop`
- `zoxide`
- `jq`
- `lazygit`
- `git-delta`
- `yazi`
- `zellij`
- `fnm`

On macOS, also remove the cask-installed WezTerm app. Fonts are never removed.

### Group 2: Shell customizations

When the user confirms:

- delete `~/.oh-my-zsh`
- delete the `powerlevel10k` theme directory if it still exists outside the Oh My Zsh tree
- restore the previous `.zshrc` backup if one exists
- otherwise remove `~/.zshrc`

`zsh` itself remains installed, and the default shell remains `zsh`.

### Group 3: Bun and Node runtime artifacts

When the user confirms:

- uninstall `bun`
- remove `~/.bun`
- remove `~/.local/share/fnm` if present
- remove the installed Node versions managed by `fnm`

### Group 4: WezTerm config

When the user confirms:

- restore the previous `~/.wezterm.lua` backup if one exists
- otherwise remove `~/.wezterm.lua`

The wallpaper file at `~/.config/terminal-setup/wallpaper.jpg` is preserved.

### Group 5: Neovim config

When the user confirms:

- restore the previous `~/.config/nvim` backup if one exists
- otherwise remove `~/.config/nvim`

### Group 6: Homebrew/Linuxbrew

When the user confirms:

- run the official uninstall script for Homebrew/Linuxbrew
- remove the mirror configuration lines that `terminal-setup` added to shell profile files

This group runs last.

## Backup and Restore Model

- Every overwritten file or directory is moved into a timestamped backup directory under `~/.local/state/terminal-setup/backups/<run-id>/`
- The most recent backup is used for interactive uninstall restores
- If no backup exists for a config file, uninstall removes the installed copy instead of restoring

## WezTerm Wallpaper Handling

- The repo stores the wallpaper as `assets/wallpaper.jpg`
- The installed config references `~/.config/terminal-setup/wallpaper.jpg`
- The config should silently skip the background when the file does not exist
- Uninstall never deletes the wallpaper file

## UX and Logging

- Keep the existing `[INFO]`, `[ OK ]`, `[WARN]`, and `[ERR ]` log format
- Add explicit phase messages for `install` and `uninstall`
- Add interactive yes/no prompts during uninstall
- Default failed commands should still stop the script via `set -euo pipefail`

## Test Scope

- Extend the repository smoke test to require `assets/wallpaper.jpg`
- Keep syntax checks for `setup.sh` and `lib/common.sh`
- Add usage assertions so the repo documents and parses the new `install` and `uninstall` subcommands
