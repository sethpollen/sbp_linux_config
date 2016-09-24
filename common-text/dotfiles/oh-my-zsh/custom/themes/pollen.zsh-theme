# My personal oh-my-zsh theme.

# Sets up prompt and title bar before each command.
set_up_terminal() {
  # Source the environment variables emitted by sbp-prompt.
  . <(sbp-prompt --exitcode="$?" --width="$COLUMNS" --shell_pid="$$")

  export ZSH_THEME_TERM_TAB_TITLE_IDLE="$TERM_TITLE"
  export ZSH_THEME_TERM_TITLE_IDLE="$TERM_TITLE"
}

# Print a bell character. If using the terminator terminal emulator, this should
# cause set the X window's urgency bit.
print_bell() {
  print -n "\a"
}

# Reports to the Conch server that a command is about to start.
on_command_start() {
  # We use the long form of the command.
  command="$3"
  conch_client --shell_pid="$$" --rpc=BeginCommand --command="$command" \
               --pwd="$PWD"
}

# Register hooks.
autoload -U add-zsh-hook
add-zsh-hook precmd print_bell
add-zsh-hook preexec on_command_start

# Manually insert set_up_terminal before all other precmd hooks.
add_to_precmd_start() {
  precmd_functions=($* $precmd_functions)
}
add_to_precmd_start set_up_terminal
