#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Prefixes each i3status line with some custom information. Adapted from
#   http://code.stapelberg.de/git/i3status/tree/contrib/wrapper.py
#
# To use it, ensure your ~/.i3status.conf contains this line:
#     output_format = "i3bar"
# in the 'general' section.
# Then, in the 'bar' section of your ~/.i3/config, use:
#     status_command i3status | i3status-wrapper.py

import sys
import json
from backlight import Backlight

light = Backlight()


def printLine(message):
  """ Non-buffered printing to stdout. """
  sys.stdout.write(message + '\n')
  sys.stdout.flush()


def readLine():
  """ Interrupted respecting reader for stdin. """
  # Try reading a line, removing any extra whitespace.
  try:
      line = sys.stdin.readline().strip()
      # i3status sends EOF, or an empty line
      if not line:
          sys.exit(3)
      return line
  # Exit on ctrl-c.
  except KeyboardInterrupt:
      sys.exit()


if __name__ == '__main__':
  # Skip the first line which contains the version header.
  printLine(readLine())
  
  # The second line contains the start of the infinite array.
  printLine(readLine())

  while True:
    prefix, line = '', readLine()
    
    # Ignore comma at start of lines.
    if line.startswith(','):
      prefix, line = ',', line[1:]

    j = json.loads(line)
    
    # Insert information into the start of the json. For brightness, only
    # add the brightness indicator if getBrightness() returns a non-error
    # value.
    brightnessFraction = light.getBrightness()
    if brightnessFraction >= 0:
      j.insert(0, {
        'full_text' : ' ☼ %d%% ' % int(round(100 * brightnessFraction)),
        'name' : 'backlight'})
    
    # Echo back new encoded json.
    printLine(prefix + json.dumps(j))
