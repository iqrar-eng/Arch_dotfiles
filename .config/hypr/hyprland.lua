---------------------
---- MY PROGRAMS ----
---------------------
local my_nvim = " nvim -u ~/dotfiles/.config/nvim/init.lua "
local my_kitty = " kitty --config ~/dotfiles/.config/kitty/default.conf "

local firefox = "firefox"
local nvim = my_kitty .. "--class kitty-nvim" .. my_nvim
local terminal = my_kitty
	.. "--config ~/dotfiles/.config/kitty/terminal.conf --class kitty-terminal sh -c 'tmux attach 2>/dev/null || tmux new-session'"
local clipboard = "copyq --start-server show"
local fileManager = "env YAZI_CONFIG_HOME=/home/iqrar/dotfiles/.config/yazi" .. my_kitty .. "--class kitty-yazi -e yazi"

------------------------
---- RULES ---
------------------------

hl.workspace_rule({ workspace = "1", on_created_empty = firefox })
hl.workspace_rule({ workspace = "2", on_created_empty = nvim })
hl.workspace_rule({ workspace = "3", on_created_empty = terminal })
hl.workspace_rule({ workspace = "4", on_created_empty = clipboard })
hl.workspace_rule({ workspace = "5", on_created_empty = fileManager })

-- No border when only one window is open on a workspace (tiled or floating)
hl.window_rule({ name = "no-border-single-tiled", match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ name = "no-border-single-floating", match = { float = true, workspace = "f[1]" }, border_size = 0 })

-- Always route these apps to their workspace, no matter where they're launched from
hl.window_rule({ name = "firefox-to-ws1", match = { class = "firefox" }, workspace = "1" })
hl.window_rule({ name = "nvim-to-ws2", match = { class = "kitty-nvim" }, workspace = "2" })
hl.window_rule({ name = "terminal-to-ws3", match = { class = "kitty-terminal" }, workspace = "3" })
hl.window_rule({ name = "copyq-to-ws4", match = { class = "com.github.hluk.copyq" }, workspace = "4" })
hl.window_rule({ name = "yazi-to-ws5", match = { class = "kitty-yazi" }, workspace = "5" })

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
	hl.exec_cmd("[workspace 1 silent] " .. firefox)
	hl.exec_cmd("[workspace 2 silent] " .. nvim)
	hl.exec_cmd("[workspace 3 silent] " .. terminal)
	hl.exec_cmd("[workspace 4 silent] " .. clipboard)
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")
hl.env("HYPRLAND_CONFIG", os.getenv("HOME") .. "/dotfiles/.config/hypr/hyprland.lua")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
	},

	decoration = {
		rounding = 0,
		shadow = { enabled = false },
		blur = { enabled = false },
	},

	animations = { enabled = false },

	-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
	dwindle = {
		preserve_split = true, -- You probably want this
		force_split = 2,
	},

	ecosystem = {
		no_donation_nag = true,
	},

	misc = {
		focus_on_activate = true,
		force_default_wallpaper = false,
		disable_splash_rendering = true,
		disable_hyprland_logo = true,
	},

	debug = {
		suppress_errors = true,
	},

	input = {
		sensitivity = 0.7,
		touchpad = {
			natural_scroll = true,
		},
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

---------------------
---- KEYBINDINGS ----
---------------------

hl.bind("SUPER + CTRL + ALT + T", hl.dsp.focus({ workspace = "previous" }))

-- Switch workspaces with SUPER + [0-9]
-- Move active window to a workspace with SUPER + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + A", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + S", hl.dsp.layout("togglesplit")) -- dwindle only

-- Move focus with SUPER + arrow keys
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))

-- Move/resize windows with SUPER + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SHIFT + CTRL + ALT + SUPER + E", hl.dsp.window.fullscreen())

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind(
	"SHIFT + CTRL + ALT + SUPER + R",
	hl.dsp.exec_cmd(
		"grim -t ppm - | satty --filename - --fullscreen --output-filename ~/Pictures/Screenshots/Screenshot_$(date '+%a-%d-%b_%Y%m%d-%H:%M:%S').png"
	)
)

hl.bind("SHIFT + CTRL + ALT + SUPER + T", hl.dsp.exec_cmd("grim - | wl-copy"))
hl.bind("SHIFT + CTRL + ALT + SUPER + N", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))

-- ========================

local function paste_slot(n)
	return function()
		hl.dispatch(hl.dsp.exec_cmd("copyq select " .. n))
		hl.dispatch(hl.dsp.exec_cmd("~/dotfiles/.config/hypr/bin/paste"))
	end
end

hl.bind("SHIFT + CTRL + ALT + SUPER + G", paste_slot(1))
hl.bind("SHIFT + CTRL + ALT + SUPER + H", paste_slot(2))
hl.bind("SHIFT + CTRL + ALT + SUPER + I", paste_slot(3))

hl.bind("SHIFT + CTRL + ALT + SUPER + S", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind("SHIFT + CTRL + ALT + SUPER + O", hl.dsp.exec_cmd("~/dotfiles/.local/bin/poweroff"))
hl.bind("SHIFT + CTRL + ALT + SUPER + P", hl.dsp.exec_cmd("~/dotfiles/.local/bin/logout"))

hl.bind(
	"SHIFT + CTRL + ALT + SUPER + A",
	hl.dsp.exec_cmd("~/dotfiles/.local/bin/clipboard-slime-core --execute --jump")
)
hl.bind("SHIFT + CTRL + ALT + SUPER + B", hl.dsp.exec_cmd("~/dotfiles/.local/bin/clipboard-slime-core --execute"))
hl.bind("SHIFT + CTRL + ALT + SUPER + C", hl.dsp.exec_cmd("~/dotfiles/.local/bin/clipboard-slime-core --jump"))
hl.bind("SHIFT + CTRL + ALT + SUPER + F", hl.dsp.exec_cmd("~/dotfiles/.local/bin/clipboard-run-and-copy"))

hl.bind("SHIFT + CTRL + ALT + SUPER + M", hl.dsp.exec_cmd("~/dotfiles/.local/bin/toggle-theme"))

hl.bind(
	"SHIFT + CTRL + ALT + SUPER + U",
	hl.dsp.exec_cmd(
		'[float; size 1100 600; center] kitty --config NONE --class kitty-wifi-popup -o remember_window_size=no -o confirm_os_window_close=0 -o font_family="JetBrainsMono Nerd Font" --single-instance --instance-group=wifi-popup sh -c "nmcli device wifi list ; nmtui-connect"'
	)
)
