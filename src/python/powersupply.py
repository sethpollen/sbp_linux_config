# -*- coding: utf-8 -*-
# Library for reading power supply stats from /sys/class/power_supply.

import time
import os
import os.path as path
from collections import deque

STATS_ROOT = '/sys/class/power_supply'


def read(filename, valueOnError=None):
  try:
    return open(filename, 'r').read().strip()
  except IOError:
    return valueOnError

def convertMicroWattHoursToJoules(microWattHours):
  return microWattHours * 0.0036

def convertMicroWattsToWatts(microWatts):
  return microWatts * 0.000001


class Stats:
  """ Provides a nice view of /sys/class/power_supply. Only reads /sys counters
  on instantiation, so you have to create a new Stats every time you want a
  fresh view. After instantiation, check out these fields:
    ac - Boolean indicating whether we are on AC power.
    numBatteries - Number of batteries.
    batteryCapacity - Factory-rated battery capacity in Joules.
    batteryCharge - Current charge of battery in Joules.
    batteryPower - Current power output of battery in Watts.
  """

  def __init__(self, ac, numBatteries, batteryCapacity, batteryCharge,
               batteryPower):
    """ Explicitly initializes the fields of this Stats. """
    self.ac = ac
    self.numBatteries = numBatteries
    self.batteryCapacity = batteryCapacity
    self.batteryCharge = batteryCharge
    self.batteryPower = batteryPower

  def __init__(self):
    """ Initializes the Stats from /sys. """
    self.ac = False
    self.numBatteries = 0
    self.batteryCapacity = 0
    self.batteryCharge = 0
    self.batteryPower = 0

    for device in os.listdir(STATS_ROOT):
      deviceRoot = path.join(STATS_ROOT, device)
      deviceType = read(path.join(deviceRoot, 'type'))
      if deviceType == 'Mains':
        if read(path.join(deviceRoot, 'online')) != '0':
          self.ac = True
      elif deviceType == 'Battery':
        self.numBatteries += 1
        self.batteryCapacity += convertMicroWattHoursToJoules(
            float(read(path.join(deviceRoot, 'energy_full_design'), 0)))
        self.batteryCharge += convertMicroWattHoursToJoules(
            float(read(path.join(deviceRoot, 'energy_now'), 0)))
        self.batteryPower += convertMicroWattsToWatts(
            float(read(path.join(deviceRoot, 'power_now'), 0)))

    if self.numBatteries == 0:
      # Something must be powering the machine. Assume it's on AC.
      self.ac = True


class StatsRefresher:
  """ Provides a Stats object with bounded staleness. """

  def __init__(self, refreshPeriod):
    """ refreshPeriod is the maximum staleness, in seconds. """
    self.refreshPeriod = refreshPeriod
    self.lastRefresh = 0
    self.stats = None

  def get(self):
    """ Gets a Stats. """
    now = time.time()
    if now - self.lastRefresh > self.refreshPeriod:
      self.stats = Stats()
      self.lastRefresh = now
    return self.stats


class HistoricalStatsRefresher:
  """ Similar to StatsRefresher, but uses the historical values of the
  batteries' energy level to compute power drain rate, instead of relying on
  the "power_now" statistic in /sys. I have no idea what interval power_now is
  computed, but it seems to be too short; power_no is too noisy.
  """

  def __init__(self, refreshPeriod, powerAggregatePeriod):
    """ refreshPeriod is the maximum staleness, in seconds.
    powerAggregatePeriod is the period to use when computing the power drain
    rate.
    """
    self.refreshPeriod = refreshPeriod
    self.powerAggregatePeriod = powerAggregatePeriod
    self.lastRefresh = 0
    self.stats = None
    # chargeHistory is a queue of (time, batteryCharge) pairs.
    self.chargeHistory = deque()

  def takeSample(self, now):
    """ Takes a new sample Stats right now. """
    self.stats = Stats()
    self.lastRefresh = now
    self.chargeHistory.append((now, self.stats.batteryCharge))
    # Garbage collect old data.
    retainThreshold = now - self.powerAggregatePeriod
    while self.chargeHistory[0][0] < retainThreshold:
      self.chargeHistory.popleft()
    # Compute the average power drain rate over the retained interval.
    chargeDelta = (self.chargeHistory[0][1] - self.chargeHistory[-1][1])
    timeDelta = (self.chargeHistory[-1][0] - self.chargeHistory[0][0])
    if timeDelta > 0:
      self.stats.batteryPower = max(0.0, chargeDelta / timeDelta)

  def get(self):
    """ Gets a Stats. """
    now = time.time()
    if now - self.lastRefresh > self.refreshPeriod:
      self.takeSample(now)
    return self.stats
