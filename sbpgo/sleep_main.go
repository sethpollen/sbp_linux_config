package main

import (
	"flag"
	"fmt"
  "github.com/sethpollen/sbp_linux_config/sbpgo"
	"os"
	"time"
)

var bell = flag.Bool("bell", false,
	"Whether to send an ASCII bell after we finish sleeping.")

func main() {
	flag.Parse()
	if len(flag.Args()) == 0 {
		fmt.Println("Expected duration")
		os.Exit(1)
		return
	}
	duration, err := time.ParseDuration(flag.Arg(0))
	if err != nil {
		fmt.Printf("Could not parse \"%v\" as a duration: %v\n", flag.Arg(0), err)
		os.Exit(2)
		return
	}
	sbpgo.VerboseSleep(duration, *bell)
}
