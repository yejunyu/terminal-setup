# Terminal Setup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a repository-style cross-platform terminal bootstrap project with a single OS-detecting entry script, shared configs, and documentation for the user's WezTerm, Zsh, and Neovim setup.

**Architecture:** The repository uses a single platform-detecting entry script that sources shared logic from `lib/common.sh`. Shared configuration files live under `configs/`, while tests validate the expected repository layout and shell script syntax. Neovim configuration is installed by cloning `yejunyu/mynvim` instead of vendoring it into this repository.

**Tech Stack:** Bash, Homebrew/Linuxbrew, WezTerm, Zsh, Oh My Zsh, powerlevel10k, LazyVim, Markdown

---

### Task 1: Create repository smoke test

**Files:**
- Create: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Write a shell smoke test that requires these files to exist:
- `setup.sh`
- `lib/common.sh`
- `configs/zsh/.zshrc`
- `configs/wezterm/.wezterm.lua`
- `README.md`

The test must also run `bash -n` against `setup.sh` and `lib/common.sh`.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL because the repository files do not exist yet.

**Step 3: Write minimal implementation**

Create the missing repository files with valid shell syntax and placeholder content where needed.

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/test_repo_layout.sh
git commit -m "test: add terminal setup repository smoke test"
```

### Task 2: Implement shared Homebrew/bootstrap logic

**Files:**
- Create: `lib/common.sh`
- Test: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Extend the smoke test expectations to ensure `lib/common.sh` stays parseable with `bash -n`.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL until `lib/common.sh` exists and parses.

**Step 3: Write minimal implementation**

Implement reusable helpers for:
- logging
- backup/copy behavior
- Homebrew/Linuxbrew install with TUNA mirrors
- package installation helpers
- Oh My Zsh and powerlevel10k install helpers
- `fnm`/Node install
- Neovim repo bootstrap

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/common.sh tests/test_repo_layout.sh
git commit -m "feat: add shared bootstrap helpers"
```

### Task 3: Implement unified entry script

**Files:**
- Create: `setup.sh`
- Test: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Rely on the smoke test's `bash -n` checks for both entry scripts.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL until both scripts exist and parse.

**Step 3: Write minimal implementation**

Implement a single `setup.sh` that:
- detects macOS vs Linux with `uname`
- runs the macOS flow with cask-based WezTerm/font install
- runs the Linux flow with Linuxbrew WezTerm install and best-effort font bootstrap
- shares the common package install list including Go, Neovim, `fnm`, `bun`, and CLI tools

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add setup.sh tests/test_repo_layout.sh
git commit -m "feat: add unified setup entrypoint"
```

### Task 4: Add shared Zsh and WezTerm configs

**Files:**
- Create: `configs/zsh/.zshrc`
- Create: `configs/wezterm/.wezterm.lua`
- Test: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Keep the smoke test file existence checks for both config files.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL until both config files exist.

**Step 3: Write minimal implementation**

Add:
- Zsh config for Oh My Zsh, powerlevel10k, `fzf`, `zoxide`, `fnm`, `bun`, aliases, and `yazi`
- WezTerm config copied from the user's current `~/.wezterm.lua`

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add configs/zsh/.zshrc configs/wezterm/.wezterm.lua
git commit -m "feat: add shared shell and wezterm configs"
```

### Task 5: Write README documentation

**Files:**
- Create: `README.md`
- Test: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Use the smoke test's README existence check.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL until `README.md` exists.

**Step 3: Write minimal implementation**

Document:
- repository structure
- install commands
- tool list
- WezTerm keybindings
- common Neovim commands
- Go setup example
- React TSX + Tailwind setup example

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add README.md
git commit -m "docs: add terminal setup readme"
```
