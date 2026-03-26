# Zsh Plugin Integration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Install and enable `extract`, `zsh-autosuggestions`, and `zsh-syntax-highlighting` as part of the terminal bootstrap, and remove the external plugin directories during shell customization uninstall.

**Architecture:** The existing shell setup flow will stay centered on Oh My Zsh. `extract` is enabled only through `.zshrc`, while the two external plugins are managed by new helper functions in `lib/common.sh` and invoked from the existing install/uninstall phases in `setup.sh`.

**Tech Stack:** Bash, Oh My Zsh, zsh, Markdown

---

### Task 1: Extend the smoke test for the plugin contract

**Files:**
- Modify: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Add assertions so the smoke test fails unless:
- `.zshrc` contains `extract`
- `.zshrc` contains `zsh-syntax-highlighting`
- `.zshrc` contains `zsh-autosuggestions`
- `README.md` mentions `zsh-syntax-highlighting`
- `README.md` mentions `zsh-autosuggestions`

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL because the current `.zshrc` and README do not contain those plugin names.

**Step 3: Write minimal implementation**

Update `.zshrc` and `README.md` until the assertions pass.

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add tests/test_repo_layout.sh configs/zsh/.zshrc README.md
git commit -m "test: cover zsh plugin setup"
```

### Task 2: Add plugin install and uninstall helpers

**Files:**
- Modify: `lib/common.sh`
- Test: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Use the existing `bash -n lib/common.sh` smoke test and the README/config content assertions.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL until helper changes are applied cleanly and syntax remains valid.

**Step 3: Write minimal implementation**

Add:
- `ZSH_AUTOSUGGESTIONS_REMOTE`
- `ZSH_SYNTAX_HIGHLIGHTING_REMOTE`
- `install_zsh_plugin`
- `install_zsh_plugins`
- `remove_zsh_plugins`

Use the user-provided Gitee remotes as defaults.

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add lib/common.sh
git commit -m "feat: manage zsh plugins"
```

### Task 3: Wire plugin management into install and uninstall

**Files:**
- Modify: `setup.sh`
- Modify: `README.md`
- Test: `tests/test_repo_layout.sh`

**Step 1: Write the failing test**

Rely on the updated smoke test and syntax checks.

**Step 2: Run test to verify it fails**

Run: `bash tests/test_repo_layout.sh`
Expected: FAIL until the install flow calls the plugin helper and the uninstall docs match the behavior.

**Step 3: Write minimal implementation**

Update:
- `setup.sh install` to call `install_zsh_plugins` after `install_oh_my_zsh`
- `setup.sh uninstall` shell customization step to call `remove_zsh_plugins`
- `README.md` to mention the two installed plugins and that shell customization uninstall removes them

**Step 4: Run test to verify it passes**

Run: `bash tests/test_repo_layout.sh`
Expected: PASS

**Step 5: Commit**

```bash
git add setup.sh README.md
git commit -m "feat: wire zsh plugins into setup flow"
```
