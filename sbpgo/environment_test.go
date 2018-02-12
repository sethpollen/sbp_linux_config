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
  mod.SetVar("B", "~!@#$%^&*()_+ :;<>,.?/\"'\t\r\n日本")
  mod.UnsetVar("A")
  var actual = mod.ToScript()
  var expected = "unset A\nexport B='~!@#$%^&*()_+ :;<>,.?/\"\\'\t\r\n日本'\n"
  if actual != expected {
    // Find the point where the two strings diverge.
    var actualRunes = []rune(actual)
    var expectedRunes = []rune(expected)
    if len(actualRunes) != len(expectedRunes) {
      t.Errorf("Expected %d runes, got %d runes",
        len(expectedRunes), len(actualRunes))
    } else {
      for i := 0; i < len(actualRunes); i++ {
        var actualRune = actualRunes[i]
        var expectedRune = expectedRunes[i]
        if actualRune != expectedRune {
          t.Errorf("At position %d, expected rune 0x%X, got rune 0x%X",
            i, expectedRune, actualRune)
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
