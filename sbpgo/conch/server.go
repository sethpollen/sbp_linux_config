package conch

import "log"
import "sync"

type ShellInfo struct {
  // TODO: store something!
}

type ShellServer struct {
  mutex sync.Mutex
  // The known set of running shell instances.
  shells map[ShellId]ShellInfo
}

func MakeShellServer() *ShellServer {
  server := new(ShellServer)
  server.shells = make(map[ShellId]ShellInfo)
  return server
}

// RPC handler.
func (self *ShellServer) BeginCommand(request *ShellBeginCommandRequest,
  response *ShellBeginCommandResponse) error {
  log.Printf("Shell %v beginning command: %v", request.ShellId,
    request.Command)
  return nil
}

// RPC handler.
func (self *ShellServer) EndCommand(request *ShellEndCommandRequest,
  response *ShellEndCommandResponse) error {
  log.Printf("Shell %v ending command", request.ShellId)
  return nil
}

// Scans over the set of shells, removing any which appear to no longer be
// running.
func (self *ShellServer) Cull() {
  self.mutex.Lock()
  defer self.mutex.Unlock()

  for knownId, _ := range self.shells {
    actualId, err := MakeShellId(knownId.Pid)
    if err != nil || *actualId != knownId {
      // Either this shell's /proc entry is gone, or it now represents a
      // different process. So we cull this shell's entry.
      delete(self.shells, knownId)
    }
  }
}