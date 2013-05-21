# -*- coding: utf-8 -*-
# Library of routines for manipulating the backlight through /sys.

import os
  
def writeFile(name, contents):
  with open(name, 'w') as f:
    # Contents of these files must be integers.
    f.write(str(int(contents)))
    
def readFile(name):
  with open(name, 'r') as f:
    return float(f.read().strip())
    
# Find the path to the brightness and max_brightness files.
searchRoot = '/sys/class/backlight'
brightnessFile = None
maxBrightness = None
for child in os.listdir(searchRoot):
  backlightRoot = os.path.join(searchRoot, child)
  brightnessFile = os.path.join(backlightRoot, 'brightness')
  maxBrightness = readFile(os.path.join(backlightRoot, 'max_brightness'))
  break # Take the first option.

def setBrightness(fraction):
  """ Sets the brightness. Fraction should be between 0 and 1. """
  if brightnessFile: # We found a backlight to manipulate.
    if fraction < 0.0:
      fraction = 0.0
    elif fraction > 1.0:
      fraction = 1.0
      
    writeFile(brightnessFile, round(fraction * maxBrightness))
    
def getBrightness():
  """ Gets the brightness, as a fraction between 0 and 1. """
  if brightnessFile: # We found a backlight to manipulate.
    return readFile(brightnessFile) / maxBrightness
  else:
    return 0
