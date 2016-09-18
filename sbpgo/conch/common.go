package conch

// The Conch server listens on a Unix domain socket.
const ServerSocketPath = "/tmp/sbp_conch.sock"

// RPC sent to indicate that the given shell instance is beginning to execute
// a command.
type ShellBeginCommandRequest struct {
	ShellId string
	Command string
}
type ShellBeginCommandResponse struct{}

// RPC sent to indiate that the given shell instance has finished executing a
// command.
type ShellEndCommandRequest struct {
	ShellId string
}
type ShellEndCommandResponse struct{}
