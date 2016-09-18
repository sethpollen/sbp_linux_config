package main

import "log"
import "net"
import "net/http"
import "net/rpc"
import "os"
import . "github.com/sethpollen/sbp_linux_config/sbpgo/conch"

type ShellServer int

func (t *ShellServer) BeginCommand(request *ShellBeginCommandRequest,
	response *ShellBeginCommandResponse) error {
	log.Printf("Shell %v beginning command: %v", request.ShellId,
            request.Command)
	return nil
}

func (t *ShellServer) EndCommand(request *ShellEndCommandRequest,
	response *ShellEndCommandResponse) error {
  log.Printf("Shell %v ending command", request.ShellId)
	return nil
}

func main() {
	server := new(ShellServer)
	rpc.Register(server)
	rpc.HandleHTTP()

	_, err := os.Stat(ServerSocketPath)
	if err == nil {
		// The socket already exists. Delete it before reopening it for listening.
		log.Printf("Removing existing %v", ServerSocketPath)
		os.Remove(ServerSocketPath)
	}

  log.Printf("Listening on Unix domain socket %v", ServerSocketPath)
	l, err := net.Listen("unix", ServerSocketPath)
	if err != nil {
		log.Fatal("Listen error:", err)
	}

	http.Serve(l, nil)
}
