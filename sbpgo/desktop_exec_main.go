// This program is used to spawn applications from the desktop. It provides
// my familiar environment variables and also logs output to ~/log.

package main

import (
  "github.com/sethpollen/sbp_linux_config/sbpgo"
  "log"
  "io"
  "os"
  "os/exec"
  "path"
  "regexp"
  "strings"
)

func main() {
  var home = os.Getenv("HOME")
  if len(home) == 0 {
    log.Fatalln("No $HOME")
  }
  
  // Source the standard environment.
  env, err := sbpgo.StandardEnviron()
  if err != nil {
    log.Fatalln(err)
  }
  env.Apply()
  
  // Spawn the subprocess.
  var program = os.Args[1:]
  if len(program) == 0 {
    log.Fatalln("No program specified")
  }
  
  cmd := exec.Command(program[0], program[1:]...)
  cmd.Stdin = os.Stdin
  
  stdout, err := cmd.StdoutPipe()
  if err != nil {
    log.Fatalln(err)
  }

  stderr, err := cmd.StderrPipe()
  if err != nil {
    log.Fatalln(err)
  }
  
  // Construct a safe filename for the log files, based on the program being
  // invoked.
  var filename = strings.Join(cmd.Args, "-")
  var re = regexp.MustCompile("[^A-Za-z0-9_\\-\\.]")
  filename = re.ReplaceAllLiteralString(filename, "-")
  filename = path.Join(home, "log", filename)

  stdoutFile, err := os.Create(filename + ".stdout")
  if err != nil {
    log.Fatalln(err)
  }

  stderrFile, err := os.Create(filename + ".stderr")
  if err != nil {
    log.Fatalln(err)
  }

  err = cmd.Start()
  if err != nil {
    log.Fatalln(err)
  }

  // Spawn goroutines to copy text from the subprocess's stdout and stderr streams.
  go tee(stdout, os.Stdout, stdoutFile)
  go tee(stderr, os.Stderr, stderrFile)

  err = cmd.Wait()
  if err != nil {
    log.Fatalln(err)
  }
}

func tee(in io.Reader, out1, out2 io.WriteCloser) {
  var buf = make([]byte, 4096)
  
  for {
    bytes, readErr := in.Read(buf)
    
    var data = buf[:bytes]
    _, writeErr1 := out1.Write(data)
    _, writeErr2 := out2.Write(data)
    
    if readErr != nil || writeErr1 != nil || writeErr2 != nil {
      break
    }
  }
  
  out1.Close()
  out2.Close()
}
