package conch_test

import "os"
import "testing"
import "time"
import . "github.com/sethpollen/sbp_linux_config/sbpgo/conch"

const testSocketPath = "/tmp/sbp_conch_test.sock"

func TestBasicRpcs(t *testing.T) {
	go RunServer(testSocketPath)
	myPid := os.Getpid()

	// It may take time for the server to come up.
	start := time.Now()
	var client *Client
	var err error
	for {
		client, err = NewClient(myPid, testSocketPath)
		if err == nil {
			break
		}
		if time.Now().Sub(start) > 10*time.Second {
			t.Error("Waited too long for server to come up")
			return
		}
		time.Sleep(time.Millisecond)
	}

	err = client.BeginCommand("ls", "/home")
	if err != nil {
		t.Error(err)
	}

	shells, err := client.ListShells()
	if err != nil {
		t.Error(err)
	}
	if len(shells) != 1 {
		t.Errorf("Expected 1 shell; got %v", len(shells))
	}
	if shells[0].Id.Pid != myPid {
		t.Error("Wrong Pid reported")
	}
	if shells[0].Info.LatestCommand != "ls" {
		t.Error("Wrong LatestCommand reported")
	}
	if shells[0].Info.Running != true {
		t.Error("Wrong Running reported")
	}
	if shells[0].Info.Pwd != "/home" {
		t.Error("Wrong Pwd reported")
	}

	err = client.EndCommand()
	if err != nil {
		t.Error(err)
	}

	shells, err = client.ListShells()
	if err != nil {
		t.Error(err)
	}
	if len(shells) != 1 {
		t.Errorf("Expected 1 shell; got %v", len(shells))
	}
	if shells[0].Info.Running != false {
		t.Error("Wrong Running reported after EndCommand")
	}
}
