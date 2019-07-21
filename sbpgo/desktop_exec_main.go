// This program is used to spawn applications from the desktop. It provides
// my familiar environment variables and also logs output to ~/log.

package main

import (
	"flag"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"io"
	"log"
	"os"
	"os/exec"
	"path"
	"regexp"
	"strings"
)

var logging = flag.Bool("logging", false,
	"Whether to emit stdout and stderr log files")

func main() {
  flag.Parse()

	// Source the standard environment.
	env, err := sbpgo.StandardEnviron()
	if err != nil {
		log.Fatalln(err)
	}
	env.Apply()

	// Spawn the subprocess.
	var program = flag.Args()
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

	// Spawn goroutines to copy text from the subprocess's stdout and stderr
	// streams.
  if *logging {
    logFiles := openLogFiles(cmd)
	  go tee(stdout, os.Stdout, logFiles.Stdout)
	  go tee(stderr, os.Stderr, logFiles.Stderr)
  } else {
    // Just copy to the parent processes stderr/stdout.
	  go tee(stdout, os.Stdout)
	  go tee(stderr, os.Stderr)
  }

	err = cmd.Start()
	if err != nil {
		log.Fatalln(err)
	}

	err = cmd.Wait()
	if err != nil {
		log.Fatalln(err)
	}
}

type logFiles struct {
  Stdout io.WriteCloser
  Stderr io.WriteCloser
}

func openLogFiles(cmd *exec.Cmd) logFiles {
  var err error

	var home = os.Getenv("HOME")
	if len(home) == 0 {
		log.Fatalln("No $HOME")
	}

	var homeLog = path.Join(home, "log")
	err = os.MkdirAll(homeLog, os.ModeDir|0755)
	if err != nil {
		log.Fatalln(err)
	}

	// Construct a safe filename for the log files, based on the program being
	// invoked.
	var filename = strings.Join(cmd.Args, "-")
	var re = regexp.MustCompile("[^A-Za-z0-9_\\-\\.]")
	filename = re.ReplaceAllLiteralString(filename, "-")
	filename = strings.TrimLeft(filename, "-")
	filename = path.Join(homeLog, filename)

	stdoutFile, err := os.Create(filename + ".stdout.log")
	if err != nil {
		log.Fatalln(err)
	}

	stderrFile, err := os.Create(filename + ".stderr.log")
	if err != nil {
		log.Fatalln(err)
	}

  return logFiles{stdoutFile, stderrFile}
}

func tee(in io.Reader, outs ...io.WriteCloser) {
	var buf = make([]byte, 16 * 1024)
  var err error

	for err == nil {
		bytes, err := in.Read(buf)
		var data = buf[:bytes]

    // Distribute the bytes to as many outs as possible.
    for _, out := range outs {
		  _, writeErr := out.Write(data)
      if err == nil && writeErr != nil {
        err = writeErr
      }
    }
	}

  for _, out := range outs {
	  out.Close()
  }
}
