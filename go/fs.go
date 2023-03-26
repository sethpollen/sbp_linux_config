// Utilities for dealing with the filesystem.

package fs

import (
	"os"
)

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
