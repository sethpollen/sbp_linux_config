# My personal oh-my-zsh theme.

# Overridable function to set up prompt and title bar before each command.
set_up_terminal() {
  export PROMPT=$(sbp-prompt --format=prompt --exitcode=$?)
  export ZSH_THEME_TERM_TAB_TITLE_IDLE=$(sbp-prompt --format=title --exitcode=$?)
  export ZSH_THEME_TERM_TITLE_ITLE=$ZSH_THEME_TERM_TAB_TITLE_IDLE
}

# Print a bell character. If using the terminator terminal emulator, this should
# cause set the X window's urgency bit.
print_bell() {
  print -n "\a"
}

# When the shell exits, clear the remembered cwd.
clear_cwd_file() {
  rm -f "${HOME}/.cwd"
}

# Register hooks.
autoload -U add-zsh-hook
add-zsh-hook zshexit clear_cwd_file
add-zsh-hook precmd print_bell

# Manually insert set_up_terminal before all other precmd hooks.
add_to_precmd_start() {
  precmd_functions=($* $precmd_functions)
}
add_to_precmd_start set_up_terminal
