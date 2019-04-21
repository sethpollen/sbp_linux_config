// Common flags for shell utilities.
package sbpgo

import (
	"flag"
)

var exitCode = flag.Int("exitcode", 0,
	"Exit code of previous command. If absent, 0 is assumed.")

func ExitCodeFlag() int {
	return *exitCode
}
