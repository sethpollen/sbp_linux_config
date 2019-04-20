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
