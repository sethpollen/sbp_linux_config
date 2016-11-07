package words_test

import (
	"testing"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo/games/words"
import . "github.com/sethpollen/sbp_linux_config/sbpgo/games/words/embed"

func TestSample(t *testing.T) {
	list := GetWordList()
	sampler := NewIndex(list)
	var sampleSizes = []int{0, 1, 10, 100, 1000}
	for _, n := range sampleSizes {
		sample := sampler.Sample(n, 10)
		if sample.Len() != n {
			t.Errorf("Expected sample of %v; got %v", n, sample.Len())
		}
	}
}
