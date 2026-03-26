# Terminal Setup Install/Uninstall Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add explicit `install` and `uninstall` subcommands, ship the WezTerm wallpaper in the repository, and implement an interactive uninstall flow that preserves fonts, wallpaper, and `zsh`.

**Architecture:** `setup.sh` will become a thin command dispatcher that selects `install` or `uninstall`, detects the current OS, and calls shared helpers in `lib/common.sh`. Shared helpers will handle backup discovery, prompt/confirm flows, package uninstall steps, wallpaper installation, and restore/remove behavior for `.zshrc`, `.wezterm.lua`, and the Neovim config.

**Tech Stack:** Bash, Homebrew/Linuxbrew, WezTerm, Zsh, Oh My Zsh, powerlevel10k, Markdown

---

### Task 1: Extend the smoke test for the new repository contract

**Files:**
- Modify: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Extend the smoke test so it requires:
- `assets/wallpaper.jpg`
- `docs/plans/2026-03-26-terminal-setup-uninstall-design.md`
- `docs/plans/2026-03-26-terminal-setup-uninstall.md`

Add content assertions with `grep -q` so the test fails unless:
- `setup.sh` mentions `install` and `uninstall`
- `configs/wezterm/.wezterm.lua` mentions `wallpaper.jpg`
- `README.md` mentions `bash setup.sh install`
- `README.md` mentions `bash setup.sh uninstall`

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL because the repo does not yet contain the wallpaper asset or the new command/doc references.

**Step 3: Write minimal implementation**

Create the wallpaper asset entry and update files until the smoke test expectations are satisfiable.

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/test_repo_layout.sh README.md configs/wezterm/.wezterm.lua assets/wallpaper.jpg docs/plans/2026-03-26-terminal-setup-uninstall.md
git commit -m "test: cover install uninstall repo contract"
```

### Task 2: Refactor shared helpers for subcommands, wallpaper install, and restore support

**Files:**
- Modify: `lib/common.sh`
- Test: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Rely on `bash -n lib/common.sh` from the smoke test and the content assertions from Task 1.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL after Task 1 until the helper API and syntax are updated.

**Step 3: Write minimal implementation**

Add helpers for:
- `usage`
- `copy_wallpaper`
- `find_latest_backup_dir`
- `restore_or_remove_path`
- `confirm_action`
- `brew_uninstall_formulae`
- `brew_uninstall_casks`
- `remove_oh_my_zsh`
- `remove_bun_runtime`
- `remove_fnm_runtime`
- `remove_terminal_setup_brew_profile_block`
- `uninstall_homebrew`

Keep the existing logging format and reuse the timestamped backup directory model.

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/common.sh tests/test_repo_layout.sh
git commit -m "feat: add uninstall helpers"
```

### Task 3: Convert `setup.sh` into an `install`/`uninstall` dispatcher

**Files:**
- Modify: `setup.sh`
- Test: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Use the new smoke test assertions that require `setup.sh` to mention both subcommands.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL until `setup.sh` supports `install` and `uninstall`.

**Step 3: Write minimal implementation**

Implement:
- argument parsing with `install`, `uninstall`, and usage output
- a shared package list
- `run_install` for the existing bootstrap flow
- `run_uninstall` for the interactive grouped removal flow
- OS-specific uninstall branches for formulae/casks versus Linuxbrew formulae

Ensure uninstall:
- preserves `zsh`
- preserves fonts
- preserves wallpaper
- leaves the default shell as `zsh`

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add setup.sh tests/test_repo_layout.sh
git commit -m "feat: add install and uninstall commands"
```

### Task 4: Update the WezTerm config to use the installed wallpaper path

**Files:**
- Modify: `configs/wezterm/.wezterm.lua`
- Test: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Rely on the smoke test assertion that expects `wallpaper.jpg` to appear in the WezTerm config.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL until the wallpaper reference changes.

**Step 3: Write minimal implementation**

Change the wallpaper lookup path to:

```lua
wezterm.home_dir .. "/.config/terminal-setup/wallpaper.jpg"
```

Keep the config resilient when the file is absent.

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add configs/wezterm/.wezterm.lua tests/test_repo_layout.sh
git commit -m "feat: use managed wezterm wallpaper path"
```

### Task 5: Update README for the new command model and uninstall behavior

**Files:**
- Modify: `README.md`
- Test: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Use the new smoke test assertions that require install and uninstall usage lines in the README.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL until the README documents the new commands.

**Step 3: Write minimal implementation**

Document:
- `bash setup.sh install`
- `bash setup.sh uninstall`
- what uninstall removes
- what uninstall preserves
- wallpaper handling
- the first-run `p10k configure` step

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add README.md tests/test_repo_layout.sh
git commit -m "docs: add uninstall usage"
```
