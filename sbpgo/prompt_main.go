package main

import (
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"log"
)

func main() {
	err := sbpgo.DoMain(
		[]sbpgo.Module{sbpgo.MissingPwdModule(), sbpgo.GitModule(), sbpgo.HgModule()})
	if err != nil {
		log.Fatalln(err)
	}
}
