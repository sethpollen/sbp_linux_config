# Extra zsh code to run whenever a new shell opens. This includes some standard
# functions and aliases, as well as a few bits of init logic.

# $PATH should only contain unique entries.
typeset -U path

append_to_path() {
  if [ -d "$1" ]; then
    path+=("$1")
  fi
}

# Make sure our PATH is set up properly. This should be unnecessary, since we
# put what we wanted in /etc/environment. But it looks like this line might
# be necessary when we SSH into a machine. Either way, it won't hurt. Note that
# we put ~/bin at the front of $PATH, so our custom scripts override default
# binaries.
path=("$HOME/bin" "$path[@]")
export PYTHONPATH="$HOME/python:$PYTHONPATH"

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
  dest=$(cat ~/.cwd)
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
