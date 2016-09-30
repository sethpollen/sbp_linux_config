package conch

import (
	"net/rpc"
)

type Client struct {
	ShellId ShellId
	client  rpc.Client
}

func NewClient(shellPid int, serverSocketPath string) (*Client, error) {
	rpc_client, err := rpc.DialHTTP("unix", serverSocketPath)
	if err != nil {
		return nil, err
	}
	shellId, err := MakeShellId(shellPid)
	if err != nil {
		return nil, err
	}
	return &Client{*shellId, *rpc_client}, nil
}

func (self *Client) BeginCommand(pwd string, command string) error {
	return self.client.Call("ShellServer.BeginCommand",
		BeginCommandRequest{self.ShellId, pwd, command},
		new(BeginCommandResponse))
}

func (self *Client) EndCommand(pwd string, exitCode int) error {
	return self.client.Call("ShellServer.EndCommand",
		EndCommandRequest{self.ShellId, pwd, exitCode},
		new(EndCommandResponse))
}

type ShellList []ShellDesc

func (self *Client) ListShells() (ShellList, error) {
	response := new(ListShellsResponse)
	err := self.client.Call("ShellServer.ListShells",
		ListShellsRequest{}, response)
	if err != nil {
		return nil, err
	}
	return response.Shells, nil
}

// Have ShellDesc implement sort.Interface.

func (self ShellList) Len() int {
	return len(self)
}

func (self ShellList) Less(i, j int) bool {
	return self[i].Id.Pid < self[j].Id.Pid
}

func (self ShellList) Swap(i, j int) {
	temp := self[i]
	self[i] = self[j]
	self[j] = temp
}
