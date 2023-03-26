package main

import (
	"fmt"
	"github.com/sethpollen/sbp_linux_config/back"
	"github.com/sethpollen/sbp_linux_config/format_percent"
	"github.com/sethpollen/sbp_linux_config/i3_gateway"
	"github.com/sethpollen/sbp_linux_config/i3blocks_pad"
	"github.com/sethpollen/sbp_linux_config/i3blocks_recolor"
	"github.com/sethpollen/sbp_linux_config/network_usage"
	"github.com/sethpollen/sbp_linux_config/prompt"
	"github.com/sethpollen/sbp_linux_config/sleep"
	"log"
	"os"
	"os/user"
	"path"
)

// Single entry point for all of my Go programs. This makes it easier to install
// the suite. Each program is pretty small, so the overall binary size
// continues to be dominated by the 2 MiB of Go runtime.

func backHome() string {
	user, err := user.Current()
	if err != nil {
		log.Fatalln(err)
		return ""
	}
	return path.Join(user.HomeDir, ".back")
}

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "No subcommand")
		os.Exit(1)
	}
	var subcommand = os.Args[1]
	os.Args = os.Args[1:]

	switch subcommand {

	case "prompt":
		prompt.Main()

	case "back":
		back.Main(backHome(), true)

	case "format_percent":
		format_percent.Main()

	case "network_usage":
		network_usage.Main()

	case "sleep":
		sleep.Main()

	case "i3blocks_pad":
		i3blocks_pad.Main()

	case "i3blocks_recolor":
		i3blocks_recolor.Main()

	case "i3_gateway":
		i3_gateway.Main()

	default:
		fmt.Fprintln(os.Stderr, "Unrecognized subcommand:", subcommand)
		os.Exit(1)
	}
}
