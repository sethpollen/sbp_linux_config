#!/bin/sh
# This script provides a standard installation of sbp-linux-config through
# the following steps:
#   1. It copies everything from ./src to ./bin.
#   2. It makes several symlinks in standard places (such as ~) that point
#      to the appropriate files in ./bin.
#   3. If arguments are provided, each is interpreted as a directory which
#      may contain zero or more subdirectories corresponding to the
#      subdirectories of ./src. Each file in each of these directires is
#      read in and appended to the corresponding file in ./bin. If no such
#      file exists yet in ./bin, it is created with the appended contents.
#      This provides a simple mechanism for adding per-machine customizations.

SBP_LINUX_CONFIG=~/sbp-linux-config
SRC=$SBP_LINUX_CONFIG/src
BIN=$SBP_LINUX_CONFIG/bin

# Clean out any existing bin stuff.
if [ -e "$BIN" ]; then
  rm -rf $BIN
fi

# Perform the copy.
cp -r $SRC $BIN

# Create all the symlinks, using this nice function:
make_link() {
  TARGET=`realpath $1`
  NAME=$2
  echo Linking $TARGET as $NAME ...
  ln --symbolic --force --no-target-directory $TARGET $NAME
}

# Link in all the dotfiles.
DOTFILES_TARGET_DIR=$BIN/dotfiles/
for TARGET in $DOTFILES_TARGET_DIR* ; do
  NAME=$(echo $TARGET | sed "s|$DOTFILES_TARGET_DIR|$HOME/.|")
  make_link $TARGET $NAME
done

# Link in all the other scripts that should be on the path.
make_link $BIN/scripts ~/bin

# Process arguments to see if they contain append-files.
for APPEND_DIR in "$@" ; do
  if [ -d "$APPEND_DIR" ]; then
    # We have a directory to search for append-files.
    for APPEND_FILE in $(cd $APPEND_DIR && find * -type f) ; do
      # APPEND_FILE should be a valid path if we start from $APPEND_DIR
      # or $BIN.
      APPEND_SRC=$APPEND_DIR/$APPEND_FILE
      APPEND_DEST=$BIN/$APPEND_FILE
      
      if [ -e "$APPEND_DEST" ]; then
	echo "Appending $APPEND_SRC to $APPEND_DEST ..."

	# Append a blank line to make sure the contents are well separated.
	echo >> $APPEND_DEST
        
        # Now append the new contents.
        cat $APPEND_SRC >> $APPEND_DEST
      else
	echo "Copying $APPEND_SRC to $APPEND_DEST ..."

        # Just copy the file over.
        cp $APPEND_SRC $APPEND_DEST
      fi
    done
  else
    echo "ERROR: $APPEND_DIR is not a directory."
  fi
done
