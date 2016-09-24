package conch

import "fmt"
import "io/ioutil"
import "strconv"
import "strings"

// The Conch server listens on a Unix domain socket.
const ServerSocketPath = "/tmp/sbp_conch.sock"

// Uniquely identifies a shell instance.
type ShellId struct {
	Pid int
	// The actual units here are platform dependent, but will be consistent
	// for all processes on the platform.
	StartTime int64
}

// Looks up the full ShellId for the currently running shell with the given
// 'pid'.
func MakeShellId(pid int) (*ShellId, error) {
	path := fmt.Sprintf("/proc/%d/stat", pid)
	stat, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, err
	}

	parts := strings.Split(string(stat), " ")

	// Index of 'starttime' in /proc/[pid]/stat.
	const startTimeIndex = 21
	if len(parts) <= startTimeIndex {
		return nil, fmt.Errorf("Didn't find starttime in %s", path)
	}
	startTime, err := strconv.ParseInt(parts[startTimeIndex], 10, 64)
	if err != nil {
		return nil, fmt.Errorf("Couldn't parse starttime: %s",
			parts[startTimeIndex])
	}

	return &ShellId{pid, startTime}, nil
}

// RPC sent to indicate that the given shell instance is beginning to execute
// a command.
type ShellBeginCommandRequest struct {
	ShellId ShellId
	Command string
}
type ShellBeginCommandResponse struct{}

// RPC sent to indiate that the given shell instance has finished executing a
// command.
type ShellEndCommandRequest struct {
	ShellId ShellId
}
type ShellEndCommandResponse struct{}
