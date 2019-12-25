// A command-line wrapper around future.go.

package sbpgo

import (
  "fmt"
  "os"
  "sort"
  "strings"
)

func subcommand() string {
  if len(os.Args) < 2 {
    fmt.Fprintln(os.Stderr, "No subcommand. Try one of these:")
    fmt.Fprintln(os.Stderr, "  ls ls_nostar start peek poll reclaim kill")
    os.Exit(1)
  }
  return os.Args[1]
}

func job() string {
  if len(os.Args) < 3 {
    fmt.Fprintln(os.Stderr, "No job specified")
    os.Exit(1)
  }
  return os.Args[2]
}

func BackMain(home string, interactive bool) {
  switch subcommand() {
    case "ls":
      ls(home, true)
      return
    // Intended for use by scripts, but not in interactive mode.
    case "ls_nostar":
      ls(home, false)
      return
    case "start":
      start(home, interactive)
      return
  }

  // All other subcommands take a job name and nothing else.
  f := OpenFuture(home, job())
  checkExtraArgs(3)

  var err error
  switch subcommand() {
    case "peek":
      err = f.Peek(os.Stdout)
    case "poll":
      err = f.Poll()
    case "reclaim":
      err = f.Reclaim()
    case "kill":
      err = f.Kill()
    default:
      fmt.Fprintln(os.Stderr, "Unrecognized subcommand: " + subcommand())
      os.Exit(1)
  }

  handle(err)
}

func checkExtraArgs(expectedArgs int) {
  if len(os.Args) > expectedArgs {
    fmt.Fprintln(os.Stderr, "Too many args: " + strings.Join(os.Args[expectedArgs:], " "))
    os.Exit(1)
  }
}

func handle(err error) {
  if err == nil {
    return
  }

  if IsJobNotExist(err) || IsJobAlreadyExist(err) || IsJobStillRunning(err) {
    fmt.Fprintln(os.Stderr, err.Error())
    os.Exit(2)
  }

  panic(err)
}

func ls(home string, star bool) {
  checkExtraArgs(2)

  futures, err := ListFutures(home)
  handle(err)

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

  var starStr string
  if star {
    starStr = " *"
  }

  for _, f := range complete {
    fmt.Println(f + starStr)
  }
  for _, f := range running {
    fmt.Println(f)
  }
}

func start(home string, interactive bool) {
  f := OpenFuture(home, job())
  program := strings.Join(os.Args[3:], " ")

  err := f.Start(program, interactive, nil)
  handle(err)
}

