---------------------
---- MY PROGRAMS ----
---------------------

local firefox = "firefox"
local nvim = "kitty ~/archlinux/.config/tmux/bin/open"
local clipboard = "copyq --start-server show"
local fileManager = "~/archlinux/.config/yazi/bin/open"

------------------------
---- RULES ---
------------------------

hl.workspace_rule({ workspace = "1", on_created_empty = firefox })
hl.workspace_rule({ workspace = "2", on_created_empty = nvim })
hl.workspace_rule({ workspace = "4", on_created_empty = clipboard })
hl.workspace_rule({ workspace = "5", on_created_empty = fileManager })

-- No border when only one window is open on a workspace (tiled or floating)
hl.window_rule({ name = "no-border-single-tiled", match = { float = false, workspace = "w[tv1]" }, border_size = 0 })
hl.window_rule({ name = "no-border-single-floating", match = { float = true, workspace = "f[1]" }, border_size = 0 })

-- Always route these apps to their workspace, no matter where they're launched from
hl.window_rule({ name = "firefox-to-ws1", match = { class = "firefox" }, workspace = "1" })
hl.window_rule({ name = "nvim-to-ws2", match = { class = "kitty-nvim" }, workspace = "2" })
hl.window_rule({ name = "yazi-to-ws5", match = { class = "kitty-yazi" }, workspace = "5" })

-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
	hl.exec_cmd("trash-empty -f 30")
	hl.exec_cmd("[workspace 1 silent] " .. firefox)
	hl.exec_cmd("[workspace 2 silent] " .. nvim)
	hl.exec_cmd("[workspace 4 silent] " .. clipboard)
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "20")

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
		force_default_wallpaper = false,
		disable_splash_rendering = true,
		disable_hyprland_logo = true,
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

require("bind")
