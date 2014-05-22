# -*- coding: utf-8 -*-
# Library formatting numbers for use in i3status lines.

import re
import math
import string

# We use binary (not SI) prefixes.
PREFIX_FACTOR = 1024
PREFIXES = [' ', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y']

LEFT_BAR  = u'▏'
RIGHT_BAR = u'▕'
VERTICAL_FILL   = u' ▁▂▃▄▅▆▇█'
HORIZONTAL_FILL = u' ▏▎▍▌▋▊▉█'


def shortBytes(bytes, skip_prefixes=0):
  """ Pretty-prints a number of bytes. The result will never exceed 3
  characters in length. If 'skip_prefixes' is greater than zero, it gives
  the number of binary SI prefixes to skip over. Quantities smaller than
  these first non-skipped prefix will be rounded away.
  """
  bytes = float(bytes)
  
  prefix = skip_prefixes
  bytes /= PREFIX_FACTOR ** skip_prefixes
  
  if bytes < 999.5:
    # No need for prefixes.
    return '%3d' % round(bytes)
  
  while bytes >= 99.5:
    # The bytes won't fit into 2 characters, so move to a higher prefix.
    bytes /= PREFIX_FACTOR
    prefix += 1

  if bytes < 0.05:
    bytesStr = ' 0'
  elif bytes < 0.95:
    bytesStr = '.%d' % round(bytes * 10)
  elif bytes < 9.5:
    bytesStr = ' %d' % round(bytes)
  else:
    bytesStr = '%d' % round(bytes)

  if prefix == 0:
    return PREFIXES[prefix] + bytesStr
  else:
    return bytesStr + PREFIXES[prefix]
  
    
def roundToVerticalBar(fraction):
  """ Fetches the closest bar character for the given fraction. """
  # Prevent non-positive values.
  fraction = min(1, max(0.001, fraction))
  # We always want bar graphs to show at least a sliver along the bottom. So
  # we round up to the next fraction of 8.
  index = int(math.ceil(fraction * 8))
  return VERTICAL_FILL[index]


def roundToHorizontalBar(fraction, num_chars):
  """ Returns a string containing a left-to-right bar graph of width 'num_chars'
  and the given fill fraction.
  """
  fraction = min(1, max(0, fraction))
  remaining = int(round(fraction * num_chars * 8))
  text = ''
  while remaining >= 8:
    text += HORIZONTAL_FILL[8]
    remaining -= 8
  while len(text) < num_chars:
    text += HORIZONTAL_FILL[remaining]
    remaining = max(0, remaining - 8)
  return text
  
  
def tieredVerticalBars(value, bar_maxes):
  """ Generates a tiered vertical bar graph which. """
  value = float(value)
  text = ''
  bar_maxes.sort()
  for bar_max in bar_maxes:
    if value >= bar_max:
      text = VERTICAL_FILL[8] + text
      value -= bar_max
    elif value <= 0:
      text = ' ' + text
    else:
      text = roundToVerticalBar(value / float(bar_max)) + text
      value = 0
  return text

def stripNonDigits(text):
  """ Strips non-digit characters from the beginning and end of text. """
  begin = 0
  end = len(text) - 1
  while begin <= end and not text[begin].isdigit():
    begin += 1
  while begin <= end and not text[end].isdigit():
    end -= 1
  return text[begin:end+1]


# Pattern for matching percentages. Note the leading and trailing spaces.
percentagePattern = re.compile(r' ?[0-9]+\% ?')

def replacePercentageWithBar(text, vertical=True, num_chars=1):
  """ Replaces the first occurrence of a percentage (like XXX%) in 'text'
  with a bar-graph that represents the same quanitity.
  """
  m = re.search(percentagePattern, text)
  if m is None:
    return text
  percentageText = m.group(0)
  fraction = float(stripNonDigits(percentageText)) * 0.01
  if vertical:
    barGraph = RIGHT_BAR + roundToVerticalBar(fraction) + LEFT_BAR
  else:
    barGraph = RIGHT_BAR + roundToHorizontalBar(fraction, num_chars) + LEFT_BAR
  return string.replace(text, percentageText, barGraph, 1)


def formatMinuteHourDuration(seconds):
  """ Formats a duration given in seconds into the HH:MM format. """
  minutes = math.floor(seconds / 60.0)
  hours = math.floor(minutes / 60.0)
  minutes -= hours * 60.0
  return '%d:%02d' % (hours, minutes)

