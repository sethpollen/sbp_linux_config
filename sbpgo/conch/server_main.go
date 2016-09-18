package main

import "log"
import "net"
import "net/http"
import "net/rpc"
import "os"
import . "github.com/sethpollen/sbp_linux_config/sbpgo/conch"

type EchoServer int

func (t *EchoServer) Echo(request *EchoRequest, response *EchoResponse) error {
  response.Text = request.Text
  return nil
}

func main() {
  server := new(EchoServer)
  rpc.Register(server)
  rpc.HandleHTTP()

  _, err := os.Stat(ServerSocketPath)
  if err == nil {
    // The socket already exists. Delete it before reopening it for listening.
    log.Print("Removing existing %s", ServerSocketPath)
    os.Remove(ServerSocketPath)
  }

  l, err := net.Listen("unix", ServerSocketPath)
  if err != nil {
    log.Fatal("Listen error:", err)
  }

  http.Serve(l, nil)
}
