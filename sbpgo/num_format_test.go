package sbpgo_test

import (
	"testing"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo"

func TestShortBytes(t *testing.T) {
	type testCase struct {
		In  int64
		Out string
	}
	var cases = []testCase{
		{0, "  0"},
		{1, "  1"},
		{10, " 10"},
		{100, "100"},

		{999, "999"},
		{1000, ".9K"},

		{1023, ".9K"},
		{1024, " 1K"},

		{1024*10 - 1, " 9K"},
		{1024 * 10, "10K"},

		{1024*100 - 1, "99K"},
		{1024 * 100, ".1M"},       // Artificially rounded up.
		{1024*1024/10 + 1, ".1M"}, // Actually >.1M

		{1024*1024 - 1, ".9M"},
		{1024 * 1024, " 1M"},

		{1024 * 1024 * 1024, " 1G"},
	}

	for _, c := range cases {
		var actual string = ShortBytes(c.In)
		if c.Out != actual {
			t.Errorf("Input: %d; Expected: %q, Actual: %q", c.In, c.Out, actual)
		}
	}

	// Also check that all inputs produce a 3-character output.
	for i := 0; i <= 1000000; i++ {
		var actual string = ShortBytes(int64(i))
		if len(actual) != 3 {
			t.Errorf("Input: %d produced bad output: %q", i, actual)
		}
	}
}

func TestiFractionToBar(t *testing.T) {
	type testCase struct {
		In  float32
		Out string
	}
	var cases = []testCase{
    {0, "▁"},
    {0.124, "▁"},
    {0.126, "▂"},
    {0.874, "▇"},
    {0.876, "█"},
    {1, "█"},
  }

	for _, c := range cases {
		var actual string = FractionToBar(c.In)
		if c.Out != actual {
			t.Errorf("Input: %d; Expected: %q, Actual: %q", c.In, c.Out, actual)
		}
	}
}
