// A command-line wrapper around future.go.

package sbpgo

import (
  "fmt"
  "os"
  "sort"
  "strings"
)

// TODO: fail if too many args are supplied

func subcommand() string {
  if len(os.Args) < 2 {
    fmt.Fprintln(os.Stderr, "No subcommand. Try one of these:")
    fmt.Fprintln(os.Stderr, "  ls fork join peek kill")
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
      ls(home)
    // Intended for use by scripts, but not in interactive mode.
    case "ls_completed":
      lsCompleted(home)
    case "fork":
      fork(home, interactive)
    case "join":
      join(home)
    case "peek":
      peek(home)
    case "kill":
      kill(home)
    default:
      fmt.Fprintln(os.Stderr, "Unrecognized subcommand: " + subcommand())
      os.Exit(1)
  }
}

func ls(home string) {
  futures, err := ListFutures(home)
  if err != nil {
    panic(err)
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

func lsCompleted(home string) {
  futures, err := ListFutures(home)
  if err != nil {
    panic(err)
  }

  var complete []string

  for _, f := range futures {
    if f.Complete {
      complete = append(complete, f.Name)
    }
  }

  sort.Strings(complete)

  for _, f := range complete {
    fmt.Println(f)
  }
}

func fork(home string, interactive bool) {
  f := OpenFuture(home, job())
  program := strings.Join(os.Args[3:], " ")
  // Notify all fish shells when done, so they can update their 'back'
  // indicator.
  err := f.Start(program, interactive, nil)
  if err != nil {
    panic(err)
  }
}

func join(home string) {
  f := OpenFuture(home, job())
  err := f.Reclaim(os.Stdout)
  if err != nil {
    if _, ok := err.(JobNotExistError); ok {
      fmt.Fprintln(os.Stderr, err.Error())
      os.Exit(2)
    }
    if _, ok := err.(JobStillRunningError); ok {
      fmt.Fprintln(os.Stderr, err.Error())
      os.Exit(2)
    }
    panic(err)
  }
}

func peek(home string) {
  f := OpenFuture(home, job())
  err := f.Peek(os.Stdout)
  if err != nil {
    if _, ok := err.(JobNotExistError); ok {
      fmt.Fprintln(os.Stderr, err.Error())
      os.Exit(2)
    }
    panic(err)
  }
}

func kill(home string) {
  f := OpenFuture(home, job())
  err := f.Kill()
  if err != nil {
    if _, ok := err.(JobNotExistError); ok {
      fmt.Fprintln(os.Stderr, err.Error())
      os.Exit(2)
    }
    panic(err)
  }
  join(home)
}
