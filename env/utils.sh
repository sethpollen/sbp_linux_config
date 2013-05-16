###############################################################################
# SHELL VARIABLES
###############################################################################

export EDITOR=vim


###############################################################################
# SHELL PROMPT AND TITLE
###############################################################################

# zsh invokes the precmd function before each prompt.
function precmd {
  ##################################################
  # Fancy PWD display function
  ##################################################
  # The home directory (HOME) is replaced with a ~
  # The last pwdmaxlen characters of the PWD are displayed
  # Leading partial directory names are striped off
  # /home/me/stuff          -> ~/stuff               if USER=me
  # /usr/share/big_dir_name -> ../share/big_dir_name if pwdmaxlen=20
  ##################################################
  # Grab the exit code of the last command before messing it up.
  local EXIT_CODE=$?
  if [ ${EXIT_CODE} -eq "0" ]
  then
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
  
  # For some reason, we need this line to get zsh to recognize the backslash-e escapes.
  PS1=`echo $PS1`

  # Set the xterm title bar to contain hostname and shortened cwd.
  case $TERM in
    xterm*)
        print -Pn "\e]0;%m:${NEW_PWD}\a"
        ;;
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
alias .="pwd"
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


###############################################################################
# UTILITY FUNCTIONS
###############################################################################

# File browsing.
function fd {
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
function kat {
  # Invoke kate in a separate process, and redirect its output
  # streams to /dev/null
  kate $* &> /dev/null &
}

# Opens dolphin (K file browser).
function dolf {
  dolphin . &> /dev/null &
}

# A nice "Where am I?" command.
function pwn {
  pwd
  ls --color=always
}

# Allows inspection of executed commands.
function doo {
  echo $@
  $@
}

# Opens a file using the current desktop's generic opener.
function ope {
  for ARG in $*
  do
    kde-open $ARG &> /dev/null || gnome-open $ARG &> /dev/null
  done
}

function psgrep {
  # Exclude our grep command from the output.
  ps aux | \
    grep -v "grep --color=auto" | \
    grep --color=auto $*
}

# Colorized VCS diffs.
function hgdiff {
  hg diff | colordiff
}
function gitdiff {
  git diff | colordiff
}

# Backs up the home directories to SOLOMON (used to be ZEDEKIAH).
function zedbck {
  # Assemble the destination name for this backup.
  EXTERNAL=SOLOMON
  HOST=`hostname`
  DEST=/media/$EXTERNAL/Backups/$HOST-home-live

  # Source name for the rsync call. Use a trailing slash to copy the contents of /home,
  # not "home" itself.
  SRC=/home/

  echo "Backing up $SRC -> $DEST ..."
  rsync -auv --delete-during --exclude=".cache/" $SRC $DEST
}
