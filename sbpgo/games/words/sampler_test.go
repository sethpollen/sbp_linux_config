package words_test

import (
	"testing"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo/games/words"
import . "github.com/sethpollen/sbp_linux_config/sbpgo/games/words/embed"

func TestSampleUniform(t *testing.T) {
	list := GetWordList()
	var sampleSizes = []int{0, 1, 10, 100, 1000}
	for _, n := range sampleSizes {
		sample := SampleUniform(list, n)
		if len(sample) != n {
			t.Errorf("Expected sample of %v; got %v", n, len(sample))
		}
	}
}

func TestSampleOccurrence(t *testing.T) {
	list := GetWordList()
	var sampleSizes = []int{0, 1, 10, 100, 1000}
	for _, n := range sampleSizes {
		sample := SampleOccurrence(list, n)
		if len(sample) != n {
			t.Errorf("Expected sample of %v; got %v", n, len(sample))
		}
	}
}
