# Extra zsh code to run whenever a new shell opens. This includes some standard
# functions and aliases, as well as a few bits of init logic.

# A few useful functions.
append_to_path() {
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

# File browsing.
alias fd..="fd .."
alias ..="fd .."

# Version control.
alias gitc="git commit --allow-empty-message -a"
alias gits="git status"
alias gitb="git branch"
alias hgc="hg commit"
alias hgs="hg status"
alias hga="hg add"

# Turn on coloring for some commands.
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Some more ls aliases.
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Move the shell to the last known path.
if [ -e ~/.cwd ]; then
  local dest=$(cat ~/.cwd)
  if [ -d "$dest" ]; then
    cd $dest
  fi

  # Clear variables to keep them from cluttering things up.
  unset dest
fi

# Function to switch and save the current path.
cd() {
  builtin cd "$@";
  echo "$PWD" > ~/.cwd;
}
