package sbpgo_test

import (
  "errors"
  "strconv"
  "strings"
  "testing"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo"

const kilo int64 = 1024

func TestFormatShortBytes(t *testing.T) {
	var suffixes = []rune{'K', 'M', 'G'}
	var str string

	str = FormatShortBytes(-1, suffixes)
	if str != "NEG" {
		t.Errorf("Expected \"NEG\", got \"%s\"", str)
	}
	str = FormatShortBytes(kilo*kilo*kilo*kilo, suffixes)
	if str != "BIG" {
		t.Errorf("Expected \"BIG\", got \"%s\"", str)
	}

	// Test all values from 0 to 1MB.
	var bytes int64 = 0
	for ; bytes <= kilo*kilo; bytes++ {
		str = FormatShortBytes(bytes, suffixes)
    err := checkShortBytes(bytes, []rune(str))
		if err != nil {
      t.Errorf("Wrong result: FormatShortBytes(%d) -> \"%s\". Detail: %v",
               bytes, str, err)
      return
    }
	}
}

func checkShortBytes(original int64, str []rune) error {
  if len(str) != 3 {
    return errors.New("Wrong length")
  }
  
  // Check the no-suffix case, in which there should be 100% fidelity.
  parsed, err := strconv.Atoi(strings.TrimSpace(string(str)))
  if err == nil {
    if int64(parsed) != original {
      return errors.New("Inaccurate no-suffix conversion")
    }
    return nil
  }
  
  var multiplier int64
  switch str[2] {
    case 'K':
      multiplier = kilo
    case 'M':
      multiplier = kilo * kilo
    case 'G':
      multiplier = kilo * kilo * kilo
    default:
      return errors.New("Bad suffix");
  }
  str = str[0:2]
  
  var divisor int64 = 1
  if str[0] == '.' {
    divisor = 10
    str = str[1:2]
  }
  
  mantissa, err := strconv.Atoi(strings.TrimSpace(string(str)))
  if err != nil {
    return errors.New("Could not parse digits")
  }
  
  // Check that we chose the closest representation to the actual value.
  var actual = int64(mantissa) * multiplier / divisor
  var next = int64(mantissa + 1) * multiplier / divisor
  var prev = int64(mantissa - 1) * multiplier / divisor
  
  var actualError = abs(actual - original)
  var nextError = abs(next - original)
  var prevError = abs(prev - original)
  
  if nextError < actualError || prevError < actualError {
    return errors.New("Did not choose closest approximation")
  }
  
  return nil
}

func abs(x int64) int64 {
  if x < 0 {
    return -x
  }
  return x
}
