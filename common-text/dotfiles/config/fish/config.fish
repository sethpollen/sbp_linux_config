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

function fish_prompt
  # TODO:
  echo "WIP "
end
