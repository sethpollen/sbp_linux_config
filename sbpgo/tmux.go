// Utilities for dealing with tmux.
package sbpgo

import (
  "os"
)

func RunningUnderTmux() bool {
  return os.Getenv("TMUX") != ""
}

type TmuxStatus struct {
  // Value is true if the session needs attention.
  Sessions map[string]bool
  // Empty string if not attached to a tmux session.
  AttachedSession string
}

// Querying is done asynchronously in the background. The returned channel
// will receive an infinite stream of identical replies. 
func GetTmuxStatus() <-chan TmuxStatus {
  var channel = make(chan TmuxStatus)

  errorsForever = func() {
    for {
      channel <- TmuxStatus{make(map[string]bool), ""}
    }
  }

  if !RunningUnderTmux() {
    // Don't waste CPU invoking tmux.
    go errorsForever()
    return channel
  }

  go func() {
    var errorChan = make(chan error)
    var sessionsChan = make(chan string)
    var attachedSessionChan = make(chan string)

    EvalCommand(sessionsChan, errorChan, ".", "tmux", "list-windows", "-a",
      "-F", "#{session_name} #{window_flags}")
    EvalCommand(attachedSessionChan, errorChan, ".", "tmux", "display-message",
      "-p", "#S")

    select {
    case err := <-errorChan:
      errorsForever()
      // TODO:
    }
  }()
  return channel
}

func CurrentTmuxSession() <-chan string {
  var session = make(chan string)
  go func() {
    if !RunningUnderTmux() {
      for {
        session <- ""
      }
    }
    result, err := EvalCommandSync(".", "tmux", "display-message", "-p", "#S")
    for {
      if err != nil {
        session <- ""
      } else {
        session <- result
      }
    }
  }()
  return session
}
