# -*- coding: utf-8 -*-
# Library for reading network usage stats from /proc/net/dev.

import time
import os

STATS_FILE = '/proc/net/dev'

WIRELESS_INTERFACE = 'wlan0'
ETHERNET_INTERFACE = 'eth0'


class Rate:
  """ Computes a instantaneous rate of a counter. """

  def __init__(self):
    self.lastCount = 0
    # If we start with the timestamp at -inf, the first rate computation will
    # still produce a rate of zero.
    self.lastTimestamp = float('-inf')
    self.rate = 0

  def update(self, now, count):
    count = float(count)
    now = float(now)
    self.rate = (count - self.lastCount) / (now - self.lastTimestamp)
    self.lastCount = count
    self.lastTimestamp = now


class InterfaceStats:
  """ Contains stats for a single network interface. """
  
  def __init__(self):
    self.rxBytes = Rate()
    self.txBytes = Rate()

  def update(self, now, rxByteCount, txByteCount):
    self.rxBytes.update(now, rxByteCount)
    self.txBytes.update(now, txByteCount)


class Stats:
  """ Contains stats parsed from /proc/net/dev. """

  def __init__(self):
    self.interfaces = {}
    self.update()

  def update(self):
    """ Updates rates by reading /proc/net/dev. """
    now = time.time()
    with open(STATS_FILE, 'r') as f:
      lines = f.readlines()
      headerLine = lines[1]
      _, receiveCols , transmitCols = headerLine.split("|")
      receiveCols = map(lambda a: "rx_" + a, receiveCols.split())
      transmitCols = map(lambda a: "tx_" + a, transmitCols.split())
      cols = receiveCols + transmitCols

      for line in lines[2:]:
        if line.find(":") < 0: continue
        interfaceName, data = line.split(":")
        interfaceName = interfaceName.strip()
        interfaceData = dict(zip(cols, data.split()))
        if not interfaceName in self.interfaces:
          self.interfaces[interfaceName] = InterfaceStats()
        self.interfaces[interfaceName].update(now,
                                              interfaceData['rx_bytes'],
                                              interfaceData['tx_bytes'])


# We use binary (not SI) prefixes.
PREFIX_FACTOR = 1024
PREFIXES = ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y']

def formatByteRate(byteRate):
  """ Pretty-prints a bytes/second rate. The result will never exceed 3
  characters in length.
  """
  byteRate = float(byteRate)
  prefix = 0
  while byteRate > 100:
    # The byteRate won't fit into 2 characters, so move to a higher prefix.
    byteRate /= PREFIX_FACTOR
    prefix += 1

  if byteRate < 0.95:
    byteRateStr = '.%d' % round(byteRate * 10)
  elif byteRate < 9.5:
    byteRateStr = ' %d' % round(byteRate)
  else:
    byteRateStr = '%d' % round(byteRate)

  return byteRateStr + PREFIXES[prefix]

