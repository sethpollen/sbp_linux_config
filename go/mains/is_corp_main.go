// A very simple binary which succeeds iff this is a corp host.

package main

import (
	"github.com/sethpollen/sbp_linux_config/hosts"
	"log"
	"os"
)

func main() {
	hostname, err := os.Hostname()
	if err != nil {
		log.Fatalln(err)
	}

	if hosts.IsCorp(hostname) {
		// Succeed.
		os.Exit(0)
	} else {
		// Fail.
		os.Exit(1)
	}
}
