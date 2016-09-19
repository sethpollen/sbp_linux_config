package conch

import "log"
import "net/rpc"

type Client struct {
	ShellId ShellId
	// May be nil if setup failed.
	client *rpc.Client
}

// We log and then drop any failures which occur, either during setup or
// when RPCs are performed. These RPCs are strictly informative, so the client
// doens't really care whether they succeed or fail.

func NewClient(shellPid int) *Client {
	rpc_client, err := rpc.DialHTTP("unix", ServerSocketPath)
	if err != nil {
		log.Print("Error creating conch.Client; returning dummy client: ", err)
	}
	shellId, err := MakeShellId(shellPid)
  if err != nil {
    log.Print("MakeShellId failed: ", err)
    shellId = new(ShellId)  // Dummy.
  }
	return &Client{*shellId, rpc_client}
}

func (self *Client) BeginCommand(command string) {
	if self.client == nil {
		return
	}
	err := self.client.Call("ShellServer.BeginCommand",
		ShellBeginCommandRequest{self.ShellId, command},
		new(ShellBeginCommandResponse))
	if err != nil {
		log.Print("Conch RPC failed: ", err)
	}
}

func (self *Client) EndCommand() {
	if self.client == nil {
		return
	}
	err := self.client.Call("ShellServer.EndCommand",
		ShellEndCommandRequest{self.ShellId},
		new(ShellEndCommandResponse))
	if err != nil {
		log.Print("Conch RPC failed: ", err)
	}
}
