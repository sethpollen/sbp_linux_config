package conch

// The Conch server listens on a Unix domain socket.
const ServerSocketPath = "/tmp/sbp_conch.sock"

type EchoRequest struct {
  Text string
}

type EchoResponse struct {
  Text string
}
