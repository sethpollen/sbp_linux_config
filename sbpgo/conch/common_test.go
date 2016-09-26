package conch_test

import (
	"os"
	"testing"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo/conch"

func TestMakeShellId(t *testing.T) {
	myPid := os.Getpid()
	shellId, err := MakeShellId(myPid)
	if err != nil {
		t.Error(err)
	}
	if shellId.Pid != myPid {
		t.Error("Wrong pid: ", shellId.Pid)
	}
	if shellId.StartTime <= 0 {
		t.Error("Bad StartTime: ", shellId.StartTime)
	}
}
