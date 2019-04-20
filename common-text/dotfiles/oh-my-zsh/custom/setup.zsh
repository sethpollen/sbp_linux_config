# Extra zsh code to run whenever a new shell opens. This includes some standard
# functions and aliases, as well as a few bits of init logic.

# $PATH should only contain unique entries.
typeset -U path

# A script for examining the source of any executable on the PATH or any
# zsh function.
catwhich() {
  file=$(which "$@")
  if [ -f "$file" ]; then
    cat "$file"
  else
    # Maybe it's a zsh function, in which case 'which' would have printed its
    # source code.
    print "$file"
  fi
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
alias fd..="fd .."
alias ..="fd .."

# Turn on coloring for some commands.
alias ls='ls -h --color=auto'
alias grep='grep --color=auto --line-number'

# Grep recursively in current directory.
grepr() {
  grep -r "$@" .
}

# Move the shell to the last known path.
if [ -e "${HOME}/.cwd" ]; then
  dest="$(cat "${HOME}/.cwd")"
  if [ -d "$dest" ]; then
    cd "$dest"
  fi

  # Clear variables to keep them from cluttering things up.
  unset dest
fi

