# My personal oh-my-zsh theme.

clear_cwd_file() {
  # When the shell exits, clear the remembered cwd.
  rm -f ~/.cwd
}

# Prompt colors.
cyan="%{$fg_bold[cyan]%}"
yellow="%{$fg_bold[yellow]%}"
red="%{$fg_bold[red]%}"
white="%{$fg_bold[white]%}"
noColor="%{$reset_color%}"

# Use single quotes when you want to defer evaluation.
prompt_dateTime="${cyan}%D{%m/%d %H:%M}"
prompt_host="${cyan}%m"
prompt_pwd="${cyan}%50<..<%~%<<"
prompt_returnCode="%(?..${red} [%?])"
prompt_arrow="${yellow}>"

# Callable function for making the default prompt.
default_prompt() {
  export PROMPT="${prompt_dateTime} ${prompt_host} ${prompt_pwd}${prompt_returnCode}
${prompt_arrow} ${noColor}"
}

# Make the default prompt.
default_prompt

# Callable function for making the default titlebars.
default_titleBar() {
  local titleBar="%m %50<..<%~%<<"
  export ZSH_THEME_TERM_TAB_TITLE_IDLE=$titleBar
  export ZSH_THEME_TERM_TITLE_IDLE=$titleBar
}

# Make the default titlebars.
default_titleBar

# Register hooks.
autoload -U add-zsh-hook
add-zsh-hook zshexit clear_cwd_file
