package conch

import (
	"log"
	"net"
	"net/http"
	"net/rpc"
	"os"
	"time"
)

type BeginCommandOp struct {
	Request  *BeginCommandRequest
	Response *BeginCommandResponse
	Done     chan<- error
}

type EndCommandOp struct {
	Request  *EndCommandRequest
	Response *EndCommandResponse
	Done     chan<- error
}

type ListShellsOp struct {
	Request  *ListShellsRequest
	Response *ListShellsResponse
	Done     chan<- error
}

type ShellServer struct {
	// A ShellServer contains an internal thread which removes ops from these
	// two channels and processes them. The internal thread never exits.
	beginCommandOps chan *BeginCommandOp
	endCommandOps   chan *EndCommandOp
	listShellsOps   chan *ListShellsOp
}

func MakeShellServer() *ShellServer {
	server := &ShellServer{
		make(chan *BeginCommandOp),
		make(chan *EndCommandOp),
		make(chan *ListShellsOp)}
	go server.Service()
	return server
}

// Task that runs in the background to service incoming server requests.
func (self *ShellServer) Service() {
	ticker := time.NewTicker(5 * time.Second)

	shells := make(map[ShellId]*ShellInfo)

	for {
		select {
		case op := <-self.beginCommandOps:
			shells[op.Request.ShellId] = &ShellInfo{
				op.Request.Pwd, op.Request.Command, true, 0, time.Now()}
			op.Done <- nil

		case op := <-self.endCommandOps:
			entry, ok := shells[op.Request.ShellId]
			if ok {
				entry.Pwd = op.Request.Pwd
				entry.Running = false
				entry.ExitCode = op.Request.ExitCode
				entry.Time = time.Now()
			} else {
				// We haven't heard of this shell before. Maybe it just started up.
				// Insert a record with no command.
				shells[op.Request.ShellId] = &ShellInfo{
					op.Request.Pwd, "", false, op.Request.ExitCode, time.Now()}
			}
			op.Done <- nil

		case op := <-self.listShellsOps:
			op.Response.Shells = make([]ShellDesc, 0, len(shells))
			for id, info := range shells {
				op.Response.Shells = append(
					op.Response.Shells, ShellDesc{id, *info})
			}
			op.Done <- nil

		case <-ticker.C:
			// TODO: check for any inactive shells which haven't been updated for
			// at least 15 seconds. Mail the commands those shells ran.

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

// RPC handlers.

func (self *ShellServer) BeginCommand(request *BeginCommandRequest,
	response *BeginCommandResponse) error {
	done := make(chan error)
	self.beginCommandOps <- &BeginCommandOp{request, response, done}
	return <-done
}

func (self *ShellServer) EndCommand(request *EndCommandRequest,
	response *EndCommandResponse) error {
	done := make(chan error)
	self.endCommandOps <- &EndCommandOp{request, response, done}
	return <-done
}

func (self *ShellServer) ListShells(request *ListShellsRequest,
	response *ListShellsResponse) error {
	done := make(chan error)
	self.listShellsOps <- &ListShellsOp{request, response, done}
	return <-done
}

// Main helper.

func RunServer(serverSocketPath string) {
	server := MakeShellServer()
	rpc.Register(server)
	rpc.HandleHTTP()

	_, err := os.Stat(serverSocketPath)
	if err == nil {
		// The socket already exists. Delete it before reopening it for listening.
		log.Printf("Removing existing %v", serverSocketPath)
		os.Remove(serverSocketPath)
	}

	log.Printf("Listening on Unix domain socket %v", serverSocketPath)
	l, err := net.Listen("unix", serverSocketPath)
	if err != nil {
		log.Fatal("Listen error: ", err)
	}

	http.Serve(l, nil)
}
