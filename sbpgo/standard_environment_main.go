// This program prints out a shell script which, when sourced, will set up my
// standard environment variables.

package main

import (
  "github.com/sethpollen/sbp_linux_config/sbpgo"
  "fmt"
  "log"
)

func main() {
  env, err := sbpgo.StandardEnviron()
  if err != nil {
    log.Fatalln(err)
  }
  fmt.Println(env.ToScript())
}
