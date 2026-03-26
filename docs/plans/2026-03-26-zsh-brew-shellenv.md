# Zsh Brew Shellenv Bootstrap Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Ensure the generated `.zshrc` bootstraps Homebrew/Linuxbrew PATH in non-login `zsh` shells before aliases and plugins use brew-installed commands.

**Architecture:** Keep install order unchanged and fix the shell startup contract instead. Add a static shellenv block to `configs/zsh/.zshrc`, document the behavior in the README, and add a focused test that asserts the block exists before aliases.

**Tech Stack:** Bash, zsh, Markdown

---

### Task 1: Add a focused `.zshrc` shellenv regression test

**Files:**
- Create: `tests/test_zshrc_brew_shellenv.sh`
- Modify: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Create a shell test that:
- checks `configs/zsh/.zshrc` contains `brew shellenv`
- checks the first `brew shellenv` line appears before the first `alias ls=` line

Update the smoke test so it requires:
- `docs/plans/2026-03-26-zsh-brew-shellenv-design.md`
- `docs/plans/2026-03-26-zsh-brew-shellenv.md`
- `tests/test_zshrc_brew_shellenv.sh`

**Step 2: Run test to verify it fails**

Run: `bash tests/test_zshrc_brew_shellenv.sh`
Expected: FAIL because `.zshrc` does not contain the shellenv block yet.

**Step 3: Write minimal implementation**

Add the shellenv block and the new test file references.

**Step 4: Run test to verify it passes**

Run: `bash tests/test_zshrc_brew_shellenv.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/test_zshrc_brew_shellenv.sh tests/test_repo_layout.sh
git commit -m "test: cover zsh brew shellenv bootstrap"
```

### Task 2: Implement shellenv bootstrap and update docs

**Files:**
- Modify: `configs/zsh/.zshrc`
- Modify: `README.md`
- Test: `tests/test_zshrc_brew_shellenv.sh`
- Test: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Use `tests/test_zshrc_brew_shellenv.sh` plus the smoke test.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_zshrc_brew_shellenv.sh`
Expected: FAIL until `.zshrc` contains the block in the right location.

**Step 3: Write minimal implementation**

Add the Homebrew/Linuxbrew shellenv block near the top of `.zshrc`, before plugin loading and aliases. Update README to mention that non-login `zsh` shells get brew-installed commands without relying on `.zprofile`.

**Step 4: Run test to verify it passes**

Run:
- `bash tests/test_zshrc_brew_shellenv.sh`
- `bash tests/test_repo_layout.sh`
- `zsh -n configs/zsh/.zshrc`

Expected: PASS

**Step 5: Commit**

```bash
git add configs/zsh/.zshrc README.md tests/test_repo_layout.sh tests/test_zshrc_brew_shellenv.sh
git commit -m "fix: bootstrap brew env in zshrc"
```
