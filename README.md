# terminal-setup

用于在新环境快速搭建开发环境的安装脚本，支持三种平台：

- macOS：使用 Homebrew。
- Ubuntu：使用 Linuxbrew/Homebrew。
- WSL Ubuntu：使用 Ubuntu `apt` 准备系统依赖，再使用 Linuxbrew/Homebrew 安装开发工具。

脚本会安装并配置 Zsh、Oh My Zsh、powerlevel10k、Neovim、Go、Node.js LTS、pnpm、bun 以及常用 CLI 工具。

## 快速开始

### 1. 获取仓库

把 `<your-repo-url>` 替换成这个仓库的实际地址：

```bash
git clone <your-repo-url> ~/terminal-setup
cd ~/terminal-setup
```

### 2. 运行安装

根据当前环境选择一条命令：

macOS：

```bash
bash setup.sh install
```

Ubuntu/Linux：

```bash
bash setup.sh install
```

WSL Ubuntu：

```bash
bash setup.sh install
```

脚本会根据 `uname -s` 和 WSL 环境标识自动选择对应流程，不需要手动指定平台。

如果服务器不需要安装 Linux WezTerm，可以使用：

```bash
bash setup.sh install --skip-wezterm-install
```

### 3. 使配置立即生效

安装结束后，在当前终端执行：

```bash
exec zsh
p10k configure
```

验证主要工具：

```bash
echo "$SHELL"
zsh --version
go version
node --version
pnpm --version
bun --version
nvim --version
```

首次打开 Neovim：

```bash
nvim
```

等待插件自动安装完成，然后在 Neovim 中执行 `:checkhealth` 检查环境。

安装器会将普通的 Neovim 复制操作（例如 `y`、`yy`）同步到系统剪贴板：macOS 使用 `pbcopy`，WSL 使用 Windows 的 `clip.exe`。因此可直接在宿主应用中粘贴。

## WSL 安装

WSL 中的 Linux 用户空间和 Windows 桌面是两个环境。脚本在 WSL 内使用 Linuxbrew/Homebrew 安装开发工具；WezTerm 应用和字体安装在 Windows 侧。

### Windows 侧：安装 WSL 和 WezTerm

在 PowerShell 中安装 Ubuntu WSL：

```powershell
wsl --install -d Ubuntu
```

然后安装 Windows 版 WezTerm，并把仓库中的配置复制到：

```text
%USERPROFILE%\.wezterm.lua
```

配置默认启动用户为 `yjy`。如果你的 WSL 用户不是 `yjy`，编辑 `.wezterm.lua`，把：

```lua
config.default_prog = { "wsl.exe", "-u", "yjy" }
```

改成你的用户名。如果使用的不是默认发行版，加入发行版名称：

```lua
config.default_prog = { "wsl.exe", "-d", "Ubuntu", "-u", "你的用户名" }
```

