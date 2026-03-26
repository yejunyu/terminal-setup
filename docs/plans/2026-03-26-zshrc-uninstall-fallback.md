# Zshrc Uninstall Fallback Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make `setup.sh uninstall` restore a previous `.zshrc` when available and otherwise create a minimal fallback `.zshrc` instead of removing it.

**Architecture:** The change stays local to the shell customization uninstall path. `lib/common.sh` will gain a dedicated helper for `.zshrc` fallback generation and a restore-or-create wrapper, while `setup.sh` will call that wrapper instead of the generic restore-or-remove helper for `.zshrc`.

**Tech Stack:** Bash, zsh, Markdown

---

### Task 1: Add a focused regression test for `.zshrc` fallback behavior

**Files:**
- Create: `tests/test_zshrc_uninstall_fallback.sh`
- Modify: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Create a shell test that:
- sets `HOME` and `XDG_STATE_HOME` to a temporary directory
- sources `lib/common.sh`
- calls a new helper named `restore_or_create_minimal_zshrc`
- verifies backup restore wins when a backup exists
- verifies a minimal `.zshrc` is created when no backup exists

Update the smoke test so it requires:
- `docs/plans/2026-03-26-zshrc-uninstall-fallback-design.md`
- `docs/plans/2026-03-26-zshrc-uninstall-fallback.md`
- `tests/test_zshrc_uninstall_fallback.sh`

**Step 2: Run test to verify it fails**

Run: `bash tests/test_zshrc_uninstall_fallback.sh`
Expected: FAIL because `restore_or_create_minimal_zshrc` does not exist yet.

**Step 3: Write minimal implementation**

Add the helper API and wire it into uninstall.

**Step 4: Run test to verify it passes**

Run: `bash tests/test_zshrc_uninstall_fallback.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/test_zshrc_uninstall_fallback.sh tests/test_repo_layout.sh
git commit -m "test: cover zshrc uninstall fallback"
```

### Task 2: Implement `.zshrc` fallback helpers

**Files:**
- Modify: `lib/common.sh`
- Test: `tests/test_zshrc_uninstall_fallback.sh`

**Step 1: Write the failing test**

Use `tests/test_zshrc_uninstall_fallback.sh` from Task 1.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_zshrc_uninstall_fallback.sh`
Expected: FAIL because the helper is missing or behavior is wrong.

**Step 3: Write minimal implementation**

Add:
- `write_minimal_zshrc`
- `restore_or_create_minimal_zshrc`

The generated file should contain:
- a comment noting `terminal-setup uninstall`
- `autoload -Uz compinit`
- `compinit`
- `PROMPT='%n@%m:%~ %# '`

**Step 4: Run test to verify it passes**

Run: `bash tests/test_zshrc_uninstall_fallback.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/common.sh tests/test_zshrc_uninstall_fallback.sh
git commit -m "feat: add zshrc uninstall fallback"
```

### Task 3: Wire the fallback into uninstall and document it

**Files:**
- Modify: `setup.sh`
- Modify: `README.md`
- Modify: `tests/test_repo_layout.sh`
- Test: `tests/test_repo_layout.sh`
- Test: `tests/test_zshrc_uninstall_fallback.sh`

**Step 1: Write the failing test**

Rely on:
- the focused fallback test
- the smoke test
- README content expectations

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL until README and uninstall flow are updated consistently.

**Step 3: Write minimal implementation**

Update:
- `setup.sh` to call `restore_or_create_minimal_zshrc`
- `README.md` to state uninstall restores the previous `.zshrc` or writes a minimal fallback when none existed
- `tests/test_repo_layout.sh` to keep the new plan/test files in scope

**Step 4: Run test to verify it passes**

Run:
- `bash tests/test_zshrc_uninstall_fallback.sh`
- `bash tests/test_repo_layout.sh`

Expected: PASS

**Step 5: Commit**

```bash
git add setup.sh README.md tests/test_repo_layout.sh
git commit -m "docs: clarify zshrc uninstall fallback"
```
