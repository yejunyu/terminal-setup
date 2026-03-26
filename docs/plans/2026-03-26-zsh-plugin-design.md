# Zsh Plugin Integration Design

**Date:** 2026-03-26

## Goal

Add `extract`, `zsh-autosuggestions`, and `zsh-syntax-highlighting` to the terminal bootstrap so they are installed, enabled in `.zshrc`, documented, and removed during the shell customization uninstall flow.

## Chosen Approach

- Keep `extract` as an Oh My Zsh built-in plugin and only add it to the `plugins=(...)` list.
- Install `zsh-autosuggestions` and `zsh-syntax-highlighting` by cloning them into `${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins`.
- Use the Gitee remotes provided by the user as the default clone URLs.
- Reuse the existing shell customization uninstall group instead of creating a separate uninstall step.

## Rationale

- This keeps the plugin model aligned with Oh My Zsh conventions.
- The two external plugins stay inside the same `~/.oh-my-zsh` tree that the installer already manages.
- Uninstall remains simple because removing `~/.oh-my-zsh` already removes these plugin directories in the common case, while an explicit helper can still clean them up if needed.

## Install Changes

1. Add plugin remote variables to `lib/common.sh`.
2. Add an `install_zsh_plugins` helper that clone-or-updates:
   - `zsh-autosuggestions`
   - `zsh-syntax-highlighting`
3. Call the helper after `install_oh_my_zsh`.
4. Update `configs/zsh/.zshrc` so `plugins=(...)` becomes:
   - `git`
   - `extract`
   - `zsh-syntax-highlighting`
   - `zsh-autosuggestions`

## Uninstall Changes

1. Add a `remove_zsh_plugins` helper for the two plugin directories under `ZSH_CUSTOM`.
2. Invoke that helper inside the existing shell customization uninstall group.
3. Keep the broader `remove_oh_my_zsh` behavior in place so the final result is unchanged even if the plugin directories are nested under `~/.oh-my-zsh`.

## Docs and Tests

- Update README to mention the extra Zsh plugins in the installed toolset and uninstall behavior.
- Extend the smoke test to assert that `.zshrc` contains `extract`, `zsh-syntax-highlighting`, and `zsh-autosuggestions`.
