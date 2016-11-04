package words_test

import (
	"testing"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo/games/words"

func TestFormatShortBytes(t *testing.T) {
	list, err := GetWordlist()
	if err != nil {
		t.Error(err)
		return
	}
	if len(list) != 5000 {
		t.Errorf("Expected 5000 words; got %v", len(list))
	}
}
