# Reset PATH in tmux to break inheritance chain, causing duplicate 'echo $PATH' entries
if [ -n "$TMUX" ]; then
  export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
fi

[[ $- == *i* ]] && source -- /usr/share/blesh/ble.sh --attach=none

# Helper to add to PATH only if not already present
pathadd() {
  [[ ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
}
pathadd "$HOME/bin"
pathadd "$HOME/.local/bin"
pathadd "$HOME/.npm-global/bin"
pathadd "$HOME/go/bin"
pathadd "$HOME/.local/share/nvim/mason/bin"

# NVM — only once
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

HISTSIZE=10000
shopt -s histappend
shopt -s autocd
shopt -s dotglob
shopt -s cdspell

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
export VISUAL=nvim
export SUDO_EDITOR=nvim

set -o vi

if [ -f /usr/share/bash-completion/bash_completion ]; then
  source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

alias ls='ls --color=always -A --group-directories-first'

source <(fzf --bash)
export FZF_DEFAULT_OPTS="
--height 100%
--history=$HOME/.fzf_history
--filepath-word
--border none
--preview-window 'top:70%:noborder'
--preview 'if [[ -d {} ]]; then ls -1 --color=always {}; else cat {}; fi' \
--bind 'focus:transform:([[ -d {} ]] || [[ -r {} ]]) && echo show-preview || echo hide-preview'
--no-separator
--ansi
--info inline-right
--multi
--cycle
--scrollbar='█'
--layout=reverse
--walker-skip .git,node_modules,target
--bind 'ctrl-^:execute-silent(realpath -- {} | wl-copy)'
--bind 'ctrl-k:execute-silent(realpath -- {} | sed \"s|^$HOME|~|\" | wl-copy)'
--bind 'ctrl-]:execute-silent(printf %s {+} | wl-copy)'
--bind 'alt-x:forward-word'
--bind 'alt-e:backward-word'
--bind 'ctrl-alt-shift-left:forward-subword'
--bind 'alt-g:backward-subword'
--bind 'ctrl-alt-shift-up:kill-word'
--bind 'ctrl-y:backward-kill-word'
--bind 'ctrl-alt-e:kill-subword'
--bind 'ctrl-alt-h:backward-kill-subword'
--bind 'shift-end:kill-line'
--bind 'ctrl-alt-shift-page-down:toggle-all'
--bind 'ctrl-r:toggle-preview'
--bind 'ctrl-f:preview-page-down'
--bind 'ctrl-l:preview-page-up'
--bind 'ctrl-p:preview-top'
--bind 'ctrl-o:preview-bottom'
--bind 'ctrl-home:first'
--bind 'ctrl-end:last'
--bind 'ctrl-up:prev-history'
--bind 'ctrl-down:next-history'
--bind 'ctrl-alt-shift-home:execute(/home/iqrar/dotfiles/.config/scripts/tmux/vim-fzf-focus {})'
"
export FZF_CTRL_R_OPTS="--no-preview"

eval "$(starship init bash)"
eval "$(zoxide init bash --cmd cd)"

[[ ! ${BLE_VERSION-} ]] || ble-attach
