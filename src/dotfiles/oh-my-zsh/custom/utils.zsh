# A few useful functions.
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
