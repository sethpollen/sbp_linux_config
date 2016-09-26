// Number formatting utilities. Includes utilities for generating Unicode
// bar graphs.
package sbpgo

import (
	"fmt"
)

const (
	SiPrefixes         = "KMGTP"
	LeftEdgeBar        = "▏"
	RightEdgeBar       = "▕"
	VertialFillBars    = " ▁▂▃▄▅▆▇█"
	HorizontalFillBars = " ▏▎▍▌▋▊▉█"
)

// Pretty-prints a number of bytes. The result be exactly 3 characters
// in length. 'suffixes' will be used to express larger values. Each suffix is
// considered to denote a value 1024x larger than the previous suffix. If
// 'bytes' is smaller than 1024, no suffix will be used.
func FormatShortBytes(bytes int64, suffixes []rune) string {
	if bytes < 0 {
		// We don't spend much effort supporting negative values.
		return "NEG"
	}
	if bytes <= 999 {
		// No suffix needed.
		return fmt.Sprintf("%3d", bytes)
	}
	var multiplier int64 = 1024
	for _, suffix := range suffixes {
    // Check if we need to include a decimal point
    var roundedDecimal int64 = RoundRatio(bytes * 10, multiplier)
    if roundedDecimal < 10 {
      return fmt.Sprintf(".%d%s", roundedDecimal, RuneToString(suffix))
    }
		var rounded int64 = RoundRatio(bytes, multiplier)
		if rounded <= 99 {
			return fmt.Sprintf("%2d%s", rounded, RuneToString(suffix))
		}
		// We'll need to move to the next suffix.
		multiplier *= 1024
	}
	// Give up. We don't have enough suffixes.
	return "BIG"
}

func RoundRatio(num, den int64) int64 {
	return (num + den/2) / den
}

func RuneToString(r rune) string {
  return string([]rune{r})
}

/*

def roundToVerticalBar(fraction):
  """ Fetches the closest bar character for the given fraction. """
  # Prevent non-positive values.
  fraction = min(1, max(0.001, fraction))
  # We always want bar graphs to show at least a sliver along the bottom. So
  # we round up to the next fraction of 8.
  index = int(math.ceil(fraction * 8))
  return VERTICAL_FILL[index]


def roundToHorizontalBar(fraction, num_chars):
  """ Returns a string containing a left-to-right bar graph of width 'num_chars'
  and the given fill fraction.
  """
  fraction = min(1, max(0, fraction))
  remaining = int(round(fraction * num_chars * 8))
  text = ''
  while remaining >= 8:
    text += HORIZONTAL_FILL[8]
    remaining -= 8
  while len(text) < num_chars:
    text += HORIZONTAL_FILL[remaining]
    remaining = max(0, remaining - 8)
  return text


def tieredVerticalBars(value, bar_maxes):
  """ Generates a tiered vertical bar graph which. """
  value = float(value)
  text = ''
  bar_maxes.sort()
  for bar_max in bar_maxes:
    if value >= bar_max:
      text = VERTICAL_FILL[8] + text
      value -= bar_max
    elif value <= 0:
      text = ' ' + text
    else:
      text = roundToVerticalBar(value / float(bar_max)) + text
      value = 0
  return text

def stripNonDigits(text):
  """ Strips non-digit characters from the beginning and end of text. """
  begin = 0
  end = len(text) - 1
  while begin <= end and not text[begin].isdigit():
    begin += 1
  while begin <= end and not text[end].isdigit():
    end -= 1
  return text[begin:end+1]


# Pattern for matching percentages. Note the leading and trailing spaces.
percentagePattern = re.compile(r' ?[0-9]+\% ?')

def replacePercentageWithBar(text, vertical=True, num_chars=1):
  """ Replaces the first occurrence of a percentage (like XXX%) in 'text'
  with a bar-graph that represents the same quantity.
  """
  m = re.search(percentagePattern, text)
  if m is None:
    return text
  percentageText = m.group(0)
  fraction = float(stripNonDigits(percentageText)) * 0.01
  if vertical:
    barGraph = RIGHT_BAR + roundToVerticalBar(fraction) + LEFT_BAR
  else:
    barGraph = RIGHT_BAR + roundToHorizontalBar(fraction, num_chars) + LEFT_BAR
  return string.replace(text, percentageText, barGraph, 1)


def formatMinuteHourDuration(seconds):
  """ Formats a duration given in seconds into the HH:MM format. """
  minutes = math.floor(seconds / 60.0)
  hours = math.floor(minutes / 60.0)
  minutes -= hours * 60.0
  return '%d:%02d' % (hours, minutes)

*/
