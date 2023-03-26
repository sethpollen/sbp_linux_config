package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path"
)

// TODO: unit tests

// Gets the list of source directories to install from for the current host.
// When setting up a new computer, add an entry here.
func getInstallSrcDirs(host string, home string) []string {
	var dirs = []string{
		// All installations use this source directory.
		//
		// TODO: consider a better name for this, and the similar directories
		// in corp_linux_config. Maybe install-src?
		path.Join(home, "sbp/sbp_linux_config/common-text"),
	}

	corp := path.Join(home, "sbp/corp_linux_config")

	switch host {
	case "holroyd":
		dirs = append(dirs,
			path.Join(corp, "common"),
			path.Join(corp, "workstation"),
			path.Join(corp, "hosts/holroyd"))

	case "montero":
		dirs = append(dirs,
			path.Join(corp, "common"),
			path.Join(corp, "workstation"))

	case "pollen":
		dirs = append(dirs,
			path.Join(corp, "common"),
			path.Join(corp, "hosts/pollen"))

	case "penguin":
		// Nothing extra.
	}

	return dirs
}

func main() {
	// Look up the current hostname and homedir.
	host, err := os.Hostname()
	if err != nil {
		log.Fatalln(err)
	}
	home, err := os.UserHomeDir()
	if err != nil {
		log.Fatalln(err)
	}

	// Delete everything in the bin directory, so we can rebuild it from scratch.
	bin := path.Join(home, "sbp/bin")
	if err = os.RemoveAll(bin); err != nil {
		log.Fatalln(err)
	}

	binScripts := path.Join(bin, "scripts")
	binDotfiles := path.Join(bin, "dotfiles")

	// Install the proper set of files for this host.
	for _, srcDir := range getInstallSrcDirs(host, home) {
		// Copy over executables with "r-x" mode.
		err = mergeDir(path.Join(srcDir, "scripts"), binScripts)
		if err != nil {
			log.Fatalln(err)
		}

		// Copy over dotfiles with "rw-" mode. "w" enables us to append to them.
		err = mergeDir(path.Join(srcDir, "dotfiles"), binDotfiles)
		if err != nil {
			log.Fatalln(err)
		}
	}

	// Install sbp_main, which is built as a data dependency of this program.
	err = copyFile(
		"./go/sbp_main_/sbp_main",
		path.Join(bin, "scripts/sbp_main"),
		// Don't allow appends.
		false)
	if err != nil {
		log.Fatalln(err)
	}

	// Add symlinks to all of my installed dotfiles.
	fmt.Printf("Linking dotfiles under %s\n", home)
	err = walk(binDotfiles, home, true, forceSymlink)
	if err != nil {
		log.Fatalln(err)
	}

	// Add a symlink from ~/bin to ~/sbp/bin. ~/bin should already be on $PATH.
	homeBin := path.Join(home, "bin")
	fmt.Printf("Linking %s\n", homeBin)
	err = forceSymlink(binScripts, homeBin)
	if err != nil {
		log.Fatalln(err)
	}

	// Install my crontab file.
	fmt.Printf("Installing crontab\n")
	err = exec.Command("crontab", path.Join(home, ".crontab")).Run()
	if err != nil {
		log.Fatalln(err)
	}

	fmt.Printf("Success!\n")
}

// Walks the directory tree rooted at 'src', mirroring that same structure
// onto 'dest'. If a file in 'src' has the same path as a file in 'dest',
// the 'src' file is appended to the existing 'dest' file.
func mergeDir(src string, dest string) error {
	return walk(src, dest, false,
		func(src string, dest string) error {
			return copyFile(src, dest,
				// Allow appends.
				true)
		})
}

// Copies from 'src' to 'dest'. If 'dest' exists and 'allowAppend' is true,
// we will append 'src' to 'dest'. If 'dest' exists and 'allowAppend' is
// false, returns an error.
func copyFile(src string, dest string, allowAppend bool) error {
	// Collect information about the src, for user later.
	srcStat, err := os.Stat(src)
	if err != nil {
		return err
	}

	// Collect information about the dest, for user later.
	_, err = os.Stat(dest)
	destExists := err == nil

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
func forceSymlink(src string, dest string) error {
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
func walk(
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
			err = walk(srcChild, destChild,
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
