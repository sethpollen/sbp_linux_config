// Utilities for dealing with tmux.
package sbpgo

import (
	"os"
	"strings"
)

func RunningUnderTmux() bool {
	return os.Getenv("TMUX") != ""
}

type TmuxStatus struct {
	// We never send a value on this channel, but we close it once the other
	// fields of this object are ready.
	ready chan bool

	// All sessions.
	//
	// TODO: try again to set a bool if there is an unattended bell (command
	// completion) in one of the sessions.
	sessions []string

	// Empty string if not attached to a tmux session.
	attachedSession string
}

func (self *TmuxStatus) Sessions() []string {
	<-self.ready
	return self.sessions
}

func (self *TmuxStatus) AttachedSession() string {
	<-self.ready
	return self.attachedSession
}

func GetTmuxStatus() *TmuxStatus {
	var status = new(TmuxStatus)
	status.ready = make(chan bool)
	status.attachedSession = ""

	go func() {
		var sessionsOut = make(chan string, 1)
		var sessionsErr = make(chan error, 1)
		go EvalCommand(sessionsOut, sessionsErr, ".", "tmux", "list-windows", "-a",
			"-F", "#{session_name}")

		var attachedSessionOut = make(chan string, 1)
		var attachedSessionErr = make(chan error, 1)
		if RunningUnderTmux() {
			go EvalCommand(attachedSessionOut, attachedSessionErr, ".", "tmux",
				"display-message", "-p", "#S")
		} else {
			// We can't be attached if we aren't running under tmux.
			attachedSessionOut <- ""
		}

		select {
		case <-sessionsErr:
		case out := <-sessionsOut:
			for _, line := range strings.Split(out, "\n") {
				line = strings.TrimSpace(line)
				if len(line) > 0 {
					status.sessions = append(status.sessions, line)
				}
			}
		}

		select {
		case <-attachedSessionErr:
		case status.attachedSession = <-attachedSessionOut:
		}

		close(status.ready)
	}()

	return status
}
