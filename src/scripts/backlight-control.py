#!/usr/bin/env python
# -*- coding: utf-8 -*-

# A simple script that uses /sys to control the brightness.
# This program accepts one command-line argument: an integer between 0 and 100,
# indicating the percentage of brightness desired. A + or - may be prepended
# to make the change relative to the current setting. Note that your
# driver may only permit fewer than 100 distinct brightness settings, so
# trying to change by small increments may have no effect.
# The argument may instead be a lower-case q. In that case, the current
# brightness value is printed to stdout.

import sys
import os
from backlight import setBrightness, getBrightness

def printHelpAndExit():
  print('Usage:\n' +
    '  backlight-control.py [+-]value\n' + 
    '(where value is an integer between 0 and 100)')
  exit(1)
  
if __name__ == '__main__':
  # Parse command-line arguments.
  if len(sys.argv) < 2:
    printHelpAndExit()
    
  # Mode can be either '+', '-', or 'abs' (absolute). Absolute is the default.
  mode = 'abs'

  setting = sys.argv[1]
  if setting == 'q':
    mode = 'q'
    setting = '0' # Dummy value.
  elif setting.startswith('+'):
    mode = '+'
    setting = setting[1:]
  elif setting.startswith('-'):
    mode = '-'
    setting = setting[1:]

  try:
    # Convert to a fraction.
    setting = float(setting) * 0.01
  except ValueError:
    printHelpAndExit()

  # Compute the new value to set.
  if mode != 'abs':
    # Scale the brightness by its max.
    brightness = getBrightness()
    if mode == '+':
      brightness += setting
    elif mode == '-':
      brightness -= setting
    else: # Mode is 'q'.
      print(brightness)
      exit(0)
  else:
    # Use the setting as an absolute brightness.
    brightness = setting
    
  setBrightness(brightness)
