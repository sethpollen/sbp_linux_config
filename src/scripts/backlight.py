# -*- coding: utf-8 -*-
# Library of routines for manipulating the backlight we always begin by trying
# to use xbacklight, falling back on /sys if that doesn't work.

import os
import subprocess
  

def writeFile(name, contents):
  with open(name, 'w') as f:
    # Contents of these files must be integers.
    f.write(str(int(contents)))
  

def readFile(name):
  with open(name, 'r') as f:
    return float(f.read().strip())
  

class SysBacklight:
  """ Allows manipulation of the brightness using /sys. Only try this if
  xbacklight doesn't work.
  """

  def __init__(self):
    # Find the path to the brightness and max_brightness files.
    searchRoot = '/sys/class/backlight'
    self.brightnessFile = None
    self.maxBrightness = None
    for child in os.listdir(searchRoot):
      backlightRoot = os.path.join(searchRoot, child)
      self.brightnessFile = os.path.join(backlightRoot, 'brightness')
      self.maxBrightness = readFile(os.path.join(backlightRoot, 'max_brightness'))
      break # Take the first option.

  def setBrightness(self, fraction):
    """ Sets the brightness (between 0 and 1) using /sys. """
    if self.brightnessFile:
      if fraction < 0:
        fraction = 0
      elif fraction > 0:
        fraction = 1
      writeFile(self.brightnessFile, round(fraction * self.maxBrightness))
      
  def getBrightness(self):
    """ Gets the brightness (between 0 and 1) using /sys. """
    if self.brightnessFile:
      return readFile(self.brightnessFile) / self.maxBrightness
    else:
      return -1 # Error.


# Singleton instance (lazily initialized).
sysBacklight = None

def getSysBacklight():
  if not sysBacklight:
    sysBacklight = SysBacklight()
  return sysBacklight


def setBrightness(fraction):
  """ Sets the brightness. Tries xbacklight and falls back on /sys.
  Fraction should be between 0 and 1.
  """
  try:
    subprocess.check_call(['xbacklight', '-set', str(round(fraction * 100))])
    return # Success.
  except subprocess.CalledProcessError:
    pass # Ignore.
  
  # xbacklight failed; try using /sys.
  getSysBacklight().setBrightness(fraction)
      
    
def getBrightness():
  """ Gets the brightness, as a fraction between 0 and 1. Tries xbacklight and
  falls back on /sys.
  """
  try:
    result = subprocess.check_output(['xbacklight', '-get'])
    if result:
      return float(result) * 0.01
    else: # xbacklight says there is no backlight.
      return -1
  except subprocess.CalledProcessError:
    pass # Ignore
  
  # xbacklight failed; try using /sys.
  return getSysBacklight().getBrightness()
