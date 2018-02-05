// Utilities for dealing with tmux.
package sbpgo

// TODO: use concurrency for other modules (git, hg, g4) as well
// TODO: reimplement tmuxls using this library

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

	// Value is true if the session needs attention.
	sessions map[string]bool
	// Empty string if not attached to a tmux session.
	attachedSession string
}

func (self *TmuxStatus) Sessions() map[string]bool {
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
  status.sessions = make(map[string]bool)
  
	go func() {
		var sessionsOut = make(chan string, 1)
		var sessionsErr = make(chan error, 1)
		go EvalCommand(sessionsOut, sessionsErr, ".", "tmux", "list-windows", "-a",
			"-F", "#{session_name} #{window_flags}")

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
				parts := strings.Split(strings.TrimSpace(line), " ")
				if len(parts) > 0 {
					session := parts[0]
					var attention bool = (strings.Index(line, "!") >= 0)
					status.sessions[session] = (attention || status.sessions[session])
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
