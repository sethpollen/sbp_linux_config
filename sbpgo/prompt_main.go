package main

import "log"
import "github.com/sethpollen/sbp_linux_config/sbpgo"

func main() {
	err := sbpgo.DoMain(
		[]sbpgo.Module{sbpgo.GitModule(), sbpgo.HgModule()},
		nil)
	if err != nil {
		log.Fatalln(err)
	}
}
