hl.bind("SUPER + CTRL + ALT + T", hl.dsp.focus({ workspace = "previous" }))

-- Switch workspaces with SUPER + [0-9]
hl.bind("SUPER + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind("SUPER + 2", hl.dsp.exec_cmd("~/archlinux/.config/tmux/bin/open"))
hl.bind("SUPER + 3", hl.dsp.exec_cmd("~/archlinux/.config/tmux/bin/open --term"))
hl.bind("SUPER + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind("SUPER + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind("SUPER + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind("SUPER + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind("SUPER + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind("SUPER + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind("SUPER + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with SUPER + SHIFT + [0-9]
hl.bind("SUPER + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind("SUPER + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind("SUPER + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind("SUPER + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind("SUPER + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind("SUPER + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind("SUPER + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind("SUPER + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind("SUPER + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind("SUPER + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

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
		hl.dispatch(hl.dsp.exec_cmd("~/archlinux/.config/hypr/bin/paste"))
	end
end

hl.bind("SHIFT + CTRL + ALT + SUPER + G", paste_slot(1))
hl.bind("SHIFT + CTRL + ALT + SUPER + H", paste_slot(2))
hl.bind("SHIFT + CTRL + ALT + SUPER + I", paste_slot(3))

hl.bind("SHIFT + CTRL + ALT + SUPER + S", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind("SHIFT + CTRL + ALT + SUPER + O", hl.dsp.exec_cmd("~/archlinux/.local/bin/poweroff"))
hl.bind("SHIFT + CTRL + ALT + SUPER + P", hl.dsp.exec_cmd("~/archlinux/.local/bin/logout"))

hl.bind(
	"SHIFT + CTRL + ALT + SUPER + A",
	hl.dsp.exec_cmd("~/archlinux/.local/bin/clipboard-slime-core --execute --jump")
)
hl.bind("SHIFT + CTRL + ALT + SUPER + B", hl.dsp.exec_cmd("~/archlinux/.local/bin/clipboard-slime-core --execute"))
hl.bind("SHIFT + CTRL + ALT + SUPER + C", hl.dsp.exec_cmd("~/archlinux/.local/bin/clipboard-slime-core --jump"))
hl.bind("SHIFT + CTRL + ALT + SUPER + F", hl.dsp.exec_cmd("~/archlinux/.local/bin/clipboard-run-and-copy"))
hl.bind(
	"SHIFT + CTRL + ALT + SUPER + Q",
	hl.dsp.exec_cmd("~/archlinux/.local/bin/clipboard-slime-core --jump --no-cancel")
)

hl.bind("SHIFT + CTRL + ALT + SUPER + M", hl.dsp.exec_cmd("~/archlinux/.local/bin/toggle-theme"))

hl.bind(
	"SHIFT + CTRL + ALT + SUPER + U",
	hl.dsp.exec_cmd(
		'[float; size 1100 600; center] kitty --config NONE --class kitty-wifi-popup -o remember_window_size=no -o confirm_os_window_close=0 -o font_family="JetBrainsMono Nerd Font" --single-instance --instance-group=wifi-popup sh -c "nmcli device wifi list ; nmtui-connect"'
	)
)
