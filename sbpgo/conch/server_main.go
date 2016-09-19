package main

import "log"
import "net"
import "net/http"
import "net/rpc"
import "os"
import . "github.com/sethpollen/sbp_linux_config/sbpgo/conch"

func main() {
	server := MakeShellServer()
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
		log.Fatal("Listen error: ", err)
	}

	http.Serve(l, nil)
}
