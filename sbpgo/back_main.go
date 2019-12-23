package main

import (
  "bytes"
  "fmt"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
  "log"
  "os"
  "os/user"
  "path"
  "sort"
  "strings"
)

// TODO: fail if too many args are supplied

func home() string {
  user, err := user.Current()
  if err != nil {
    log.Fatalln(err)
  }
  return path.Join(user.HomeDir, ".back")
}

func subcommand() string {
  if len(os.Args) < 2 {
    fmt.Println("No subcommand. Try one of these:")
    fmt.Println("  ls fork join peek kill")
    os.Exit(1)
  }
  return os.Args[1]
}

func job() string {
  if len(os.Args) < 3 {
    fmt.Println("No job specified")
    os.Exit(1)
  }
  return os.Args[2]
}

func main() {
  switch subcommand() {
    case "ls":
      ls()
    case "fork":
      fork()
    case "join":
      join()
    case "peek":
      peek()
    case "kill":
      kill()
    default:
      fmt.Println("Unrecognized subcommand: " + subcommand())
      os.Exit(1)
  }
}

func ls() {
  futures, err := sbpgo.ListFutures(home())
  if err != nil {
    log.Fatalln(err)
  }

  var complete []string
  var running []string

  for _, f := range futures {
    if f.Complete {
      complete = append(complete, f.Name)
    } else {
      running = append(running, f.Name)
    }
  }

  sort.Strings(complete)
  sort.Strings(running)

  for _, f := range complete {
    fmt.Println(f + " *")
  }
  for _, f := range running {
    fmt.Println(f)
  }
}

func fork() {
  f := sbpgo.OpenFuture(home(), job())
  program := strings.Join(os.Args[3:], " ")
  // Notify all fish shells when done, so they can update their 'back'
  // indicator.
  f.Start(program, true, nil)
}

func join() {
  f := sbpgo.OpenFuture(home(), job())
  output, err := f.Reclaim()
  if err != nil {
    log.Fatalln(err)
  }
  displayOutput(output)
}

func peek() {
  f := sbpgo.OpenFuture(home(), job())
  output, err := f.Peek()
  if err != nil {
    log.Fatalln(err)
  }
  displayOutput(output)
}

func kill() {
  f := sbpgo.OpenFuture(home(), job())
  err := f.Kill()
  if err != nil {
    log.Fatalln(err)
  }
  join()
}

func displayOutput(output []byte) {
  // TODO: just dump it all to stdout, and write a shell wrapper to display
  // it nicely with 'less'.
}
