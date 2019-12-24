// When running in a unit test, use the local directory instead of trying
// to access $HOME.

package main

import (
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"os"
)

func main() {
  sbpgo.BackMain(os.Getenv("TEST_TMPDIR"))
}
