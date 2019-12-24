// When running in a unit test, use the local directory instead of trying
// to access $HOME.

package main

import (
	"github.com/sethpollen/sbp_linux_config/sbpgo"
)

func main() {
  sbpgo.BackMain("/dev/shm/sbp-back_main_test")
}
