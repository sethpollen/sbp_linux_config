package main

import (
	"github.com/sethpollen/sbp_linux_config/sbpgo"
  "os/user"
  "path"
)

func home() string {
  user, err := user.Current()
  if err != nil {
    panic(err)
  }
  return path.Join(user.HomeDir, ".back")
}

func main() {
  sbpgo.BackMain(home())
}
