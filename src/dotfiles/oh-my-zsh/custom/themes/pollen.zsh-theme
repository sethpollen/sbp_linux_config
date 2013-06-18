# My personal oh-my-zsh theme.

pollen_zshexit() {
  # When the shell exits, clear the remembered cwd.
  rm -f ~/.cwd
}
autoload -U add-zsh-hook
add-zsh-hook zshexit pollen_zshexit

# Function used by the prompt to generate abbreviated PWDs.
# If an argument is supplied, it is used instead of $PWD.
short_pwd() {
  local len=40

  if [ $# -ge 1 ]; then
    local dir=$1
  else
    local dir=${PWD/#$HOME/\~}
  fi

  local len=$(( ( len >= ${#dir} ) ? ${#dir} : len ))
  local offset=$(( ${#dir} - len ))
  if [ ${offset} -gt "0" ]; then
    local dir=$dir[$offset,9999]
    local dir=../${dir#*/}
  fi
  print -n ${dir}
}

# Prompt colors.
cyan="%{$fg_bold[cyan]%}"
yellow="%{$fg_bold[yellow]%}"
red="%{$fg_bold[red]%}"
white="%{$fg_bold[white]%}"
noColor="%{$reset_color%}"

# A nice overridable alias. This allows someone to change the definition
# of prompt_pwd but still use the nice short_pwd functionality.
prompt_pwd() {
  print -n "${cyan}"
  short_pwd
}

# Use single quotes when you want to defer evaluation.
local dateTime="${cyan}%D{%m/%d %H:%M}"
local host="${cyan}%m"
local pwd='$(prompt_pwd)'
local returnCode="%(?..${red}[%?])"
local arrow="${yellow}>"

PROMPT="${dateTime} ${host} ${pwd} ${returnCode}
${arrow} ${noColor}"

# Set xterm titlebars.
ZSH_THEME_TERM_TAB_TITLE_IDLE="%m ${pwd}"
ZSH_THEME_TERM_TITLE_IDLE="%m ${pwd}"
