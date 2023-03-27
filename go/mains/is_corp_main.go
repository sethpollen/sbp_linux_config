// A very simple binary which succeeds iff this is a corp host.

package main

import (
    "github.com/sethpollen/sbp_linux_config/hosts"
    "log"
    "os"
)

func main() {
    hostIsCorp, err := hosts.IsCorp()
    if err != nil {
        log.Fatalln(err)
    }
    if hostIsCorp {
        // Succeed.
        os.Exit(0)
    } else {
        // Fail.
        os.Exit(1)
    }
}
