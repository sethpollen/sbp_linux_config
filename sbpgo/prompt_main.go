package main

import (
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"log"
)

func main() {
	err := sbpgo.DoMain(
		[]sbpgo.Module{sbpgo.GitModule(), sbpgo.HgModule()},
		nil)
	if err != nil {
		log.Fatalln(err)
	}
}
