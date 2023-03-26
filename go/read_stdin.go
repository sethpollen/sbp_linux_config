package read_stdin

import (
	"bytes"
	"io"
	"os"
)

// Reads all of stdin, blocking until EOF.
func Read() string {
	var buf bytes.Buffer
	_, err := io.Copy(&buf, os.Stdin)
	if err != nil {
		panic("ReadStdin")
	}
	return buf.String()
}
