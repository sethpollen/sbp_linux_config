package sbpgo_test

import (
  "fmt"
  "os"
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
  fmt.Println(script)
}
