# My personal oh-my-zsh theme.

# Add our own custom precmd script.
pollen_precmd() {
  # Empty (for now!)
}

# Register custom precmd script.
autoload -U add-zsh-hook
add-zsh-hook precmd pollen_precmd

# Function used by the prompt to generate abbreviated PWDs.
short_pwd() {
  local len=50
  local dir=${PWD##*/}
  local len=$(( ( len < ${#dir} ) ? ${#dir} : len ))
  local newPwd=${PWD/#$HOME/\~}
  local offset=$(( ${#newPwd} - len ))
  if [ ${offset} -gt "0" ] ; then
    local newPwd=$newPwd[$offset,9999]
    local newPwd=../${newPwd#*/}
  fi
  print $newPwd
}

# A nice overridable alias. This allows someone to change the definition
# of prompt_pwd but still use the nice short_pwd functionality.
prompt_pwd() {
  short_pwd
}

# Set up the prompt.
local cyan="%{$fg_bold[cyan]%}"
local yellow="%{$fg_bold[yellow]%}"
local red="%{$fg_bold[red]%}"
local noColor="%{$reset_color%}"

local returnCode="%(?..${red}[%?]${nocolor})"

# Use single quotes to defer evaluation.
local pwd='$(prompt_pwd)'

PROMPT="${cyan}%D{%m/%d %H:%M} %m ${pwd} ${returnCode}
${yellow}>${noColor} "
