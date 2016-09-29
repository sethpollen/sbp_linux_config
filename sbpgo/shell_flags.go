// Common flags for shell utilities.
package sbpgo

import (
	"flag"
)

var shellPid = flag.Int("shell_pid", -1,
	"PID of the shell process. If not set, we won't interact with the Conch "+
		"server.")
var exitCode = flag.Int("exitcode", 0,
	"Exit code of previous command. If absent, 0 is assumed.")

func ShellPidFlag() int {
	return *shellPid
}

func ExitCodeFlag() int {
	return *exitCode
}
