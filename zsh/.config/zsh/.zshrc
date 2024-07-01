# Enable colors and change prompt:
autoload -U colors && colors	# Load colors
PS1="%B%F{15}%~%f%b "
setopt autocd		# Automatically cd into typed directory.
stty stop undef		# Disable ctrl-s to freeze terminal.
setopt interactive_comments
LC_CTYPE=en_US.UTF-8
LC_ALL=en_US.UTF-8
# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"

export PATH="/home/aboud/.local/bin:$PATH"

unsetopt PROMPT_SP

# Default programs:
# Change the default crypto/weather monitor sites.
# export CRYPTOURL="rate.sx"
# export WTTRURL="wttr.in"
# ~/ Clean-up:
autoload -Uz compinit; compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char
# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp -uq)"
    trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' HUP INT QUIT TERM PWR EXIT
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' '^uyazi\n'
bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'
bindkey -s '^r' '^ufzf | xargs zathura\n'
bindkey -s '^x' '^unvim /home/aboud/.local/bin/suckless/dwm/config.h\n'
bindkey -s '^h' '^u/home/aboud/.local/bin/scripts/programming/zellij-cht.sh\n'
bindkey -s '^p' '^u/home/aboud/.local/bin/scripts/myaurhelper.sh\n'

bindkey '^[[P' delete-char

export GEMINI_API_KEY="AIzaSyAkLWvM1ij1V5-iqbRRidaCv-qgTOGIjUQ"
# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete

# Load syntax highlighting; should be last.
source /home/aboud/.local/bin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
eval "$(zoxide init zsh)"
# The following lines were added by compinstall
autoload -Uz +X compinit && compinit
autoload -Uz +X bashcompinit && bashcompinit
# End of lines added by compinstall
if [ -z "${PURE_POWER_MODE}" ]; then
  PURE_POWER_MODE=fancy
fi

if autoload -U is-at-least && is-at-least 5.7 && [[ $COLORTERM == (24bit|truecolor) || ${terminfo[colors]} -eq 16777216 ]]; then
    DESERT_NIGHT_PURE_POWER_TRUE_COLOR=true
else
    DESERT_NIGHT_PURE_POWER_TRUE_COLOR=false
fi

if test -z "${ZSH_VERSION}"; then
  echo "purepower: unsupported shell; try zsh instead" >&2
  return 1
  exit 1
fi

() {
  emulate -L zsh && setopt no_unset pipe_fail

  # `$(_pp_c x y`) evaluates to `y` if the terminal supports >= 256 colors and to `x` otherwise.
  zmodload zsh/terminfo
  if (( terminfo[colors] >= 256 )); then
    function _pp_c() { print -nr -- $2 }
  else
    function _pp_c() { print -nr -- $1 }
    typeset -g POWERLEVEL9K_IGNORE_TERM_COLORS=true
  fi

  # `$(_pp_s x y`) evaluates to `x` in portable mode and to `y` in fancy mode.
  if [[ ${PURE_POWER_MODE:-fancy} == fancy || $PURE_POWER_MODE == modern ]]; then
    function _pp_s() { print -nr -- $2 }
  else
    if [[ $PURE_POWER_MODE != portable ]]; then
      echo -En "purepower: invalid mode: ${(qq)PURE_POWER_MODE}; " >&2
      echo -E  "valid options are 'modern', 'fancy' and 'portable'; falling back to 'portable'" >&2
    fi
    function _pp_s() { print -nr -- $1 }
  fi

  typeset -ga POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
      dir vcs)

  typeset -ga POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
      status command_execution_time background_jobs custom_rprompt context)

  local ins=$(_pp_s '>' '❯')
  local cmd=$(_pp_s '<' '❮')

  # typeset -g POWERLEVEL9K_CUSTOM_RPROMPT=custom_rprompt
  # typeset -g POWERLEVEL9K_CUSTOM_RPROMPT_BACKGROUND=none
  # typeset -g POWERLEVEL9K_CUSTOM_RPROMPT_FOREGROUND=$(_pp_c 4 12)

  unfunction _pp_c _pp_s
} "$@"

# bun completions
[ -s "/home/aboud/.bun/_bun" ] && source "/home/aboud/.bun/_bun"
