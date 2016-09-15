package main

import "log"
import . "github.com/sethpollen/sbp_linux_config/sbpgo"

func main() {
	err := DoMain([]Module{GitModule(), HgModule()}, nil)
	if err != nil {
		log.Fatalln(err)
	}
}
