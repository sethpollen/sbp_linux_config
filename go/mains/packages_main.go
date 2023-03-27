// Prints out the list (space-separated) of apt packages which should be
// installed for the current host.

package main

import (
	"fmt"
	"github.com/sethpollen/sbp_linux_config/hosts"
	"log"
	"os"
	"path"
	"strings"
)

func main() {
	hostname, err := os.Hostname()
	if err != nil {
		log.Fatalln(err)
	}

	installSrcDirs, err := hosts.GetInstallSrcDirs(hostname)
	if err != nil {
		log.Fatalln(err)
	}

	// Find packages listed by each directory in installSrcDirs.
	for _, srcDir := range installSrcDirs {
		text, err := os.ReadFile(path.Join(srcDir, "packages"))
		if os.IsNotExist(err) {
			// This directory doesn't list any packages. That's fine.
			continue
		}
		if err != nil {
			log.Fatalln(err)
		}

		for _, packageName := range strings.Fields(string(text)) {
			fmt.Print(packageName + " ")
		}
	}
}
