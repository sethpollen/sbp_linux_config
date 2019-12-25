# If no subcommand has been given, suggest one.
complete -f -c back \
  -n "not string match -qr \"ls|fork|peek|join|kill\" (commandline -cpo)" \
  -a "ls fork peek join kill"

# Suggest job names for subcommands which take an existing job's name.
complete -f -c back \
  -n "string match -qr \"peek|join|kill\" (commandline -cpo)" \
  -a "(back ls_nostar)"
