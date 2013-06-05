###############################################################################
# SHELL VARIABLES
###############################################################################

# We used to define some standard shell variables here (like $EDITOR), but we
# found that it's much better to put these in /etc/environment, where they will
# be available to all programs, not just to zsh instances.

###############################################################################
# SHELL PROMPT AND TITLE
###############################################################################

# zsh invokes the precmd function before each prompt.
precmd() {
  # Fancy PWD display function:
  # The home directory (HOME) is replaced with a ~.
  # The last pwdmaxlen characters of the PWD are displayed.
  # Leading partial directory names are striped off:
  # /home/me/stuff          -> ~/stuff               if USER=me
  # /usr/share/big_dir_name -> ../share/big_dir_name if pwdmaxlen=20

  # Grab the exit code of the last command before messing it up.
  local EXIT_CODE=$?
  if [ ${EXIT_CODE} -eq "0" ]; then
    # Don't show zero exit codes.
    EXIT_CODE=
  else
    # Wrap exit codes in brackets.
    EXIT_CODE="[${EXIT_CODE}]"
  fi
  
  # How many characters of the $PWD should be kept
  local pwdmaxlen=50
  # Indicate that there has been dir truncation
  local trunc_symbol=".."
  local dir=${PWD##*/}
  local pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
  NEW_PWD=${PWD/#$HOME/\~}
  local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))
  if [ ${pwdoffset} -gt "0" ]
  then
    if [ $ZSH_NAME ]; then
      # zsh uses a different syntax for grabbing substrings.
      NEW_PWD=$NEW_PWD[$pwdoffset,9999]
    else
      NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
    fi
    NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
  fi
  
  local PROMPT_DOLLAR_COLOR="1;33m" # Yellow.
  local EXIT_CODE_COLOR="\e[1;31m" # Red.
  local COMMAND_COLOR="0m"

  # Set up command prompt line.
  if [ $ZSH_NAME ]; then
    local PROMPT_COLOR="1;36m" # Cyan for zsh.
    PS1="\e[$PROMPT_COLOR%D{%m/%d %H:%M} %m ${NEW_PWD} ${EXIT_CODE_COLOR}${EXIT_CODE}\n\e[${PROMPT_DOLLAR_COLOR}z> \e[$COMMAND_COLOR"
  else # It must be bash.
    local PROMPT_COLOR="1;31m" # Red for bash.
    PS1="\e[$PROMPT_COLOR\D{%m/%d %H:%M} \h \${NEW_PWD} ${EXIT_CODE_COLOR}${EXIT_CODE}\n\e[${PROMPT_DOLLAR_COLOR}b> \e[$COMMAND_COLOR"
  fi
  
  # For some reason, we need this line to get zsh to recognize the
  # backslash-e escapes.
  PS1=$(echo $PS1)

  # Set the xterm title bar to contain hostname and shortened cwd.
  case "$TERM" in
    xterm*)
      if [ $ZSH_NAME ]; then
        print -Pn "\e]0;%m: ${NEW_PWD}\a"
      fi ;;
  esac
}

# Bash doesn't use precmd; it instead uses the PROMPT_COMMAND variable.
PROMPT_COMMAND=precmd


###############################################################################
# ALIASES
###############################################################################

# Some nice shortcuts.
alias fd..="fd .."
alias ..="fd .."
alias gist="git status"
alias gibt="git branch"

# Turn on coloring for some commands.
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Some more ls aliases.
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Command-line aliases for DE functionality.
alias i3lock="i3lock -c 000000"
alias i3suspend="sudo pm-suspend && i3lock"
alias i3shutdown="sudo shutdown -h -P now"
alias i3restart="sudo shutdown -r now"
alias i3logout="i3-msg exit"


###############################################################################
# UTILITY FUNCTIONS
###############################################################################

append_to_path() {
  # This works in zsh and bash.
  export PATH="$PATH:$1"
}

# File browsing.
fd() {
  if [ $# -ge 1 ]; then
    if [ -f "$1" ]; then
      vim "$1"
    fi
    if [ -d "$1" ]; then
      cd "$1"
      ls --color=always
    fi
  else
    ls --color=always
  fi
}

# Asynchronously opens the K Advanced Text Editor.
kat() {
  # Invoke kate in a separate process, and redirect its output
  # streams to /dev/null
  kate $* &> /dev/null &
}

# Opens dolphin (K file browser).
dolf() {
  dolphin . &> /dev/null &
}

# Colorized VCS diffs.
hgdiff() {
  hg diff | colordiff
}
gitdiff() {
  git diff | colordiff
}

