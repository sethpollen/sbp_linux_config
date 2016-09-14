# -*- coding: utf-8 -*-
# A small library to generate color from a spectrum based on the current time
# of day. Not really useful, but kind of cool as an addition to i3bar.

import time
import colorsys


# Here's the spectrum we use. All colors are specified in the HSV scaled
# and have saturation=60 and value=100. Hue counts down, interpolating
# between several points throught the day:
#
#   2AM  - Serious coding time. You should not usually stay up this late.
#          Sort of a burning red: hue=360 (hue=0)
#   7AM  - Good morning! Blue: hue=240
#   12PM - Lunch time. Green: hue=120
#   5PM  - Time to go home. Yellow: hue=60
#   8PM  - Time to relax. Orange: hue=30
SATURATION = 0.6
VALUE = 1

# Table of points representing the above color points. Note that we add an
# a duplicate point at the beginning and end to make lookup easy.
COLOR_TABLE = [
  (-4, 390),  # 8PM again.
  (2, 360),
  (7, 240),
  (12, 120),
  (17, 60),
  (20, 30),
  (26, 0),  # 2AM again.
]


def interpolate(p1, p2, x):
  """ Performs linear interpolation between two points (p1 and p2) expressed
  as (x,y) pairs, using 'x' as the input value.
  """
  (x1, y1) = p1
  (x2, y2) = p2
  dx = abs(x1 - x2)
  dy = abs(y1 - y2)
  minx = min(x1, x2)
  miny = min(y1, y2)
  r = (x - minx) / float(dx)
  return miny + (r * dy)


def getColor(now):
  """ Gets a color (as an RGB triple) to use for the current time 'now'.
  'now' must be a datetime.datetime object.
  """
  hour = now.hour + (now.minute / 60.0)
  
  # Look up bounds for 'hour' in the color table.
  upper = 1
  while True:
    (upperHour, _) = COLOR_TABLE[upper]
    if hour <= upperHour:
      break
    upper += 1

  p1 = COLOR_TABLE[upper - 1]
  p2 = COLOR_TABLE[upper]
  hue = interpolate(p1, p2, hour) % 360

  # colorsys expects hue to be in the range [0, 1] rather than [0, 360].
  hue = float(hue) / 360.0

  return colorsys.hsv_to_rgb(hue, SATURATION, VALUE)


def formatRgb(rgb):
  """ Takes an RGB triple 'rgb' (a triple of values in the range [0, 1]) and
  returns a #XXXXXX hex string.
  """
  (r, g, b) = rgb
  r = min(255, int(r * 256))
  g = min(255, int(g * 256))
  b = min(255, int(b * 256))
  return "#%02X%02X%02X" % (r, g, b)
