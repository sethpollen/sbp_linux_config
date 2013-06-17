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
import math
from backlight import Backlight

CPU_HISTORY_LEN = 8
LEFT_BAR = u'▏'

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


def roundToBar(fraction):
  """ Fetches the closest bar character for the given fraction. """
  if fraction <= 0:
    # Prevent non-positive values.
    fraction = 0.01
  elif fraction > 1:
    fraction = 1
  index = int(math.ceil(fraction * 8))
  return u' ▁▂▃▄▅▆▇█'[index]


def stripNonDigits(text):
  """ Strips non-digit characters from the beginning and end of text. """
  begin = 0
  end = len(text) - 1
  while begin <= end and not text[begin].isdigit():
    begin += 1
  while begin <= end and not text[end].isdigit():
    end -= 1
  return text[begin:end+1]


if __name__ == '__main__':
  # Keep a little history of CPU usages to display in a bar graph. This history
  # is actually just a string of bar-graph characters.
  cpuGraph = roundToBar(0) * CPU_HISTORY_LEN

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
        'full_text' : u' ☼ %d%% ' % int(round(100 * brightnessFraction)),
        'name' : 'backlight'})

    # Try to extract the cpu_usage entry from the JSON.
    for entry in j:
      if entry['name'] == 'cpu_usage':
        cpuText = entry['full_text']

        # Parse the CPU percentage and add it to the rolling list.
        cpuBar = roundToBar(float(stripNonDigits(cpuText)) * 0.01)
        cpuGraph = cpuGraph[1:] + cpuBar

        # Append the graph to the displayed text.
        entry['full_text'] = ' ' + cpuGraph + LEFT_BAR + cpuText
    
    # Echo back new encoded json.
    printLine(prefix + json.dumps(j))
