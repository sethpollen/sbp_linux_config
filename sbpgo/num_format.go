// Number formatting utilities. Includes utilities for generating Unicode
// bar graphs.
package sbpgo

import (
  "math"
  "fmt"
)

const (
	leftEdgeBar        = "▏"
	rightEdgeBar       = "▕"
	verticalFillBars   = "▁▂▃▄▅▆▇█"
	horizontalFillBars = "▏▎▍▌▋▊▉█"
  numBars            = 8
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
    var roundedDecimal int64 = roundRatio(bytes * 10, multiplier)
    if roundedDecimal < 10 {
      return fmt.Sprintf(".%d%s", roundedDecimal, runeToString(suffix))
    }
		var rounded int64 = roundRatio(bytes, multiplier)
		if rounded <= 99 {
			return fmt.Sprintf("%2d%s", rounded, runeToString(suffix))
		}
		// We'll need to move to the next suffix.
		multiplier *= 1024
	}
	// Give up. We don't have enough suffixes.
	return "BIG"
}

func roundRatio(num, den int64) int64 {
	return (num + den/2) / den
}

func runeToString(r rune) string {
  return string([]rune{r})
}

// Returns the closest bar character for the given fraction.
func RoundToVerticalBar(fraction float64) string {
  fraction = math.Min(1, math.Max(0, fraction))
  var barWidth float64 = 1.0 / numBars
  for _, barRune := range verticalFillBars {
    fraction -= barWidth
    if fraction <= 0 {
      return string([]rune{barRune})
    }
  }
  // Error.
  return "X"
}