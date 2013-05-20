#!/usr/bin/python
# A simple script that uses /sys to control the brightness.
# This program accepts one command-line argument: an integer between 0 and 100,
# indicating the percentage of brightness desired. A + or - may be prepended
# to make the change relative to the current setting. Note that your
# driver may only permit fewer than 100 distinct brightness settings, so
# trying to change by small increments may have no effect.

import sys


def printHelpAndExit():
  print('Usage:\n' +
    '  backlight-control.py [+-]value\n' + 
    '(where value is an integer between 0 and 100)')
  exit(-1)


def setBrightness(setting):
  """ Uses /sys """
  #TODO


def main():
  if len(sys.argv) < 2:
    printHelpAndExit()

  # Mode can be either '+', '-', or 'abs' (absolute). Absolute is the default.
  mode = 'abs'

  setting = sys.argv[1]
  if setting.startswith('+'):
    mode = '+'
    setting = setting[1:]
  elif setting.startswith('-'):
    mode = '-'
    setting = setting[1:]

  try:
    setting = int(setting)
  except ValueError:
    printHelpAndExit()

  # Compute the new value to set.
  if mode != 'abs':
    oldBrightness = getBrightness()
    if mode == '+':
      setting = oldBrightness + setting
    else:
      setting = oldBrightness - setting

  # TODO saturate.

  setBrightness(newBrightness)
  

if __name__ == '__main__':
  main()
