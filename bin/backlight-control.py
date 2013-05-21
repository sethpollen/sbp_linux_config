#!/usr/bin/python
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

def printHelpAndExit():
  print('Usage:\n' +
    '  backlight-control.py [+-]value\n' + 
    '(where value is an integer between 0 and 100)')
  exit(1)
  
def writeFile(name, contents):
  with open(name, 'w') as f:
    # Contents of these files must be integers.
    contents = int(contents)
    f.write(str(contents))
    
def readFile(name):
  with open(name, 'r') as f:
    return float(f.read().strip())
  
def main():
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
    setting = float(setting)
  except ValueError:
    printHelpAndExit()
    
  # Find the path to the brightness and max_brightness files.
  searchRoot = '/sys/class/backlight'
  backlightRoot = None
  for child in os.listdir(searchRoot):
    backlightRoot = os.path.join(searchRoot, child)
    break # Take the first option.
  else:
    # We found no suitable backlight directory.
    print('Could not find a backlight in ' + searchRoot)
    exit(1)
    
  brightnessFile = os.path.join(backlightRoot, 'brightness')
  maxBrightnessFile = os.path.join(backlightRoot, 'max_brightness')
  maxBrightness = readFile(maxBrightnessFile)

  # Compute the new value to set.
  if mode != 'abs':
    # Scale the brightness by its max.
    brightness = readFile(brightnessFile) * (100.0 / maxBrightness)
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

  # Saturate.
  if brightness < 0.0:
    brightness = 0.0
  elif brightness > 100.0:
    brightness = 100.0
    
  # Scale back down by the max, rounding to the nearest integer.
  writeFile(brightnessFile, round(brightness * (maxBrightness / 100.0)))

if __name__ == '__main__':
  main()
