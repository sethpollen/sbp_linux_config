// A very simple binary which succeeds iff this is a corp host.

package main

import (
  "fmt"
	"github.com/sethpollen/sbp_linux_config/hosts"
	"log"
	"os"
)

func main() {
	hostname, err := hosts.GetHostname()
	if err != nil {
		log.Fatalln(err)
	}

	if hosts.IsCorp(hostname) {
		// Succeed.
    fmt.Printf("%s is corp\n", hostname)
		os.Exit(0)
	} else {
		// Fail.
    fmt.Printf("%s is not corp\n", hostname)
		os.Exit(1)
	}
}
