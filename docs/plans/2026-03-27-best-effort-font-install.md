# Best-Effort Font Install Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Install macOS font casks one by one so a single font failure only prints a warning and does not abort the rest of the setup flow.

**Architecture:** Keep `brew_install` and `brew_install_casks` strict. Add a dedicated font-cask helper in `lib/common.sh` and call it from the macOS branch in `setup.sh`, while `wezterm` remains a separate strict install.

**Tech Stack:** Bash, Homebrew, Markdown

---

### Task 1: Add a focused test for the font helper contract

**Files:**
- Create: `tests/test_best_effort_font_install.sh`
- Modify: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Create a shell test that:
- sources `lib/common.sh`
- overrides `brew` with a shell function stub
- verifies the new helper:
  - skips already installed fonts
  - continues after a simulated install failure

Update the smoke test so it requires:
- `docs/plans/2026-03-27-best-effort-font-install-design.md`
- `docs/plans/2026-03-27-best-effort-font-install.md`
- `tests/test_best_effort_font_install.sh`

**Step 2: Run test to verify it fails**

Run: `bash tests/test_best_effort_font_install.sh`
Expected: FAIL because the helper does not exist yet.

**Step 3: Write minimal implementation**

Add the helper and wire it into `setup.sh`.

**Step 4: Run test to verify it passes**

Run: `bash tests/test_best_effort_font_install.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/test_best_effort_font_install.sh tests/test_repo_layout.sh
git commit -m "test: cover best effort font install"
```

### Task 2: Implement per-font best-effort install and update docs

**Files:**
- Modify: `lib/common.sh`
- Modify: `setup.sh`
- Modify: `README.md`
- Test: `tests/test_best_effort_font_install.sh`
- Test: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Use the focused helper test and smoke test.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_best_effort_font_install.sh`
Expected: FAIL until the helper and setup flow are updated.

**Step 3: Write minimal implementation**

Add:
- `brew_install_font_casks_best_effort` in `lib/common.sh`

Update:
- `setup.sh` so macOS installs `wezterm` strictly and fonts through the new helper
- `README.md` so it documents the warning-and-continue behavior for fonts

**Step 4: Run test to verify it passes**

Run:
- `bash tests/test_best_effort_font_install.sh`
- `bash tests/test_repo_layout.sh`
- `bash setup.sh --help`

Expected: PASS

**Step 5: Commit**

```bash
git add lib/common.sh setup.sh README.md tests/test_best_effort_font_install.sh tests/test_repo_layout.sh
git commit -m "fix: make font install best effort"
```
