# -*- coding: utf-8 -*-
# Library for reading network usage stats from /proc/net/dev.

import time
import os

STATS_FILE = '/proc/net/dev'

WIRELESS_INTERFACE = 'wlan0'
ETHERNET_INTERFACE = 'eth0'
VPN_INTERFACE      = 'tun0'


class Rate:
  """ Computes a instantaneous rate of a counter. """

  def __init__(self):
    self.count = 0
    # If we start with the timestamp at -inf, the first rate computation will
    # still produce a rate of zero.
    self.timestamp = float('-inf')
    self.rate = 0

  def update(self, now, now_count):
    now_count = float(now_count)
    now = float(now)
    self.rate = (now_count - self.count) / (now - self.timestamp)
    self.count = now_count
    self.timestamp = now


class InterfaceStats:
  """ Contains stats for a single network interface. """
  
  def __init__(self):
    self.now = float('-inf')
    self.rxBytes = Rate()
    self.txBytes = Rate()

  def update(self, now, rxByteCount, txByteCount):
    self.now = now
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

    # Remove any interfaces which weren't present in the file.
    for key in self.interfaces.keys():
      if self.interfaces[key].now < now:
        del self.interfaces[key]

