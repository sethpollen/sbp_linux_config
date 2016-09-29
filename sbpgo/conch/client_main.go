// Simple binary to use for interacting with the Conch server.
package main

// TODO: Link in the prompt library and format the prompt string for each
// shell shown. This should include lots of useful info and colors!

import (
	"flag"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"github.com/sethpollen/sbp_linux_config/sbpgo/conch"
	"os"
	"strings"
)

var serverSocket = flag.String("server_socket", conch.ServerSocketPath,
	"Path to the Unix domain socket to use for talking to the server.")
var rpc = flag.String("rpc", "",
	"RPC to make to the server. Supported RPCs: BeginCommand, EndCommand, "+
		"ListShells.")
var color = flag.Bool("color", true,
	"Whether to colorize the output.")

// Flags specific to individual RPC types.
var pwd = flag.String("pwd", "",
	"PWD string. Required when --rpc is BeginCommand or EndCommand.")
var command = flag.String("command", "",
	"Command string. Required when --rpc is BeginCommand.")
var hideMyShell = flag.Bool("hide_my_shell", true,
	"If true, ListShells will not display its own containing shell.")

// We also use flags from shell_flags.go.

func fail(a ...interface{}) {
	fmt.Println(a...)
	os.Exit(1)
}

func main() {
	flag.Parse()

	shellPid := sbpgo.ShellPidFlag()
	if shellPid < 0 {
		fail("--shell_pid must be nonnegative")
	}
	client, err := conch.NewClient(shellPid, *serverSocket)
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
		err = client.EndCommand(*pwd, sbpgo.ExitCodeFlag())
		if err != nil {
			fail(err)
		}

	case "ListShells":
		shells, err := client.ListShells()
		if err != nil {
			fail(err)
		}

		var lines []string = make([]string, 0, len(shells))
		for _, shell := range shells {
			if *hideMyShell && shell.Id.Pid == shellPid {
				continue
			}
			styledLine := formatShellDesc(&shell)
			var line string
			if *color {
				line = styledLine.String(false)
			} else {
				line = styledLine.PlainString()
			}
			lines = append(lines, line)
		}

		fmt.Print(strings.Join(lines, "\n"))

	default:
		fail("Unrecognized --rpc: ", *rpc)
	}
}

func formatShellDesc(shell *conch.ShellDesc) sbpgo.StyledString {
	var text sbpgo.StyledString

	text = append(text, sbpgo.Unstyled(fmt.Sprintf(
		"Shell %v:\n  Pwd: %v\n", shell.Id.Pid, shell.Info.Pwd))...)

	if shell.Info.Running {
		text = append(text, sbpgo.Unstyled(fmt.Sprintf(
			"  Running: %v\n", shell.Info.LatestCommand))...)

	} else if len(shell.Info.LatestCommand) > 0 {
		if shell.Info.ExitCode == 0 {
			text = append(text, sbpgo.Stylize("  Done:", sbpgo.Yellow, sbpgo.Bold)...)
		} else {
			text = append(text, sbpgo.Stylize(fmt.Sprintf(
				"  Done(%d):", shell.Info.ExitCode), sbpgo.Red, sbpgo.Bold)...)
		}

		text = append(text, sbpgo.Unstyled(fmt.Sprintf(
			" %v\n", shell.Info.LatestCommand))...)
	}

	return text
}
