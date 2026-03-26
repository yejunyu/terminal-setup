local wezterm = require("wezterm")
local config = wezterm.config_builder and wezterm.config_builder() or {}

local triple = wezterm.target_triple or ""
local is_windows = triple:find("windows") ~= nil
local is_macos = triple:find("darwin") ~= nil
local is_linux = triple:find("linux") ~= nil

-- 1) Base performance and system settings
config.animation_fps = 60
config.max_fps = 120
config.front_end = "WebGpu"

if is_windows then
	config.default_prog = { "wsl.exe" }
elseif is_macos then
	config.default_prog = { "/bin/zsh", "-l" }
elseif is_linux then
	config.default_prog = { "/bin/zsh", "-l" }
end

-- 2) Visual and fonts
config.color_scheme = "Tokyo Night"
config.font = wezterm.font_with_fallback({
	"MartianMono Nerd Font Mono",
	"JetBrainsMono Nerd Font",
	"Cascadia Mono",
	"Noto Sans Mono CJK SC",
})
config.font_size = 15.0
config.line_height = 1.2

-- 3) Window styling
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.8
if is_windows then
	config.win32_system_backdrop = "Acrylic"
end

-- 4) Keybindings
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{ key = "|", mods = "LEADER|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

	{ key = "LeftArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Down") },

	{ key = "LeftArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
	{ key = "RightArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
	{ key = "UpArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
	{ key = "DownArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },
}

-- 5) Wallpaper if present at ~/Pictures/wallpaper.png
local wallpaper = wezterm.home_dir .. "/Pictures/wallpaper.png"
local f = io.open(wallpaper, "rb")
if f then
	f:close()
	config.background = {
		{
			source = { File = wallpaper },
			hsb = { brightness = 0.1 },
			width = "Cover",
			height = "Cover",
		},
	}
end

return config
