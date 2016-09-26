package main

import (
	"github.com/sethpollen/sbp_linux_config/sbpgo/conch"
)

func main() {
	conch.RunServer(conch.ServerSocketPath)
}
