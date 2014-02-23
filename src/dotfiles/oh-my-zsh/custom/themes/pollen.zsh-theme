# My personal oh-my-zsh theme.

clear_cwd_file() {
  # When the shell exits, clear the remembered cwd.
  rm -f ~/.cwd
}

# Prompt colors.
cyan="%{$fg_bold[cyan]%}"
yellow="%{$fg_bold[yellow]%}"
magenta="%{$fg_bold[magenta]%}"
red="%{$fg_bold[red]%}"
white="%{$fg_bold[white]%}"
no_color="%{$reset_color%}"

# Prefix with no_color to remove any bolding.
dim_white="${no_color}%{$fg[white]%}"
dim_yellow="${no_color}%{$fg[yellow]%}"

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
  local tilde="~"

  # Parse args.
  local info=
  local pwd="${PWD/${HOME}/${tilde}}"
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
  local short_host="${HOST%%.*}"
  short_host_len="$#short_host"
  short_host="${magenta}${short_host}"

  # If running over SSH, put parentheses around hostname.
  if [ ${SSH_TTY} ]; then
    short_host="${dim_yellow}(${short_host}${dim_yellow})"
    short_host_len="$((2 + short_host_len))"
  fi

  # Automatically include Git branch status in the info, if there is no other
  # info to show.
  if [ -z "$info" ]; then
    info="$(git_info)"

    # If we found some git stuff, note it in the flag and strip the repo path
    # from the PWD.
    if [ ! -z "$info" ]; then
      if [ -z "$flag" ]; then
        flag="git"
      fi

      local full_repo_path="$(git rev-parse --show-toplevel)"
      local tilde_repo_path="~${full_repo_path#${HOME}}"
      local new_pwd="${pwd#${tilde_repo_path}}"
      if [[ "$new_pwd" == "$pwd" ]]; then
        # The tilde path didn't work. Try the full path.
        new_pwd="${pwd#${full_repo_path}}"
      fi

      # Strip leading slashes from the pwd.
      pwd="${new_pwd#/}"

      # If the pwd is empty, make it a slash.
      if [[ -z "$pwd" ]]; then
        pwd="/"
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
  # after the hostname, then the number of characters in the info, then six
  # more for the exit status.
  local pwd_maxlen=$((maxlen - 12 - short_host_len - 1 - $#info - 6))

  # If there isn't enough room to get a good squint at the PWD, just put it
  # on the next line.
  local pwd_prefix=
  if [[ ($pwd_maxlen -lt $#pwd) && ($pwd_maxlen -lt 16) ]]; then
    # The PWD will get a whole line to itself.
    pwd_prefix=$'\n'
    pwd_maxlen=$maxlen
  fi

  if [[ $pwd_maxlen -lt 2 ]]; then
    # We need at least 2 spots for the "..".
    pwd_maxlen=2
  fi

  # Build up the prompt.
  PROMPT="${cyan}%D{%m/%d %H:%M} ${short_host}${cyan} "
  if [ ! -z "$info" ]; then
    PROMPT="${PROMPT}${white}${info}${cyan}"
  fi
  PROMPT="${PROMPT}${pwd_prefix}%${pwd_maxlen}<..<${pwd}%<<%(?.. ${red}[%?])
${yellow}${flag}\$${no_color} "

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
  local tilde="~"

  # Parse args.
  local info=
  local pwd="${PWD/${HOME}/${tilde}}"
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
    # comfortably in tmux.
    maxlen=32
  fi

  # Automatically include Git branch status in the info, if there is no other
  # info to show.
  if [ -z "$info" ]; then
    info="$(git_info)"

    # If we found some git stuff, note it in the flag and strip the repo path
    # from the PWD.
    if [ ! -z "$info" ]; then
      local full_repo_path="$(git rev-parse --show-toplevel)"
      local tilde_repo_path="~${full_repo_path#${HOME}}"
      local new_pwd="${pwd#${tilde_repo_path}}"
      if [[ "$new_pwd" == "$pwd" ]]; then
        # The tilde path didn't work. Try the full path.
        new_pwd="${pwd#${full_repo_path}}"
      fi

      # Strip leading slashes from the pwd.
      pwd="${new_pwd#/}"

      # If the pwd is empty, make it a slash.
      if [[ -z "$pwd" ]]; then
        pwd="/"
      fi
    fi
  fi
  pwd="$(basename ${pwd})"

  # Dress up the info, if we got one.
  if [ ! -z "$info" ]; then
    # Don't add a trailing space; it pollutes my title lines in byobu.
    info="[${info}]"
  fi

  # Compute how much space we have for the PWD. We take off the number of
  # characters in the info.
  local pwd_maxlen=$((maxlen - $#info))
  if [[ $pwd_maxlen -lt 2 ]]; then
    # We need at least 2 spots for the "..".
    pwd_maxlen=2
  fi

  # Build up the title bar string.
  local title_bar=""
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
