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

	var sorted []string
	for session, _ := range sessions {
		sorted = append(sorted, session)
	}
	sort.Strings(sorted)

	if *oneLine {
		for i, session := range sorted {
			if i != 0 {
				fmt.Print(" ")
			}
			fmt.Print(session)
		}
		fmt.Println()
		return
	}

	for _, session := range sorted {
		fmt.Print(session)

		attached := (session == tmuxStatus.AttachedSession())
		attention := sessions[session]

		if attached || attention {
			fmt.Print(" ")
			if attached {
				fmt.Print("*")
			}
			if attention {
				fmt.Print("!")
			}
		}

		fmt.Println()
	}
}
