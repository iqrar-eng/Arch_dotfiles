#
# ~/.bash_profile
#
[[ -f ~/.bashrc ]] && . ~/.bashrc

export HYPRLAND_CONFIG=$HOME/dotfiles/.config/hypr/hyprland.lua

if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec uwsm start hyprland.desktop
fi
