# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# [ -f /bin/zsh ] && exec zsh

########################################
# local settings
########################################

[ -f $HOME/.bashrc.local ] && source $HOME/.bashrc.local

########################################
# some normal settings
########################################

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.aliases.sh ]; then
    . ~/.aliases.sh
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

########################################
# PATH
########################################

[ -r $HOME/.local/bin ] && PATH="$PATH:$HOME/.local/bin"

########################################
# sheldon
########################################

# loading plugins with sheldon
# eval "$(sheldon source)"

########################################
# prompt
########################################

if type starship > /dev/null; then
    # starship
    eval "$(starship init bash)"
else
    export PS1="\[\e[46m\]\u|\h\[\e[m\] \[\e[36m\]\w\[\e[m\] \n \$ "

    function __show_status() {
        local status=$(echo ${PIPESTATUS[@]})
        local SETCOLOR_SUCCESS="echo -en \\033[1;32m"
        local SETCOLOR_FAILURE="echo -en \\033[1;31m"
        local SETCOLOR_WARNING="echo -en \\033[1;33m"
        local SETCOLOR_NORMAL="echo -en \\033[0;39m"

        local SETCOLOR s
        for s in ${status}
        do
            if [ ${s} -gt 100 ]; then
                SETCOLOR=${SETCOLOR_FAILURE}
            elif [ ${s} -gt 0 ]; then
                SETCOLOR=${SETCOLOR_WARNING}
            else
                SETCOLOR=${SETCOLOR_SUCCESS}
            fi
        done
        ${SETCOLOR}
        echo "(rc->${status// /|})"
        ${SETCOLOR_NORMAL}
    }
    PROMPT_COMMAND='__show_status;'${PROMPT_COMMAND//__show_status;/}
fi

########################################
# check updates 
########################################

# Fetch updates of this repository on backgound
(cd $HOME/dotfiles && git fetch > /dev/null 2>&1 &) 