package sbpgo

import (
	"bytes"
	"errors"
	"io"
	"os"
	"path"
)

// Reads all of stdin, blocking until EOF.
func ReadStdin() string {
	var buf bytes.Buffer
	_, err := io.Copy(&buf, os.Stdin)
	if err != nil {
		panic("ReadStdin")
	}
	return buf.String()
}

func DirExists(n string) (bool, error) {
	f, err := os.Stat(n)
	if err != nil {
		if os.IsNotExist(err) {
			return false, nil
		}
		return false, err
	}
	return f.IsDir(), nil
}

func FileExists(n string) (bool, error) {
	f, err := os.Stat(n)
	if err != nil {
		if os.IsNotExist(err) {
			return false, nil
		}
		return false, err
	}
	return !f.IsDir(), nil
}
