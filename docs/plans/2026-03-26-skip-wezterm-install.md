# Skip WezTerm Install Flag Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add `--skip-wezterm-install` to `setup.sh install` so server environments can skip the `brew install wezterm` step while keeping the rest of the setup flow unchanged.

**Architecture:** `setup.sh` will parse install-time flags before running `run_install`. The WezTerm package install branches on one boolean, while the existing config copy, wallpaper copy, font handling, and uninstall flow stay unchanged.

**Tech Stack:** Bash, Homebrew/Linuxbrew, Markdown

---

### Task 1: Extend the smoke test for the new install flag

**Files:**
- Modify: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Add assertions so the smoke test fails unless:
- `setup.sh` contains `--skip-wezterm-install`
- `README.md` contains `--skip-wezterm-install`
- `docs/plans/2026-03-26-skip-wezterm-install-design.md` exists
- `docs/plans/2026-03-26-skip-wezterm-install.md` exists

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL because the current script and README do not mention the flag yet.

**Step 3: Write minimal implementation**

Update the usage text and README so the assertions can pass.

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/test_repo_layout.sh README.md setup.sh docs/plans/2026-03-26-skip-wezterm-install.md
git commit -m "test: cover skip wezterm install flag"
```

### Task 2: Implement argument parsing and conditional WezTerm package install

**Files:**
- Modify: `setup.sh`
- Test: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Use the smoke test from Task 1 plus `bash setup.sh --help` verification.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL until `setup.sh` parses and documents the flag correctly.

**Step 3: Write minimal implementation**

Add:
- an install flag parser for `--skip-wezterm-install`
- a boolean such as `SKIP_WEZTERM_INSTALL=0`
- conditional package installation:
  - macOS skips only the `wezterm` cask and still installs fonts
  - Linux skips only `brew install wezterm` and still runs font bootstrap

**Step 4: Run test to verify it passes**

Run:
- `bash tests/test_repo_layout.sh`
- `bash setup.sh --help`

Expected: PASS

**Step 5: Commit**

```bash
git add setup.sh tests/test_repo_layout.sh README.md
git commit -m "feat: add skip wezterm install flag"
```
