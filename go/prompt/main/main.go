package main

import "log"
import "github.com/sethpollen/sbp_linux_config/go/git"
import "github.com/sethpollen/sbp_linux_config/go/hg"
import "github.com/sethpollen/sbp_linux_config/go/prompt"

func main() {
	err := prompt.DoMain([]prompt.Module{git.Module(), hg.Module()}, nil)
	if err != nil {
		log.Fatalln(err)
	}
}
