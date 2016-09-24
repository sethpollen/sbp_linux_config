package conch

import "net/rpc"

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

func (self *Client) BeginCommand(command string, pwd string) error {
	return self.client.Call("ShellServer.BeginCommand",
		BeginCommandRequest{self.ShellId, pwd, command},
		new(BeginCommandResponse))
}

func (self *Client) EndCommand(pwd string) error {
	return self.client.Call("ShellServer.EndCommand",
		EndCommandRequest{self.ShellId, pwd},
		new(EndCommandResponse))
}

func (self *Client) ListShells() ([]ShellDesc, error) {
	response := new(ListShellsResponse)
	err := self.client.Call("ShellServer.ListShells",
		ListShellsRequest{}, response)
	if err != nil {
		return nil, err
	}
	return response.Shells, nil
}
