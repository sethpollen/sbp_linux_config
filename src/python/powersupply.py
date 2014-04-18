# -*- coding: utf-8 -*-
# Library for reading power supply stats from /sys/class/power_supply.

import time
import os
import os.path as path

STATS_ROOT = '/sys/class/power_supply'


def read(filename):
  return open(filename, 'r').read()

def convertMicroWattHoursToJoules(microWattHours):
  return microWattHours * 0.0036

def convertMicroWattsToWatts(microWatts):
  return microWatts * 0.000001


class Stats:
  """ Provides a nice view of /sys/class/power_supply. Only reads /sys counters
  on instantiation, so you have to create a new Stats every time you want a
  fresh view. After instantiation, check out these fields:
    ac - Boolean indicating whether we are on AC power.
    batteryCapacity - Factory-rated battery capacity in Joules.
    batteryCharge - Current charge of battery in Joules.
    batteryPower - Current power output of battery in Watts.
  """

  def __init__(self):
    self.ac = False
    numBatteries = 0
    self.batteryCapacity = 0
    self.batteryCharge = 0
    self.batteryPower = 0

    for device in os.listdir(STATS_ROOT):
      deviceRoot = path.join(STATS_ROOT, device)
      deviceType = read(path.join(deviceRoot, 'type'))
      if deviceType == 'Mains':
        self.ac = True
      elif deviceType == 'Battery':
        self.batteryCapacity += convertMicroWattHoursToJoules(
            float(read(path.join(deviceRoot, 'energy_full_design'))))
        self.batteryCharge += convertMicroWattHoursToJoules(
            float(read(path.join(deviceRoot, 'energy_now'))))
        delf.batteryPower += convertMicroWattsToWatts(
            float(read(path.join(deviceRoot, 'power_now'))))

    if numBatteries == 0:
      # Something must be powering the machine. Assume it's on AC.
      self.ac = True
