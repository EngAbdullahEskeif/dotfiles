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

alias openfoam='source /home/aboud/.local/OpenFOAM-v2312/OpenFOAM-v2312/etc/bashrc'
alias ls='exa'
alias grep='grep -i --color=auto'
alias rm='rm --interactive --verbose'
alias mv='mv --interactive --verbose'
alias cp='cp --verbose'
alias cd='z'
alias fman='compgen -c | fzf | xargs man'
alias vim="nvim"
alias ros="distrobox enter ubuntuforros"
alias vpnon="sudo protonvpn connect -f"
alias vpnoff="sudo protonvpn disconnect"
alias androidon="aft-mtp-mount /home/aboud/personal/mnt/android/"
alias androidoff="sudo umount /home/aboud/personal/mnt/android/"
alias refresh="cd /home/aboud/.local/bin/dwl/ && sudo make clean install"
alias \
	ka="killall" \
	g="git" \
	v="$EDITOR" \
	p="pacman" \
#export PATH="/home/aboud/.local/bin:$PATH"
#export PATH="/home/aboud/.scripts/:$PATH"
#export PATH="/usr/local/bin:$PATH"
#export PATH="/usr/bin:$PATH" export PATH="/bin:$PATH"
#export PATH="/usr/sbin:$PATH"
#export PATH="/sbin/:$PATH"
# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

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
bindkey -s '^z' '^uzellij attach Main\n'
bindkey -s '^h' '^u/home/aboud/.local/bin/scripts/programming/zellij-cht.sh\n'

bindkey -s '^x' '^unvim /home/aboud/.local/bin/dwl/config.h\n'


bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'

bindkey '^[[P' delete-char

export GEMINI_API_KEY="AIzaSyAkLWvM1ij1V5-iqbRRidaCv-qgTOGIjUQ"
# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete

