package conch_test

import (
	"errors"
	"os"
	"testing"
	"time"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo/conch"

const testSocketPath = "/tmp/sbp_conch_test.sock"

func openClient(myPid int, socketPath string) (*Client, error) {
	start := time.Now()
	var client *Client
	var err error
	for {
		client, err = NewClient(myPid, socketPath)
		if err == nil {
			return client, nil
		}
		if time.Now().Sub(start) > 10*time.Second {
			return nil, errors.New("Waited too long for server to come up")
		}
		time.Sleep(time.Millisecond)
	}
}

func TestBasicRpcs(t *testing.T) {
	go RunServer(testSocketPath)
	myPid := os.Getpid()

	client, err := openClient(myPid, testSocketPath)
	if err != nil {
		t.Error(err)
	}

	beginTime := time.Now()
	err = client.BeginCommand("/home", "ls")
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
	if shells[0].Info.ExitCode != 0 {
		t.Error("Wrong ExitCode reported")
	}
	if shells[0].Info.Pwd != "/home" {
		t.Error("Wrong Pwd reported")
	}
	if shells[0].Info.Time.Before(beginTime) {
		t.Error("Wrong Time reported")
	}

	endTime := time.Now()
	err = client.EndCommand("/home2", 89)
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
	if shells[0].Info.ExitCode != 89 {
		t.Error("Wrong ExitCode reported")
	}
	if shells[0].Info.Pwd != "/home2" {
		t.Error("Wrong Pwd reported")
	}
	if shells[0].Info.Time.Before(endTime) {
		t.Error("Wrong Time reported")
	}
}
