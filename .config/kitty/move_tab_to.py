import os
import glob
import subprocess
from pathlib import Path

home = Path.home()
kitty_dir = home / ".config/kitty"
current = kitty_dir / "current-theme.conf"

resolved = os.path.realpath(current)
uid = os.getuid()

is_dark = "dark" in resolved
next_theme = kitty_dir / "themes" / ("light.conf" if is_dark else "dark.conf")

# Kitty
if current.is_symlink() or current.exists():
    current.unlink()
current.symlink_to(next_theme)

result = subprocess.run(
    ["kitty", "@", "--to", "unix:@mykitty", "load-config"],
    capture_output=True
)
if result.returncode != 0:
    subprocess.run(["pkill", "-USR1", "-x", "kitty"])

# tmux
tmux_bg = "#a6e3a1" if is_dark else "#2e465e"
tmux_fg = "#1e1e2e" if is_dark else "#eff1f5"
subprocess.run(
    ["tmux", "set", "-g", "mode-style", f"bg={tmux_bg}"],
    capture_output=True
)

# GNOME
gnome_scheme = "prefer-light" if is_dark else "prefer-dark"
subprocess.run([
    "gsettings", "set", "org.gnome.desktop.interface",
    "color-scheme", gnome_scheme
])

# CopyQ
copyq_theme = home / ".config/copyq/themes" / ("light.ini" if is_dark else "dark.ini")
subprocess.run(["copyq", "eval", f"loadTheme('{copyq_theme}')"])

# Neovim
scheme = "catppuccin-latte" if is_dark else "catppuccin-mocha"
nvim_state_dir = home / ".local/share/nvim"
nvim_state_dir.mkdir(parents=True, exist_ok=True)
(nvim_state_dir / "colorscheme").write_text(scheme + "\n")

for sock in glob.glob(f"/run/user/{uid}/nvim.*.*"):
    if os.path.exists(sock):
        subprocess.run(
            ["nvim", "--server", sock, "--remote-send", f"<Cmd>colorscheme {scheme}<CR>"],
            capture_output=True
        )import subprocess

def get_indices():
    result = subprocess.run(["tmux", "list-windows", "-F", "#{window_index}"],
                            capture_output=True, text=True)
    return sorted([int(x) for x in result.stdout.strip().split('\n') if x])

def get_current():
    result = subprocess.run(["tmux", "display-message", "-p", "#{window_index}"],
                            capture_output=True, text=True)
    return int(result.stdout.strip())

def main(args):
    indices = get_indices()
    current = get_current()

    if len(args) > 1:
        target = int(args[1])
        # build new order: remove current, insert at target pos
        items = [i for i in indices if i != current]
        items.insert(target - 1, current)

        # step 1: move all to temp high indices, track orig->tmp mapping
        tmp_base = 1000
        orig_to_tmp = {}
        for i, idx in enumerate(indices):
            tmp = tmp_base + i
            subprocess.run(["tmux", "move-window", "-s", str(idx), "-t", str(tmp)])
            orig_to_tmp[idx] = tmp

        # step 2: move from tmp to final positions in new order
        for new_pos, orig_idx in enumerate(items, 1):
            subprocess.run(["tmux", "move-window", "-s", str(orig_to_tmp[orig_idx]), "-t", str(new_pos)])
            subprocess.run(["tmux", "select-window", "-t", str(target)])
    else:
        target = max(indices) + 1
        subprocess.run(["tmux", "move-window", "-t", str(target)])
        subprocess.run(["tmux", "move-window", "-r"])
    return ""

def handle_result(args, answer, target_window_id, boss):
    pass

if __name__ == '__main__':
    import sys
    main(sys.argv)
