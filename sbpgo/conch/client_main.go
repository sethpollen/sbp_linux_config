// Simple binary to use for interacting with the Conch server.

package main

import "flag"
import "fmt"
import "os"
import . "github.com/sethpollen/sbp_linux_config/sbpgo/conch"

var shellPid = flag.Int("shell_pid", -1,
	"PID of the shell process.")
var serverSocket = flag.String("server_socket", ServerSocketPath,
	"Path to the Unix domain socket to use for talking to the server.")
var rpc = flag.String("rpc", "",
	"RPC to make to the server. Supported RPCs: BeginCommand, EndCommand, "+
		"ListShells.")
var command = flag.String("command", "",
	"Command string. Required when --rpc is BeginCommand.")
var pwd = flag.String("pwd", "",
	"PWD string. Required when --rpc is BeginCommand or EndCommand.")
var hideInactiveShells = flag.Bool("hide_inactive_shells", false,
	"If true, ListShells will only show shells which have a running command.")

func main() {
	flag.Parse()

	if *shellPid < 0 {
		fmt.Println("--shell_pid must be nonnegative")
		os.Exit(1)
	}
	client, err := NewClient(*shellPid, *serverSocket)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	switch *rpc {
	case "BeginCommand":
		if len(*command) == 0 {
			fmt.Println("--command not provided")
			os.Exit(1)
		}
		if len(*pwd) == 0 {
			fmt.Println("--pwd not provided")
			os.Exit(1)
		}
		err = client.BeginCommand(*command, *pwd)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

	case "EndCommand":
		if len(*pwd) == 0 {
			fmt.Println("--pwd not provided")
			os.Exit(1)
		}
		err = client.EndCommand(*pwd)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

	case "ListShells":
		shells, err := client.ListShells()
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		for _, shell := range shells {
			if shell.Info.Running || !*hideInactiveShells {
				fmt.Printf("Shell %v:\n  Pwd: %v\n", shell.Id.Pid, shell.Info.Pwd)
				if shell.Info.Running {
					fmt.Printf("  Running: %v\n", shell.Info.LatestCommand)
				} else if len(shell.Info.LatestCommand) > 0 {
					fmt.Printf("  Done: %v\n", shell.Info.LatestCommand)
				}
			}
		}

	default:
		fmt.Println("Unrecognized --rpc: ", *rpc)
		os.Exit(1)
	}
}
