# terminal-setup

Cross-platform terminal bootstrap for macOS and Linux, built around your current WezTerm config, `zsh + oh-my-zsh + p10k`, and your Neovim repo at `yejunyu/mynvim`.

## Repository Layout

```text
terminal-setup/
├── README.md
├── setup.sh
├── lib/
│   └── common.sh
└── configs/
    ├── wezterm/
    │   └── .wezterm.lua
    └── zsh/
        └── .zshrc
```

```bash
git clone <your-repo-url> terminal-setup
cd terminal-setup
bash setup.sh
```

## What Gets Installed

- Homebrew / Linuxbrew using TUNA mirrors
- WezTerm with your shared `.wezterm.lua`
- Zsh, Oh My Zsh, and powerlevel10k
- Neovim plus your `yejunyu/mynvim` LazyVim config
- Go
- fnm + Node.js LTS
- bun
- Modern CLI tools:
  - bat
  - eza
  - fd
  - ripgrep
  - fzf
  - btop
  - zoxide
  - jq
  - lazygit
  - git-delta
  - yazi
  - zellij

## Notes

- The installer persists TUNA mirror variables for Homebrew in your shell profile files.
- It only updates existing shell profile files; if none exist, it creates `~/.zprofile` instead of creating every possible profile file.
- `HOMEBREW_CORE_GIT_REMOTE` is intentionally not set by default, matching the current TUNA guidance for modern brew installs.
- `setup.sh` detects the operating system with `uname -s` and applies the correct macOS or Linux installation path.
- On Linux, font installation is best-effort: the installer bootstraps the two primary Nerd Fonts first, then warns if you still need extra CJK fallback fonts.
- On first launch after setup, run `p10k configure` to generate your own `~/.p10k.zsh`.

## Linux Preflight

Before running `setup.sh` on Linux, install the Homebrew prerequisites from the official docs.

Debian/Ubuntu:

```bash
sudo apt-get install build-essential procps curl file git
```

Fedora:

```bash
sudo dnf group install development-tools
sudo dnf install procps-ng curl file
```

CentOS Stream / RHEL:

```bash
sudo dnf group install 'Development Tools'
sudo dnf install procps-ng curl file
```

Arch Linux:

```bash
sudo pacman -S base-devel procps-ng curl file git
```

## CLI Cheat Sheet

### Replaced commands

- `ls` -> `eza --icons --group-directories-first`
- `ll` -> `eza -la --icons --group-directories-first`
- `lt` -> `eza --tree --level=2 --icons`
- `cat` -> `bat`
- `find` -> `fd`
- `grep` -> `rg`
- `top` -> `btop`
- `lg` -> `lazygit`
- `zj` -> `zellij`

### Most useful commands

```bash
bat README.md
eza -la --icons
fd tailwind src
rg "TODO|FIXME" .
z code
zi
y
lg
zellij
```

### fzf

- `Ctrl+R`: fuzzy search command history
- `Ctrl+T`: fuzzy search files
- `Alt+C`: fuzzy jump into directories

### yazi

Use the `y` shell function instead of calling `yazi` directly. It syncs the last directory back to your shell:

```bash
y
y ~/Downloads
```

## WezTerm Keybindings

- `Ctrl+q`, then `|`
  Split current pane horizontally
- `Ctrl+q`, then `-`
  Split current pane vertically
- `Alt+Left/Right/Up/Down`
  Move focus between panes
- `Ctrl+q`, then arrow keys
  Resize current pane

## Neovim Quick Commands

- `:Lazy`
  Open plugin manager UI
- `:Lazy sync`
  Install or sync plugins
- `:Lazy update`
  Update plugins
- `:Mason`
  Manage LSPs, formatters, and debuggers
- `:LspInfo`
  Show active LSP clients for current buffer
- `:ConformInfo`
  Show formatter status
- `:checkhealth`
  Run Neovim health checks

Your current LazyVim config already enables:

- `lazyvim.plugins.extras.lang.go`
- `lazyvim.plugins.extras.lang.typescript`
- `lazyvim.plugins.extras.lang.tailwind`

That means Go, TS/TSX, and Tailwind support are already wired on the Neovim side; the main remaining job is installing the external toolchains.

## Go Development Environment

The setup scripts install `go` via Homebrew/Linuxbrew.

Verify:

```bash
go version
```

Create a minimal Go project:

```bash
mkdir hello-go
cd hello-go
go mod init example/hello-go
cat > main.go <<'EOF'
package main

import "fmt"

func main() {
    fmt.Println("hello go")
}
EOF

go run .
```

Open it in Neovim:

```bash
nvim main.go
```

Then check:

```vim
:checkhealth
:Mason
:LspInfo
```

If `gopls` is missing, install it from `:Mason`.

## React + TSX + Tailwind Development Environment

The setup scripts install Node LTS via `fnm`, so you can start a React + TypeScript project with Vite immediately.

Create the project:

```bash
npm create vite@latest my-react-app -- --template react-ts
cd my-react-app
npm install
```

Add Tailwind using the current Vite plugin flow:

```bash
npm install tailwindcss @tailwindcss/vite
```

Update `vite.config.ts`:

```ts
import { defineConfig } from "vite"
import react from "@vitejs/plugin-react"
import tailwindcss from "@tailwindcss/vite"

export default defineConfig({
  plugins: [react(), tailwindcss()],
})
```

Import Tailwind in `src/index.css`:

```css
@import "tailwindcss";
```

Start the dev server:

```bash
npm run dev
```

Open the app code:

```bash
nvim src/App.tsx
```

Then check:

```vim
:checkhealth
:Mason
:LspInfo
```

If TypeScript or Tailwind language servers are missing, install them from `:Mason`.

## Bun

The setup scripts install bun with its official installer.

Basic checks:

```bash
bun --version
bun install
bun run dev
```
