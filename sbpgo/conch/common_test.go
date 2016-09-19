package conch_test

import "os"
import "testing"
import . "github.com/sethpollen/sbp_linux_config/sbpgo/conch"

func TestMakeShellId(t *testing.T) {
  pid := os.Getpid()
  shellId, err := MakeShellId(pid)
  if err != nil {
    t.Error(err)
  }
  if shellId.Pid != pid {
    t.Error("Wrong pid: ", shellId.Pid)
  }
  if shellId.StartTime <= 0 {
    t.Error("Bad StartTime: ", shellId.StartTime)
  }
}