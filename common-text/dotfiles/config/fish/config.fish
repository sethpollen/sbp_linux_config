###############################################################################
# Basic setup.

# No greeting.
set fish_greeting

# Start at the most recent pwd, if possible.
if test -f /dev/shm/sbp-last-pwd
  set -l dir (cat /dev/shm/sbp-last-pwd)
  if test -d $dir
    cd $dir
  end
end

# Import my standard environment.
set -x -g EDITOR vim
set -x -g TERMINAL terminator
set -x -g MAILDIR $HOME/Maildir
if test -d /usr/games && not contains /usr/games $PATH
  set -x -g PATH $PATH /usr/games
end
if not contains $HOME/bin $PATH
  set -x -g PATH $PATH $HOME/bin
end
# Set a sentinel.
set -x -g SBP_ENVIRONMENT_SOURCE fish

# Brighten this up just a bit. The default is 005fd7
set fish_color_command 0088dd

###############################################################################
# File browsing.

function fd
  if test -d $argv[1]
    cd $argv && ls
  else if test -f $argv[1]
    vim $argv[1]
  else
    return 1
  end
end

function ..
  fd ..
end

function .
  fd .
end

###############################################################################
# Prompt.

function sbp_prompt_wrapper
  sbp_main prompt \
    --mode=fast \
    --exit_code=$status \
    --width=$COLUMNS \
    --fish_pid=(echo %self) \
    $argv
end

function fish_prompt
  sbp_prompt_wrapper --output=fish_prompt
end

function fish_title
  sbp_prompt_wrapper --output=terminal_title
end

function after_command --on-event fish_postexec
  # Bell after each command, so that terminator sets the X urgency bit.
  echo -n \a

  # Clear the prompt info cache, since the command may have changed the PWD
  # or the state of the workspace.
  sbp_main prompt --mode=purge --fish_pid=(echo %self)
end

# Allow background processes to request a redraw of the fish prompt.
function redraw_prompt --on-signal USR1
  if status is-interactive
    commandline -f repaint
  end
end
