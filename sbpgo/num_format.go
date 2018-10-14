// Utilities for formatting numbers.

package sbpgo

import (
	"fmt"
)

// Formats a byte count. The result will be exactly 3 characters in length
// (we'll use binary SI letters to abbreviate it). A typical value for
// 'siPrefixes' is " KMGT".
func ShortBytes(x int64, siPrefixes string) string {
	if x < 1000 {
		// No prefix necessary.
		return fmt.Sprintf("%3d", x)
	}

	// Invariant: multiplier = 1024^exponent
	var exponent int = 1
	var multiplier int64 = 1024
	for x/multiplier >= 100 {
		exponent += 1
		multiplier *= 1024
	}
	var prefix string = siPrefixes[exponent : exponent+1]

	if x/multiplier < 1 {
		digit := x * 10 / multiplier
		if digit == 0 {
			// We're in a bind here. A value like 102400 cannot be written with K,
			// since "100K" is too long. But it's less than .1M. In this case we
			// lie and say that it's .1M.
			digit = 1
		}
		return fmt.Sprintf(".%d%s", digit, prefix)
	}
	return fmt.Sprintf("%2d%s", x/multiplier, prefix)
}

// Returns a Unicode bar character to represent the given fraction.
func FractionToBar(fraction float32) string {
	var bars = []string{"▁", "▂", "▃", "▄", "▅", "▆", "▇", "█"}

	if fraction < 0 {
		fraction = 0
	}
	if fraction > 1 {
		fraction = 1
	}
	index := int(fraction * float32(len(bars)))
	// Handle the special case of fraction=1.
	if index == len(bars) {
		index--
	}
	return bars[index]
}