字体需要单独安装在 Windows 中。请打开 [Maple Mono NF CN](https://github.com/subframe7536/maple-font) 的 GitHub 页面，在 Releases 下载并安装 `font-maple-mono-nf-cn` 对应的字体包。WSL 脚本不会安装 Linux 字体。

### WSL 侧：安装开发环境

进入 Ubuntu WSL 后执行：

```bash
sudo apt update
sudo apt install -y ca-certificates curl git
git clone <your-repo-url> ~/terminal-setup
cd ~/terminal-setup
bash setup.sh install
```

WSL 流程会：

- 使用 `apt` 安装 Linuxbrew 所需的系统编译依赖。
- 使用 Linuxbrew 安装 Zsh、Neovim、Go、fnm 和 CLI 工具，和普通 Linux 的工具版本保持一致。
- 安装 fnm、Node.js LTS、pnpm 和 bun。
- 安装 Oh My Zsh、插件、powerlevel10k 和 Neovim 配置。
- 不修改 WSL 内的 `~/.wezterm.lua`，不安装 Linux 字体。

完成后执行：

```bash
exec zsh
p10k configure
nvim
```

完全退出并重启 Windows WezTerm，打开后验证：

```bash
whoami
```

应该显示你在 WSL 中创建的 Linux 用户名。

## Ubuntu/Linux 前置依赖

WSL Ubuntu 和普通 Linux 都使用 Linuxbrew。WSL 运行脚本前只需要先准备仓库下载所需的 `curl`、`git` 和 `sudo`，脚本会自动安装 Linuxbrew 前置依赖：

```bash
sudo apt-get update
sudo apt-get install -y build-essential procps curl file git
```

Fedora：

```bash
sudo dnf group install development-tools
sudo dnf install procps-ng curl file
```

Arch Linux：

```bash
sudo pacman -S base-devel procps-ng curl file git
```

## macOS 前置依赖

先安装 Xcode Command Line Tools：

```bash
xcode-select --install
```

然后执行：

```bash
git clone <your-repo-url> ~/terminal-setup
cd ~/terminal-setup
bash setup.sh install
```

脚本会安装 Homebrew、开发工具、Codex cask 和 Maple Mono NF CN 字体。macOS 和普通 Linux 使用 Homebrew cask `font-maple-mono-nf-cn` 安装；字体安装失败只会显示警告，不会中断整个流程。

## 仓库结构

```text
terminal-setup/
├── README.md
├── assets/
│   └── wallpaper.jpg
├── setup.sh
├── docs/
│   └── plans/
│       ├── 2026-03-26-terminal-setup-uninstall-design.md
│       └── 2026-03-26-terminal-setup-uninstall.md
├── lib/
│   └── common.sh
└── configs/
    ├── wezterm/
    │   └── .wezterm.lua
    └── zsh/
        └── .zshrc
```

## 安装参数

只支持以下命令：

```bash
bash setup.sh install
bash setup.sh install --skip-wezterm-install
bash setup.sh uninstall
bash setup.sh --help
```

`--skip-wezterm-install` 只跳过 macOS/Linux 中 WezTerm 的包安装，不影响其他开发工具安装。WSL 本身不会安装 Linux WezTerm。

Go 代理默认配置为 `https://goproxy.cn,direct`。如需修改，在安装命令前设置环境变量：

```bash
GO111MODULE_VALUE=on \
GOPROXY_VALUE=https://proxy.golang.org,direct \
bash setup.sh install
```

## 卸载

```bash
bash setup.sh uninstall
```

卸载过程会逐项询问。WSL 中通过 `apt` 安装的系统依赖不会自动删除；如果需要删除它们，请使用 Ubuntu 自己的 `apt remove`。

查看命令帮助：

```bash
bash setup.sh --help
```

## What Gets Installed

- Homebrew on macOS and Linux/WSL
- The shared WezTerm config at `~/.wezterm.lua` (WezTerm itself is installed manually)
- Homebrew cask: Codex (`brew install --cask codex`) on macOS; Linux/WSL uses Homebrew formulae and does not install Linux casks
- Managed WezTerm wallpaper at `~/.config/terminal-setup/wallpaper.jpg`
- Zsh, Oh My Zsh, and powerlevel10k
- Oh My Zsh plugins: `extract`, `zsh-autosuggestions`, `zsh-syntax-highlighting`
- Neovim plus your `yejunyu/mynvim` LazyVim config
- Go
- fnm + Node.js LTS
- pnpm installed globally through npm
- bun
- Modern CLI tools:
  - tree-sitter
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
- `setup.sh install` detects the operating system with `uname -s` and applies the correct macOS or Linux installation path.
- The installer does not install or uninstall WezTerm; it assumes WezTerm is installed manually and only manages its config file.
- On macOS, font casks are installed one by one. If a single font is already present or its install fails, the installer prints a warning and continues.
- `setup.sh uninstall` is interactive. It can remove WezTerm config, Neovim config, shell customizations, `bun`, `fnm`, Node runtimes, and brew-managed tools. WSL Ubuntu system packages are left in place.
- The shell setup enables `extract`, `zsh-autosuggestions`, and `zsh-syntax-highlighting`.
- The generated `.zshrc` bootstraps Homebrew/Linuxbrew `shellenv` where brew is used, so brew-installed commands are available even in non-login `zsh` shells. It also adds the WSL fnm directory to `PATH`.
- Uninstall preserves `zsh`, fonts, and the wallpaper file.
- When uninstall removes shell customizations, it restores your previous `.zshrc` if one was backed up; otherwise it writes a minimal fallback `.zshrc`.
- On Linux, font installation is best-effort: the installer bootstraps the two primary Nerd Fonts first, then warns if you still need extra CJK fallback fonts.
- On first launch after setup, run `p10k configure` to generate your own `~/.p10k.zsh`.
- During install, the wallpaper from `assets/wallpaper.jpg` is copied to `~/.config/terminal-setup/wallpaper.jpg`.
- On WSL, the installer uses Ubuntu `apt` only for system prerequisites, then installs development tools through Linuxbrew/Homebrew.
- On Linux, the installer installs Homebrew formulae `unzip` and `fontconfig`; macOS uses its separate Xcode Command Line Tools check.
- On WSL, the installer leaves `~/.wezterm.lua` and Linux fonts untouched. Install Windows WezTerm and fonts on Windows instead.

## 卸载行为

`bash setup.sh uninstall` confirms each group separately:

- brew-managed packages on macOS/Linux/WSL
- shell customizations: `oh-my-zsh`, `powerlevel10k`, `zsh-autosuggestions`, `zsh-syntax-highlighting`, and `.zshrc`
  If there was no pre-install `.zshrc` backup, uninstall writes a minimal fallback `.zshrc` instead of leaving the file absent.
- runtimes: `bun`, `fnm`, and installed Node versions
- WezTerm config: `~/.wezterm.lua`
- Neovim config: `~/.config/nvim`
- Homebrew/Linuxbrew itself on macOS/Linux/WSL; WSL keeps Ubuntu's system packages

What it keeps:

- `zsh`
- fonts
- `~/.config/terminal-setup/wallpaper.jpg`

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

The setup scripts install `go` via Homebrew/Linuxbrew on macOS/Linux/WSL.
During install, they also run:

```bash
go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
```

You can override these defaults before install:

```bash
GO111MODULE_VALUE=on GOPROXY_VALUE=https://goproxy.cn,direct bash setup.sh install
```

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

The setup scripts install Node LTS via `fnm` and install `pnpm` globally, so you can start a React + TypeScript project with Vite immediately.

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
