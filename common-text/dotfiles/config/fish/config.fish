# No greeting.
set fish_greeting

# Start at the most recent pwd, if possible.
if test -f /dev/shm/last-pwd
  cd (cat /dev/shm/last-pwd)
end

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
