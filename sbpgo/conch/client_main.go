// Simple binary to use for interacting with the Conch server.
package main

import (
	"flag"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/sbpgo/conch"
  "os"
  "strconv"
)

var shellPid = flag.Int("shell_pid", -1,
	"PID of the shell process.")
var serverSocket = flag.String("server_socket", conch.ServerSocketPath,
	"Path to the Unix domain socket to use for talking to the server.")
var rpc = flag.String("rpc", "",
	"RPC to make to the server. Supported RPCs: BeginCommand, EndCommand, "+
		"ListShells.")

var pwd = flag.String("pwd", "",
  "PWD string. Required when --rpc is BeginCommand or EndCommand.")
var command = flag.String("command", "",
	"Command string. Required when --rpc is BeginCommand.")
var exitCode = flag.String("exit_code", "",
  "Exit code of last command. Required when --rpc is EndCommand.")
var hideMyShell = flag.Bool("hide_my_shell", true,
	"If true, ListShells will not display its own containing shell.")

func fail(a ...interface{}) {
  fmt.Println(a...);
  os.Exit(1)
}

func main() {
	flag.Parse()

	if *shellPid < 0 {
		fail("--shell_pid must be nonnegative")
	}
	client, err := conch.NewClient(*shellPid, *serverSocket)
	if err != nil {
		fail(err)
	}

	switch *rpc {
	case "BeginCommand":
		if len(*command) == 0 {
			fail("--command not provided")
		}
		if len(*pwd) == 0 {
			fail("--pwd not provided")
		}
		err = client.BeginCommand(*pwd, *command)
		if err != nil {
			fail(err)
		}

	case "EndCommand":
    if len(*pwd) == 0 {
      fail("--pwd not provided")
    }
    if len(*exitCode) == 0 {
      fail("--exit_code not provided")
    }
    numericExitCode, err := strconv.Atoi(*exitCode)
    if err != nil {
      fail("--exit_code must be an integer")
    }
		err = client.EndCommand(*pwd, numericExitCode)
		if err != nil {
			fail(err)
		}

	case "ListShells":
		shells, err := client.ListShells()
		if err != nil {
			fail(err)
		}
		for _, shell := range shells {
			if *hideMyShell && shell.Id.Pid == *shellPid {
        continue
      }
      fmt.Printf("Shell %v:\n  Pwd: %v\n", shell.Id.Pid, shell.Info.Pwd)
      if shell.Info.Running {
        fmt.Printf("  Running: %v\n", shell.Info.LatestCommand)
      } else if len(shell.Info.LatestCommand) > 0 {
        fmt.Printf("  Done: %v\n", shell.Info.LatestCommand)
        if shell.Info.ExitCode != 0 {
          fmt.Printf("  Exit code: %v\n", shell.Info.ExitCode)
        }
      }
		}

	default:
		fail("Unrecognized --rpc: ", *rpc)
	}
}
