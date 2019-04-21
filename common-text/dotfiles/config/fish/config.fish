###############################################################################
# Basic setup.

# No greeting.
set fish_greeting

# Start at the most recent pwd, if possible.
if test -f /dev/shm/last-pwd
  cd (cat /dev/shm/last-pwd)
end

# Import my standard environment.
eval (~/bin/sbp-environment --shell_type=fish)

###############################################################################
# File browsing.

function fd
  cd $argv
  and ls
end

function ..
  fd ..
end

function .
  fd .
end

###############################################################################
# Prompt.

# Before displaying each prompt, run all my custom Go logic and dump the
# results in to the fish session's global variable namespace.
function source_sbp_prompt --on-event fish_prompt
  eval (sbp-prompt --exitcode=$status --width=$COLUMNS --shell_type=fish)
end

# Then just export the variables when asked.
function fish_prompt
  echo "$PROMPT"
end

function fish_title
  echo "$TERM_TITLE"
end

# Bell after each command, so that terminator sets the X urgency bit.
function bell_after_command --on-event fish_postexec
  echo -n \a
end

###############################################################################
# Utilities.

function grepr --description "Grep in all files under the current directory" \
    --wraps=grep
  grep -r $argv
end
