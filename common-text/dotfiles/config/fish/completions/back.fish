# If no subcommand has been given, suggest one.
complete -f -c back \
  -n "not string match -qr \"fork|join|ls|kill|peek\" (commandline -cpo)" \
  -a "fork join ls kill peek"

# Suggest job names for subcommands which take an existing job's name.
complete -f -c back \
  -n "string match -qr \"join|kill|peek\" (commandline -cpo)" \
  -a "(back ls)"
