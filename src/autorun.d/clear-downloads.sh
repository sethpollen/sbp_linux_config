#!/bin/sh
# Empty out the downloads directory.

DOWNLOADS=~/Downloads
if [ -d "$DOWNLOADS" ]; then
  rm -rf $DOWNLOADS
  mkdir $DOWNLOADS
fi
