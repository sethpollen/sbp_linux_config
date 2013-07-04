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
no_color="%{$reset_color%}"

# Produces the info string to insert into the prompt when inside a git repo.
git_info() {
  local str="$(git_prompt_info)"
  if [ ! -z "$str" ]; then
    # We are actually in git. Grab the name of the repo.
    repo="$(git rev-parse --show-toplevel)"
    if [ ! -z "${repo}" ]; then
      # Basename gets mad if you call it with an empty string.
      repo="$(basename ${repo})"
    fi

    # Check if the repo name is the same as the branch name. The branch name
    # is the first part of $str.
    if [ "${str##${repo}}" = "${str}" ]; then
      # The repo name is not redundant, so include it.
      str="${repo}: ${str}"
    fi
  fi
  print -n "$str"
}

# Standard function for building prompt strings. The result is exported to the
# PROMPT variable.
# Arguments:
#   --maxlen=INTEGER
#       Specifies the maximum number of characters for the resulting string.
#       The PWD may be truncated to make it fit, but no other truncation
#       efforts will occur. Defaults to $COLUMNS.
#   --info=STRING
#       Optionally provides an info string to print before the PWD. If this is
#       non-empty, it will be surrounded by square brackets and printed out
#       in white.
#   --pwd=STRING
#       Optionally specifies the string to print as the PWD. If omitted, the
#       complete current PWD is used.
#   --flag=STRING
#       A short string to put before the ">" prompt.
build_prompt() {
  # Parse args.
  local info=
  local pwd="${PWD/${HOME}/\~"
  local maxlen=
  local flag=
  for arg in "$@"; do
    case "$arg" in
      --maxlen=*)
        maxlen="${arg#--maxlen=}" ;;
      --info=*)
        info="${arg#--info=}" ;;
      --pwd=*)
        pwd="${arg#--pwd=}" ;;
      --flag=*)
        flag="${arg#--flag=}" ;;
    esac
  done

  # Check if we need a default maxlen.
  if [ -z "$maxlen" ]; then
    if [ $COLUMNS ]; then
      maxlen="$COLUMNS"
    else
      maxlen=9999
    fi
  fi

  # Make sure we know our hostname.
  if [ -z "$HOST" ]; then
    export HOST="$(hostname)"
  fi

  # Automatically include Git branch status in the info, if there is no other
  # info to show.
  if [ -z "$info" ]; then
    info="$(git_info)"

    # If we found some git stuff, note it in the flag.
    if [ ! -z "$info" ]; then
      if [ -z "$flag" ]; then
        flag="git"
      fi
    fi
  fi

  # Dress up the info, if we got one.
  if [ ! -z "$info" ]; then
    # Add a trailing space to set it off from the PWD.
    info="[${info}] "
  fi

  # Compute how much space we have for the PWD. We take off 12 for the date
  # and time, then the number of characters in the hostname, 1 for the space
  # after the hostname, then the number of characters in the info, then four
  # more for the exit status.
  local pwd_maxlen=$((maxlen - 12 - $#HOST - 1 - $#info - 4))
  if [[ $pwd_maxlen -lt 2 ]]; then
    # We need at least 2 spots for the "..".
    pwd_maxlen=2
  fi

  # Build up the prompt.
  PROMPT="${cyan}%D{%m/%d %H:%M} %m "
  if [ ! -z "$info" ]; then
    PROMPT="${PROMPT}${white}${info}${cyan}"
  fi
  PROMPT="${PROMPT}%${pwd_maxlen}<..<${pwd}%<<%(?.. ${red}[%?])
${yellow}${flag}>${no_color} "

  # Make sure the PROMPT variableis are exported to the outer ZSH environment.
  export PROMPT
}

# Standard function for building titlebar strings. The result is exported to the
# appropriate oh-my-zsh variables.
# Arguments:
#   --maxlen=INTEGER
#       Specifies the maximum number of characters for the resulting string.
#       The PWD may be truncated to make it fit, but no other truncation
#       efforts will occur.
#   --info=STRING
#       Optionally provides an info string to print before the PWD. If this is
#       non-empty, it will be surrounded by square brackets.
#   --pwd=STRING
#       Optionally specifies the string to print as the PWD. If omitted, the
#       complete current PWD is used.
build_title_bar() {
  # Parse args.
  local info=
  local pwd="%~"
  local maxlen=
  for arg in "$@"; do
    case "$arg" in
      --maxlen=*)
        maxlen="${arg#--maxlen=}" ;;
      --info=*)
        info="${arg#--info=}" ;;
      --pwd=*)
        pwd="${arg#--pwd=}" ;;
    esac
  done

  # Check if we need a default maxlen.
  if [ -z "$maxlen" ]; then
    # Pick a reasonable value. Hopefully this allows 3 or 4 titlebars to fit
    # comfortably across the top of the screen.
    maxlen=90
  fi

  # Make sure we know our hostname.
  if [ -z "$HOST" ]; then
    export HOST="$(hostname)"
  fi

  # Automatically include Git branch status in the info, if there is no other
  # info to show.
  if [ -z "$info" ]; then
    info="$(git_info)"
  fi

  # Dress up the info, if we got one.
  if [ ! -z "$info" ]; then
    # Add a trailing space to set it off from the PWD.
    info="[${info}] "
  fi

  # Compute how much space we have for the PWD. We take off the number of
  # characters in the hostname, 1 for the space after the hostname, then
  # the number of characters in the info.
  local pwd_maxlen=$((maxlen - $#HOST - 1 - $#info))
  if [[ $pwd_maxlen -lt 2 ]]; then
    # We need at least 2 spots for the "..".
    pwd_maxlen=2
  fi

  # Build up the title bar string.
  local title_bar="%m "
  if [ ! -z "$info" ]; then
    title_bar="${title_bar}${info}"
  fi
  title_bar="${title_bar}%${pwd_maxlen}<..<${pwd}%<<"

  # Export to oh-my-zsh.
  export ZSH_THEME_TERM_TAB_TITLE_IDLE=$title_bar
  export ZSH_THEME_TERM_TITLE_IDLE=$title_bar
}

# Overridable function to set up prompt and title bar before each command.
set_up_terminal() {
  build_prompt
  build_title_bar
}

# Configure the gitfast plugin, which supplies git_prompt_info.
ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
GIT_PS1_SHOWDIRTYSTATE="yes"

# Register hooks.
autoload -U add-zsh-hook
add-zsh-hook zshexit clear_cwd_file

# Manually insert set_up_terminal before all other precmd hooks.
add_to_precmd_start() {
  precmd_functions=($* $precmd_functions)
}

add_to_precmd_start set_up_terminal
