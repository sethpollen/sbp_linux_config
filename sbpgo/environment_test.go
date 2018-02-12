package sbpgo_test

import (
	"os"
	"strings"
	"testing"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo"

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

	var expecteds = []string{"PATH", "PYTHONPATH", "SBP_ENVIRONMENT_SENTINEL",
                           "EDITOR", "TERMINAL"}
	for _, expected := range expecteds {
		if strings.Index(script, expected) < 0 {
			t.Errorf("Did not find %s", expected)
		}
	}

  os.Setenv("SBP_ENVIRONMENT_SENTINEL", "1")

	env, err = StandardEnviron()
	if err != nil {
		t.Error(err)
		return
	}
  script = env.ToScript()

  if len(script) > 0 {
    t.Error("Expected no script if sentinel is already set")
  }
}
