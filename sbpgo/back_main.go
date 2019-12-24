package main

import (
	"github.com/sethpollen/sbp_linux_config/sbpgo"
  "os/user"
  "path"
)

// TODO: need to wrap this in a shell script to call less when displaying
// output.
//
//   less +G --RAW-CONTROL-CHARS
//
// Need something like -F to avoid invoking less if there is no output.

func home() string {
  user, err := user.Current()
  if err != nil {
    panic(err)
  }
  return path.Join(user.HomeDir, ".back")
}

func main() {
  sbpgo.BackMain(home(), true)
}
