package words_test

import (
	"testing"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo/games/words/embed"

func TestGetWordList(t *testing.T) {
	list := GetWordList()
	if len(list.Words) != 5000 {
		t.Errorf("Expected 5000 words; got %v", len(list.Words))
	}
	var totalOccurrences int64 = 0
	for _, word := range list.Words {
		totalOccurrences += word.Occurrences
	}
	if list.TotalOccurrences != totalOccurrences {
		t.Errorf("Expected %v total occurrences; got %v",
			totalOccurrences, list.TotalOccurrences)
	}
}
