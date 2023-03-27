// Utilities for dealing with the filesystem.

// TODO: unit tests

package fs

import (
	"fmt"
	"io"
	"os"
	"path"
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

// Walks the directory tree rooted at 'src', mirroring that same structure
// onto 'dest'. If a file in 'src' has the same path as a file in 'dest',
// the 'src' file is appended to the existing 'dest' file.
func MergeDir(src string, dest string) error {
	return Walk(src, dest, false,
		func(src string, dest string) error {
			return CopyFile(src, dest,
				// Allow appends.
				true)
		})
}

// Copies from 'src' to 'dest'. If 'dest' exists and 'allowAppend' is true,
// we will append 'src' to 'dest'. If 'dest' exists and 'allowAppend' is
// false, returns an error.
func CopyFile(src string, dest string, allowAppend bool) error {
	// Collect information about the src, for use later.
	srcStat, err := os.Stat(src)
	if err != nil {
		return err
	}

	// Collect information about the dest, for use later.
	destExists, err := FileExists(dest)

	// Open the source file for reading.
	srcFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	// Open the destination file, creating it if it doesn't exist.
	flag := os.O_CREATE | os.O_WRONLY
	if allowAppend {
		// Append to the file if it already exists.
		flag = flag | os.O_APPEND
	} else {
		// We want an error if the file already exists.
		flag = flag | os.O_EXCL
	}
	destFile, err := os.OpenFile(dest, flag,
		// Preserve the mode on the source file.
		srcStat.Mode())
	if err != nil {
		return err
	}
	defer destFile.Close()

	if destExists {
		// Appending is somewhat unusual, so we print out a message each time
		// it happens.
		fmt.Printf("Appending to %s\n", dest)

		// Make sure we don't accidentally concatenate the last existing line
		// with the first new line. We write two newlines here instead of one
		// to make it easier to see how the resulting file was constructed.
		destFile.WriteString("\n\n")
	}

	// Copy the file contents.
	_, err = io.Copy(destFile, srcFile)
	if err != nil {
		return err
	}

	return nil
}

// Adds a symlink named 'dest', pointing to the existing location 'src'.
func ForceSymlink(src string, dest string) error {
	// Use Lstat so that we can see symlinks to directories as symlinks.
	destStat, err := os.Lstat(dest)
	if os.IsNotExist(err) {
		// No need to delete anything before making the link.
		return os.Symlink(src, dest)
	}
	if err != nil {
		return err
	}
	if destStat.IsDir() {
		// Don't handle the case where linkName is a directory. It's too easy to
		// blow away existing config folders that way.
		return fmt.Errorf("refusing to replace directory with symlink: %s", dest)
	}

	// Remove the existing destination, so we can replace it with the desired
	// symlink.
	err = os.Remove(dest)
	if err != nil {
		return err
	}

	return os.Symlink(src, dest)
}

// Recursively traverses the directory tree rooted at 'src'. Ensures that
// 'dest' has a similar directory tree, and invokes 'process' for each file.
//
// If 'addDot' is true, we will prepend a dot (".") to the top level dest
// names (both files and directories).
func Walk(
	src string,
	dest string,
	addDot bool,
	process func(src string, dest string) error) error {
	// Check if the src exists and is a directory.
	srcStat, err := os.Stat(src)
	if os.IsNotExist(err) {
		// The source directory does not exist, so there is nothing to copy over.
		// Don't return an error.
		return nil
	}
	if err != nil {
		return err
	}
	if !srcStat.Mode().IsDir() {
		return fmt.Errorf("%s is not a directory", src)
	}

	// Ensure the destination directory exists.
	err = os.MkdirAll(dest, 0750)
	if err != nil {
		return err
	}

	// Get the list of things to copy over.
	srcChildren, err := os.ReadDir(src)
	if err != nil {
		return err
	}

	// Decide whether to prepend a dot.
	dot := ""
	if addDot {
		dot = "."
	}

	for _, child := range srcChildren {
		srcChild := path.Join(src, child.Name())
		destChild := path.Join(dest, dot+child.Name())

		if child.IsDir() {
			// Recursively process the child directory.
			err = Walk(srcChild, destChild,
				// Don't add any more dots.
				false, process)
		} else {
			// Process this file.
			err = process(srcChild, destChild)
		}

		if err != nil {
			return err
		}
	}

	return nil
}
