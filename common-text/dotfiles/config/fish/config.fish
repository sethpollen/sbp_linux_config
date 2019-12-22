###############################################################################
# Basic setup.

# No greeting.
set fish_greeting

# Start at the most recent pwd, if possible.
if test -f /dev/shm/last-pwd
  set -l dir (cat /dev/shm/last-pwd)
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
if not contains $HOME/python $PYTHONPATH
  set -x -g PYTHONPATH $PYTHONPATH $HOME/python
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
  sbp-prompt \
    --exit_code=$status --width=$COLUMNS \
    --back_ls_top=(back ls | head -n 1) \
    $argv
end

function fish_prompt
  sbp_prompt_wrapper --output=fish_prompt
end

function fish_title
  sbp_prompt_wrapper --output=terminal_title
end

# Bell after each command, so that terminator sets the X urgency bit.
function bell_after_command --on-event fish_postexec
  echo -n \a
end

# Allow background processes to request a redraw of the fish prompt.
function redraw_prompt --on-signal USR1
  commandline -f repaint
end
