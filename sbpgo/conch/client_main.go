package main

import "fmt"
import "log"
import "net/rpc"
import . "github.com/sethpollen/sbp_linux_config/sbpgo/conch"

func main() {
  client, err := rpc.DialHTTP("unix", ServerSocketPath)
  if err != nil {
    log.Fatal("Dial failed:", err)
  }
  request := &EchoRequest{"foo"}
  var response EchoResponse
  err = client.Call("EchoServer.Echo", request, &response)
  if err != nil {
    log.Fatal("RPC failed:", err)
  }
  fmt.Printf("Got response: %s\n", response.Text)
}
