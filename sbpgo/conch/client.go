package conch

import "log"
import "net/rpc"

type Client struct {
	shellId string

	// May be nil if setup failed.
	client *rpc.Client
}

// We log and then drop any failures which occur, either during setup or
// when RPCs are performed. These RPCs are strictly informative, so the client
// doens't really care whether they succeed or fail.
//
// Note that execute RPCs asynchronously, so there is no guarantee that they
// will arrive at the server in any particular order. This is OK for now,
// since we expect a single client process to only ever issue 1 RPC before
// exiting.

func NewClient(shellId string) *Client {
	rpc_client, err := rpc.DialHTTP("unix", ServerSocketPath)
	if err != nil {
		log.Print("Error creating conch.Client; returning dummy client:", err)
	}
	return &Client{shellId, rpc_client}
}

func (self *Client) BeginCommand(command string) {
	if self.client == nil {
		return
	}
	err := self.client.Call("ShellServer.BeginCommand",
		ShellBeginCommandRequest{self.shellId, command},
		new(ShellBeginCommandResponse))
	if err != nil {
		log.Print("Conch RPC failed:", err)
	}
}

func (self *Client) EndCommand() {
	if self.client == nil {
		return
	}
	err := self.client.Call("ShellServer.EndCommand",
		ShellEndCommandRequest{self.shellId},
		new(ShellEndCommandResponse))
	if err != nil {
		log.Print("Conch RPC failed:", err)
	}
}
