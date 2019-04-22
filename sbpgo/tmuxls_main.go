// Lists open tmux sessions.
package main

import (
	"flag"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"sort"
)

var oneLine = flag.Bool("one_line", false,
	"True to produce a compressed one-line output.")

func main() {
	flag.Parse()

	tmuxStatus := sbpgo.GetTmuxStatus()
	sessions := tmuxStatus.Sessions()

	sort.Strings(sessions)

	if *oneLine {
		for i, session := range sessions {
			if i != 0 {
				fmt.Print(" ")
			}
			fmt.Print(session)
		}
		fmt.Println()
		return
	}

	for _, session := range sessions {
		fmt.Print(session)

	  if session == tmuxStatus.AttachedSession() {
		  fmt.Print(" *")
		}

		fmt.Println()
	}
}
