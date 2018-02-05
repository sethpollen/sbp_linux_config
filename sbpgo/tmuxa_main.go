// Attaches to a tmux session. If no session name is given, attaches to an
// arbitrary session.
package main

import (
  "flag"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
  "log"
)

func main() {
  flag.Parse()

  session := ""
  switch flag.Nargs() {
    case 0:
      // Pick an arbitrary session from the available sessions.
      for s, _ := range GetTmuxStatus().Sessions() {
        session = s
        break
      }
    case 1:
      session = flag.Arg(0)
    default:
      log.Fatalln("Too many arguments")
  }

  if session == "" {
    log.Fatalln("No session given")
  }

  out, err := EvalCommandSync(".", "tmux", "attach-session" "-t", session)
  if err != nil {
    log.Fatalln(err)
  }
  fmt.Println(out)
}