# Load syntax highlighting; should be last.
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null
source /home/aboud/.local/bin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export BEMENU_OPTS='--fb "#1e1e2e" --ff "#cdd6f4" --nb "#1e1e2e" --nf "#cdd6f4" --tb "#1e1e2e" --hb "#1e1e2e" --tf "#f38ba8" --hf "#f9e2af" --af "#cdd6f4" --ab "#1e1e2e"'
eval "$(zoxide init zsh)"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

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
  if (( ${PURE_POWER_USE_P10K_EXTENSIONS:-1} )); then
    local p="\${\${\${KEYMAP:-0}:#vicmd}:+${${ins//\\/\\\\}//\}/\\\}}}"
    p+="\${\${\$((!\${#\${KEYMAP:-0}:#vicmd})):#0}:+${${cmd//\\/\\\\}//\}/\\\}}}"
  else
    p=$ins
  fi
  if [[ "$DESERT_NIGHT_PURE_POWER_TRUE_COLOR" == "true" ]]; then
    local ok="%F{#d3c6aa}${p}%f"
    local err="%F{#e67e80}${p}%f"
  else
    local ok="%F{$(_pp_s 007 223)}${p}%f"
    local err="%F{$(_pp_s 001 167)}${p}%f"
  fi

  if (( ${PURE_POWER_USE_P10K_EXTENSIONS:-1} )); then
    typeset -g POWERLEVEL9K_SHOW_RULER=true
    typeset -g POWERLEVEL9K_RULER_CHAR=$(_pp_s '-' '─')
    typeset -g POWERLEVEL9K_RULER_BACKGROUND=none
    if [[ "$DESERT_NIGHT_PURE_POWER_TRUE_COLOR" == "true" ]]; then
      typeset -g POWERLEVEL9K_RULER_FOREGROUND='#596763'
    else
      typeset -g POWERLEVEL9K_RULER_FOREGROUND=$(_pp_c 7 240)
    fi
  else
    typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
    function custom_rprompt() { }
  fi

  typeset -g POWERLEVEL9K_LEFT_SEGMENT_END_SEPARATOR=
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  typeset -g POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%(?.$ok.$err) "

  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
  typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_WHITESPACE_BETWEEN_{LEFT,RIGHT}_SEGMENTS=

  typeset -g POWERLEVEL9K_DIR_{ETC,HOME,HOME_SUBFOLDER,DEFAULT,NOT_WRITABLE}_BACKGROUND=none
  typeset -g POWERLEVEL9K_{ETC,FOLDER,HOME,HOME_SUB}_ICON=
  if [[ "$DESERT_NIGHT_PURE_POWER_TRUE_COLOR" == "true" ]]; then
    typeset -g POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_VISUAL_IDENTIFIER_COLOR='#e69875'
  else
    typeset -g POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_VISUAL_IDENTIFIER_COLOR=$(_pp_c 003 208)
  fi
  if [[ "$PURE_POWER_MODE" == "modern" ]]; then
    typeset -g POWERLEVEL9K_LOCK_ICON=''
  else
    typeset -g POWERLEVEL9K_LOCK_ICON=
  fi
  if [[ "$DESERT_NIGHT_PURE_POWER_TRUE_COLOR" == "true" ]]; then
    typeset -g POWERLEVEL9K_DIR_{ETC,DEFAULT}_FOREGROUND='#83c092'
    typeset -g POWERLEVEL9K_DIR_{HOME,HOME_SUBFOLDER}_FOREGROUND='#a7c080'
    typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_FOREGROUND='#e67e80'
  else
    typeset -g POWERLEVEL9K_DIR_{ETC,DEFAULT}_FOREGROUND=$(_pp_c 006 108)
    typeset -g POWERLEVEL9K_DIR_{HOME,HOME_SUBFOLDER}_FOREGROUND=$(_pp_c 010 142)
    typeset -g POWERLEVEL9K_DIR_NOT_WRITABLE_FOREGROUND=$(_pp_c 009 167)
  fi

  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED,LOADING}_BACKGROUND=none
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED}_MAX_NUM=99
  if [[ "$DESERT_NIGHT_PURE_POWER_TRUE_COLOR" == "true" ]]; then
    typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#7fbbb3'
    typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#dbbc7f'
    typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#d699b6'
    typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND='#859289'
  else
    typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=$(_pp_c 004 109)
    typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=$(_pp_c 011 214)
    typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=$(_pp_c 005 175)
    typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=$(_pp_c 007 245)
  fi
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_UNTRACKEDFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_UNSTAGEDFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_MODIFIED_FOREGROUND
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_STAGEDFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_MODIFIED_FOREGROUND
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_INCOMING_CHANGESFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_CLEAN_FOREGROUND
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_OUTGOING_CHANGESFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_CLEAN_FOREGROUND
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_STASHFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_CLEAN_FOREGROUND
  typeset -g POWERLEVEL9K_VCS_{CLEAN,UNTRACKED,MODIFIED}_ACTIONFORMAT_FOREGROUND=001
  typeset -g POWERLEVEL9K_VCS_LOADING_ACTIONFORMAT_FOREGROUND=$POWERLEVEL9K_VCS_LOADING_FOREGROUND
  if [[ "$PURE_POWER_MODE" == "modern" ]]; then
    typeset -g POWERLEVEL9K_VCS_GIT_ICON=''
    typeset -g POWERLEVEL9K_VCS_GIT_GITHUB_ICON=''
    typeset -g POWERLEVEL9K_VCS_GIT_GITLAB_ICON=''
    typeset -g POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON=''
    typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
    typeset -g POWERLEVEL9K_VCS_REMOTE_BRANCH_ICON=' '
    typeset -g POWERLEVEL9K_VCS_COMMIT_ICON=' '
    typeset -g POWERLEVEL9K_VCS_STAGED_ICON=' '
    typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON=' '
    typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='✩'
    typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON='⇣'
    typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON='⇡'
    typeset -g POWERLEVEL9K_VCS_STASH_ICON='*'
    typeset -g POWERLEVEL9K_VCS_TAG_ICON=' '
  else
    typeset -g POWERLEVEL9K_VCS_{GIT,GIT_GITHUB,GIT_BITBUCKET,GIT_GITLAB,BRANCH}_ICON=
    typeset -g POWERLEVEL9K_VCS_REMOTE_BRANCH_ICON=$'%{\b|%}'
    typeset -g POWERLEVEL9K_VCS_COMMIT_ICON='@'
    typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
    typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='!'
    typeset -g POWERLEVEL9K_VCS_STAGED_ICON='+'
    typeset -g POWERLEVEL9K_VCS_INCOMING_CHANGES_ICON=$(_pp_s '<' '⇣')
    typeset -g POWERLEVEL9K_VCS_OUTGOING_CHANGES_ICON=$(_pp_s '>' '⇡')
    typeset -g POWERLEVEL9K_VCS_STASH_ICON='*'
    typeset -g POWERLEVEL9K_VCS_TAG_ICON=$'%{\b#%}'
  fi

  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_BACKGROUND=none
  if [[ "$DESERT_NIGHT_PURE_POWER_TRUE_COLOR" == "true" ]]; then
    typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#e67e80'
  else
    typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND=$(_pp_c 001 167)
  fi
  typeset -g POWERLEVEL9K_CARRIAGE_RETURN_ICON=

  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_BACKGROUND=none
  if [[ "$DESERT_NIGHT_PURE_POWER_TRUE_COLOR" == "true" ]]; then
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#859289'
  else
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=$(_pp_c 008 246)
  fi
  typeset -g POWERLEVEL9K_EXECUTION_TIME_ICON=

  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,ROOT,REMOTE_SUDO,REMOTE,SUDO}_BACKGROUND=none
  if [[ "$DESERT_NIGHT_PURE_POWER_TRUE_COLOR" == "true" ]]; then
    typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,REMOTE_SUDO,REMOTE,SUDO}_FOREGROUND='#e69875'
    typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND='#e67e80'
  else
    typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,REMOTE_SUDO,REMOTE,SUDO}_FOREGROUND=$(_pp_c 003 208)
    typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND=$(_pp_c 001 167)
  fi

  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_BACKGROUND=none
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VISUAL_IDENTIFIER_COLOR=2
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_ICON=$(_pp_s '%%' '⇶')

  # typeset -g POWERLEVEL9K_CUSTOM_RPROMPT=custom_rprompt
  # typeset -g POWERLEVEL9K_CUSTOM_RPROMPT_BACKGROUND=none
  # typeset -g POWERLEVEL9K_CUSTOM_RPROMPT_FOREGROUND=$(_pp_c 4 12)

  unfunction _pp_c _pp_s
} "$@"
