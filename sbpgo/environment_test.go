package sbpgo_test

import (
	"os"
	"strings"
	"testing"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo"

func TestToScript(t *testing.T) {
	var mod = NewEnvironMod()
	mod.SetVar("A", "B")
	// Include some tricky characters.
	mod.SetVar("B", "\"'\n\\日本")
	mod.UnsetVar("A")
	var actual = mod.ToScript()
	var expected = "set --erase A; set --export --global B \\U22\\U27\\Ua\\U5c\\U65e5\\U672c; "
	if actual != expected {
		// Find the point where the two strings diverge.
		var actualRunes = []rune(actual)
		var expectedRunes = []rune(expected)
		if len(actualRunes) != len(expectedRunes) {
			t.Errorf("Expected %d runes, got %d runes. Actual: %q",
				len(expectedRunes), len(actualRunes), actual)
		} else {
			for i := 0; i < len(actualRunes); i++ {
				var actualRune = actualRunes[i]
				var expectedRune = expectedRunes[i]
				if actualRune != expectedRune {
					t.Errorf("At position %d, expected rune 0x%X, got rune 0x%X. Actual: %q",
						i, expectedRune, actualRune, actual)
				}
			}
		}
	}
}

func TestApply(t *testing.T) {
	var mod = NewEnvironMod()
	mod.SetVar("A", "1")
	mod.UnsetVar("B")

	os.Setenv("B", "2")
	mod.Apply()

	a, aOk := os.LookupEnv("A")
	_, bOk := os.LookupEnv("B")

	if !aOk || a != "1" {
		t.Error("A")
	}
	if bOk {
		t.Error("B")
	}
}

func TestStandardEnviron(t *testing.T) {
	// Set some variables which 'bazel test' seems to clear.
	os.Setenv("HOME", "/foo")
	os.Setenv("PYTHONPATH", "/bar")

	env, err := StandardEnviron()
	if err != nil {
		t.Error(err)
		return
	}
	script := env.ToScript()

	var expecteds = []string{"PATH", "PYTHONPATH", "EDITOR", "TERMINAL"}
	for _, expected := range expecteds {
		if strings.Index(script, expected) < 0 {
			t.Errorf("Did not find %s", expected)
		}
	}

	// Test idempotence.
	env.Apply()

	env, err = StandardEnviron()
	if err != nil {
		t.Error(err)
		return
	}
	script2 := env.ToScript()

	if script != script2 {
		t.Error("Not idempotent")
	}
}
