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
eval (~/bin/sbp-environment)

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

function fish_prompt
  sbp-prompt --exit_code=$status --width=$COLUMNS --output=fish_prompt
end

function fish_title
  sbp-prompt --exit_code=$status --width=$COLUMNS --output=terminal_title
end

# Bell after each command, so that terminator sets the X urgency bit.
function bell_after_command --on-event fish_postexec
  echo -n \a
end
