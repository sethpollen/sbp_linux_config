// Common flags for shell utilities.
package sbpgo

import (
	"flag"
  "log"
)

var exitCode = flag.Int("exitcode", 0,
	"Exit code of previous command. If absent, 0 is assumed.")

// TODO: remove posix support
var shellType = flag.String("shell_type", "posix",
  "Shell type, which informs export syntax. Accepted values are 'posix' and "+
  "'fish'.")

func ExitCodeFlag() int {
	return *exitCode
}

func ShellTypeFlag() string {
	s := *shellType
  if s == "posix" || s == "fish" {
    return s
  }
  log.Fatalln("Unexpected shell_type:", s)
  return ""
}
