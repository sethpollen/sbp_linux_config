// Implements futures back by out-of-process background work.

package sbpgo

import (
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"path"
	"regexp"
	"strconv"
	"strings"
	"time"
)

type FutureStat struct {
	Name     string
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

// Kills and reclaims all futures.
func ClearFutures(home string) error {
	// Kill all futures in a single bulk operation.
	pattern := home
	if !strings.HasSuffix(pattern, "/") {
		pattern += "/"
	}
	err := kill(regexp.QuoteMeta(pattern))
	if err != nil {
		return err
	}

	// Reclaim futures in parallel.
	futures, err := ListFutures(home)
	if err != nil {
		return err
	}

	var errors = make(chan error, len(futures))

	for _, future := range futures {
		f := OpenFuture(home, future.Name)
		go removeAll(f.myHome(), errors)
	}

	for _, _ = range futures {
		err = <-errors
		if err != nil {
			return err
		}
	}

	return nil
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
func IsJobNotExist(err error) bool {
	_, ok := err.(JobNotExistError)
	return ok
}

type JobAlreadyExistError struct {
	name string
}

func (self JobAlreadyExistError) Error() string {
	return "Job already exists: " + self.name
}
func IsJobAlreadyExist(err error) bool {
	_, ok := err.(JobAlreadyExistError)
	return ok
}

type JobStillRunningError struct {
	name string
}

func (self JobStillRunningError) Error() string {
	return "Job still running: " + self.name
}
func IsJobStillRunning(err error) bool {
	_, ok := err.(JobStillRunningError)
	return ok
}

// Starts the given future by spawning 'cmd' in the background. 'interactive'
// determines whether the output will be dressed up with command-line prompts.
// Once the command completes, we will send SIGUSR1 to 'notifyPid', if it is
// non-nil.
func (self Future) Start(cmd string, interactive bool, notifyPid *int) error {
	err := self.checkNotExists()
	if err != nil {
		return err
	}

	err = ensureDir(self.myHome())
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
		program += "sbp-prompt --mode=slow --output=fish_prompt " +
			"--show_back=false --width=$COLUMNS\n"
		program += "set_color $fish_color_command\n"
		program += "echo " + strconv.Quote(cmd) + "\n"
		program += "set_color normal\n"
	}

	// Wrap the cmd in another fish shell to avoid any weird syntax interaction.
	program += "fish -c " + strconv.Quote(cmd) + "\n"

	if interactive {
		program += "sbp-prompt --mode=slow --output=fish_prompt " +
			"--show_back=false --width=$COLUMNS --exit_code=$status " +
			"--dollar=false\n"
	}

	program += "end </dev/null >" + strconv.Quote(self.outputFile()) + " 2>&1\n"
	program += "touch " + strconv.Quote(self.doneFile()) + "\n"

	if notifyPid != nil {
		program += "kill -USR1 " + fmt.Sprintf("%d", *notifyPid) + "\n"
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

// If the background task has completed, returns successfully. Otherwise returns
// an error.
func (self Future) Poll() error {
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

	return nil
}

// If the background task has completed, deletes all of its state. Otherwise
// returns an error.
func (self Future) Reclaim() error {
	err := self.Poll()
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

	return kill(regexp.QuoteMeta(self.socketFile()))
}

// Generic entry point for asynchronous code. 'cmds' gives a set of named shell
// commands. For each command, we will start a background job for it, if one is
// not already started. We return a map with the containing the output of any
// completed commands.
func Futurize(
	home string,
	cmds map[string]string,
	notifyPid *int) (map[string][]byte, error) {
	// Treat each future in parallel.
	var errors = make(chan error, len(cmds))
	var resultChans = make(map[string]chan []byte)

	for name, cmd := range cmds {
		resultChan := make(chan []byte, 1)
		resultChans[name] = resultChan
		f := OpenFuture(home, name)
		go f.futurize(cmd, notifyPid, errors, resultChan)
	}

	for _, _ = range cmds {
		err := <-errors
		if err != nil {
			return nil, err
		}
	}

	var results = make(map[string][]byte)
	for name, resultChan := range resultChans {
		result, ok := <-resultChan
		if ok {
			results[name] = result
		}
	}

	return results, nil
}

// Same semantics as Futurize(), but does everything synchronously, so every
// command always has a result.
func FuturizeSync(cmds map[string]string,
	env map[string]string) (map[string][]byte, error) {
	// Treat each future in parallel.
	var errors = make(chan error, len(cmds))
	var resultChans = make(map[string]chan []byte)

	for name, cmd := range cmds {
		resultChan := make(chan []byte, 1)
		resultChans[name] = resultChan
		go runCmd(cmd, env, resultChan, errors)
	}

	for _, _ = range cmds {
		err := <-errors
		if err != nil {
			return nil, err
		}
	}

	var results = make(map[string][]byte)
	for name, resultChan := range resultChans {
		result, ok := <-resultChan
		if ok {
			results[name] = result
		}
	}

	return results, nil
}

////////////////////////////////////////////////////////////////////////////////
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

func (self Future) checkNotExists() error {
	exists, err := DirExists(self.myHome())
	if err != nil {
		return err
	}
	if exists {
		return JobAlreadyExistError{self.name}
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

func kill(socketFilePattern string) error {
	var pattern = "^dtach -n " + socketFilePattern

	// We delegate all the hard work to pkill and pgrep. We kill only the dtach
	// processes using sockets which match our pattern.
	pkill := exec.Command("pkill", "--full", pattern)
	err := pkill.Run()
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
	for {
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
		time.Sleep(time.Millisecond)
	}

	return nil
}

func (self Future) futurize(cmd string, notifyPid *int,
	errChan chan error, resultChan chan []byte) {
	// Try to spawn the job. Don't use interactive mode.
	err := self.Start(cmd, false, notifyPid)
	if err == nil {
		// Job was started. Nothing else to do.
		close(resultChan)
		errChan <- nil
		return
	}

	if !IsJobAlreadyExist(err) {
		errChan <- err
		return
	}

	// The job already exists.
	complete, err := self.isComplete()
	if err != nil {
		errChan <- err
		return
	}

	if complete {
		output, err := ioutil.ReadFile(self.outputFile())
		if err != nil {
			errChan <- err
			return
		}
		resultChan <- output
		errChan <- nil
		return
	}

	// Job is still running, so we don't have a result to yield.
	close(resultChan)
	errChan <- nil
	return
}

func removeAll(dir string, errChan chan error) {
	errChan <- os.RemoveAll(dir)
}

func runCmd(cmd string, env map[string]string, resultChan chan []byte,
	errChan chan error) {
	c := exec.Command("fish", "-c", cmd)

	c.Env = os.Environ()
	for k, v := range env {
		c.Env = append(c.Env, fmt.Sprintf("%s=%s", k, v))
	}

	result, err := c.CombinedOutput()
	resultChan <- result

	if _, ok := err.(*exec.ExitError); ok {
		// We don't care if the command failed; we still just report its output
		// (including stderr).
		errChan <- nil
	} else {
		errChan <- err
	}
}
