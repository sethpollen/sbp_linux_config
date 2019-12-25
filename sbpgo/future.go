// Implements futures back by out-of-process background work.

package sbpgo

import (
  "fmt"
  "io"
  "io/ioutil"
  "os"
  "os/exec"
  "path"
  "strconv"
  "time"
)

type FutureStat struct {
  Name string
  Complete bool
}

// Lists all futures, including completed ones not yet reclaimed.
func ListFutures(home string) ([]FutureStat, error) {
  err := ensureDir(home)
  if err != nil {
    return nil, err
  }

  children, err := ioutil.ReadDir(home)
  if err != nil {
    return nil, err
  }

  var futures []FutureStat
  for _, child := range children {
    if !child.IsDir() {
      continue
    }
    name := child.Name()

    f := OpenFuture(home, name)
    complete, err := f.isComplete()
    if err != nil {
      return nil, err
    }

    futures = append(futures, FutureStat{name, complete})
  }
  return futures, nil
}

type Future struct {
  home string
  name string
}

func OpenFuture(home string, name string) Future {
  return Future{home, name}
}

type JobNotExistError struct {
  name string
}
func (self JobNotExistError) Error() string {
  return "Job does not exist: " + self.name
}

type JobStillRunningError struct {
  name string
}
func (self JobStillRunningError) Error() string {
  return "Job still running: " + self.name
}


// Starts the given future by spawning 'cmd' in the background. 'interactive'
// determines whether the output will be dressed up with command-line prompts.
// Once the command completes, we will send SIGUSR1 to 'redrawPid', or to all
// running fish shells if 'redrawPid' is nil.
func (self Future) Start(cmd string, interactive bool, redrawPid *int) error {
  err := ensureDir(self.myHome())
  if err != nil {
    return err
  }

  // Make sure the output file always exists, even if dtach dies before writing
  // it.
  _, err = os.Create(self.outputFile())
  if err != nil {
    return err
  }

  // Build up the program to be passed to dtach (via fish).
  var program = "begin\n"

  if interactive {
    program += "sbp-prompt --width=$COLUMNS --output=fish_prompt\n"
    program += "set_color $fish_color_command\n"
    program += "echo " + strconv.Quote(cmd) + "\n"
    program += "set_color normal\n"
  }

  // Wrap the cmd in another fish shell to avoid any weird syntax interaction.
  program += "fish -c " + strconv.Quote(cmd) + "\n"

  if interactive {
    program += "sbp-prompt --width=$COLUMNS --output=fish_prompt " +
               "--exit_code=$status --dollar=false\n"
  }

  program += "end </dev/null >" + strconv.Quote(self.outputFile()) + " 2>&1\n"
  program += "touch " + strconv.Quote(self.doneFile()) + "\n"

  if redrawPid |= nil {
    program += "kill -USR1 " + fmt.Sprintf("%d", *redrawPid) + "\n"
  }

  // Spawn the program in the background.
  dtach := exec.Command(
    "dtach", "-n", self.socketFile(), "-E", "fish", "-c", program)
  output, err := dtach.CombinedOutput()
  if err != nil {
    return fmt.Errorf("Failed to start dtach.\nerr: %v\noutput:\n%s",
                      err, output)
  }

  return nil
}

// Copies all output produced so far into 'sink'.
func (self Future) Peek(sink io.Writer) error {
  err := self.checkExists()
  if err != nil {
    return err
  }

  f, err := os.Open(self.outputFile())
  if err != nil {
    return err
  }

  _, err = io.Copy(sink, f)
  if err != nil {
    return err
  }

  return nil
}

// If the background task has completed, copies its output to 'sink' and then
// deletes all of its state. Otherwise returns an error.
func (self Future) Reclaim(sink io.Writer) error {
  err := self.checkExists()
  if err != nil {
    return err
  }

  complete, err := self.isComplete()
  if err != nil {
    return err
  }
  if !complete {
    return JobStillRunningError{self.name}
  }

  err = self.Peek(sink)
  if err != nil {
    return err
  }

  err = os.RemoveAll(self.myHome())
  if err != nil {
    return err
  }

  return nil
}

// Forcibly terminates the background task, leaving it completed but not
// reclaimed.
func (self Future) Kill() error {
  err := self.checkExists()
  if err != nil {
    return err
  }

  var pattern = "dtach -n " + self.socketFile()

  // We delegate all the hard work to pkill and pgrep. We kill only the dtach
  // process using our socket.
  pkill := exec.Command("pkill", "--full", pattern)
  err = pkill.Run()
  if err != nil {
    // pkill exits with 1 if it couldn't find anything to kill.
    if pkill.ProcessState.ExitCode() == 1 {
      // Return with success. Maybe we just raced with the job shutting down
      // on its own.
      return nil
    }
    return err
  }

  // Wait for the job to truly exit.
  for ;; {
    pgrep := exec.Command("pgrep", "--full", pattern)
    err = pgrep.Run()
    if err != nil {
      if pgrep.ProcessState.ExitCode() == 1 {
        // The dtach process is gone.
        return nil
      }
      return err
    }

    // The process is still running. Loop around again.
    time.Sleep(10 * time.Millisecond)
  }
}

///////////////////////////////////////////////////////////////////////////////
// Implementation details.

func ensureDir(d string) error {
  return os.MkdirAll(d, 0777)
}

func (self Future) myHome() string {
  return path.Join(self.home, self.name)
}

func (self Future) outputFile() string {
  return path.Join(self.myHome(), "output")
}

func (self Future) socketFile() string {
  return path.Join(self.myHome(), "socket")
}

func (self Future) doneFile() string {
  return path.Join(self.myHome(), "done")
}

func (self Future) checkExists() error {
  exists, err := DirExists(self.myHome())
  if err != nil {
    return err
  }
  if !exists {
    return JobNotExistError{self.name}
  }
  return nil
}

func (self Future) isComplete() (bool, error) {
  hasDoneFile, err := FileExists(self.doneFile())
  if err != nil {
    return false, err
  }
  if hasDoneFile {
    // The child finished writing its output. We don't care if dtach is still
    // racin to tear down.
    return true, nil
  }

  hasSocket, err := FileExists(self.socketFile())
  if err != nil {
    return false, err
  }
  if !hasSocket {
    // dtach isn't running. Maybe it died before writing the done file.
    return true, nil
  }

  return false, nil
}
