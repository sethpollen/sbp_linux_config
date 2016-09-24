package conch

import "fmt"
import "time"

type BeginCommandOp struct {
	Request *ShellBeginCommandRequest
	Done    chan error
}

type EndCommandOp struct {
	Request *ShellEndCommandRequest
	Done    chan error
}

type ShellServer struct {
	// A ShellServer contains an internal thread which removes ops from these
	// two channels and processes them. The internal thread never exits.
	beginCommandOps chan *BeginCommandOp
	endCommandOps   chan *EndCommandOp
}

func MakeShellServer() *ShellServer {
	server := &ShellServer{make(chan *BeginCommandOp), make(chan *EndCommandOp)}
	go server.Service()
	return server
}

// Task that runs in the background to service incoming server requests.
func (self *ShellServer) Service() {
	cullTicker := time.NewTicker(5 * time.Second)

	// Information tracked for each shell.
	type Info struct {
		LatestCommand string
		// True if the LatestCommand is still running.
		Running bool
		Pwd     string
	}
	shells := make(map[ShellId]*Info)

	for {
		select {
		case op := <-self.beginCommandOps:
			{
				shells[op.Request.ShellId] = &Info{op.Request.Command, true,
					op.Request.Pwd}
				op.Done <- nil
			}

		case op := <-self.endCommandOps:
			{
				entry, ok := shells[op.Request.ShellId]
				if ok {
					entry.Running = false
					op.Done <- nil
				} else {
					op.Done <- fmt.Errorf("Unknown ShellId: %v", op.Request.ShellId)
				}
			}

		case <-cullTicker.C:
			{
				// Cull the list, checking for shells which don't exist anymore.
				for knownId, _ := range shells {
					actualId, err := MakeShellId(knownId.Pid)
					if err != nil || *actualId != knownId {
						// Either this shell's /proc entry is gone, or it now represents a
						// different process. So we cull this shell's entry.
						delete(shells, knownId)
					}
				}
			}
		}
	}
}

// RPC handler.
func (self *ShellServer) BeginCommand(request *ShellBeginCommandRequest,
	response *ShellBeginCommandResponse) error {
	done := make(chan error)
	self.beginCommandOps <- &BeginCommandOp{request, done}
	return <-done
}

// RPC handler.
func (self *ShellServer) EndCommand(request *ShellEndCommandRequest,
	response *ShellEndCommandResponse) error {
	done := make(chan error)
	self.endCommandOps <- &EndCommandOp{request, done}
	return <-done
}

// Scans over the set of shells, removing any which appear to no longer be
// running.
// TODO: incorporate into Service()
/*
func (self *ShellServer) Cull() {
	self.mutex.Lock()
	defer self.mutex.Unlock()

}
*/
