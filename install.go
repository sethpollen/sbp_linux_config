package main

import (
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path"
)

// Gets the list of source directories to install from for the current host.
func getInstallSrcDirs(host string, homeDir string) []string {
	var dirs = []string{
		// All installations use this source directory.
		path.Join(homeDir, "sbp/sbp_linux_config/common-text"),
	}

	corp := path.Join(homeDir, "sbp/corp_linux_config")

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
			path.Join(corp, "workstation"),
			path.Join(corp, "hosts/pollen"))

	case "penguin":
		// Nothing extra.
	}

	return dirs
}

func main() {
	host, err := os.Hostname()
	if err != nil {
		log.Fatalln(err)
	}

	homeDir, err := os.UserHomeDir()
	if err != nil {
		log.Fatalln(err)
	}

	// Delete everything in the bin directory, so we can rebuild it from scratch.
	bin := path.Join(homeDir, "sbp/bin")
	if err = os.RemoveAll(bin); err != nil {
		log.Fatalln(err)
	}

	binScripts := path.Join(bin, "scripts")
	binDotfiles := path.Join(bin, "dotfiles")

	// Install the right set of files for this host.
	for _, srcDir := range getInstallSrcDirs(host, homeDir) {
		// Copy over executables with the "x" mode bit set.
		err = appendDir(path.Join(srcDir, "scripts"), binScripts, 0550)
		if err != nil {
			log.Fatalln(err)
		}

		// Copy over dotfiles without the "x" mode bit set.
		err = appendDir(path.Join(srcDir, "dotfiles"), binDotfiles, 0660)
		if err != nil {
			log.Fatalln(err)
		}
	}

	// Install sbpgo_main, which is built as a data dependency of this program.
	//
	// TODO: don't use appendFile here. We don't want to concatenate two Go
	// binaries.
	err = appendFile(
		"./sbpgo/sbpgo_main_/sbpgo_main",
		path.Join(bin, "scripts/sbpgo_main"),
		0550)
	if err != nil {
		log.Fatalln(err)
	}

	// Add symlinks to all of my installed dotfiles.
	err = linkDotfiles(binDotfiles, homeDir)
	if err != nil {
		log.Fatalln(err)
	}

	// Add a symlink from ~/bin to ~/sbp/bin. ~/bin should already be on $PATH.
	homeBin := path.Join(homeDir, "bin")
	printLink(binScripts, homeBin)
	err = forceSymlink(binScripts, homeBin)
	if err != nil {
		log.Fatalln(err)
	}

	// Install my crontab file.
	err = exec.Command("crontab", path.Join(homeDir, ".crontab")).Run()
	if err != nil {
		log.Fatalln(err)
	}

	fmt.Println("Success")
}

// Prints progress updates with nice vertical alignment.
func printLink(src string, dest string) {
	fmt.Printf("Linking %-30s to %s\n", dest, src)
}

// TODO: unit test
//
// Walks the directory tree rooted at 'src', mirroring that same structure
// onto 'dest'. If a file in 'src' has the same path as a file in 'dest',
// the 'src' file is appended to the existing 'dest' file.
func appendDir(src string, dest string, fileMode os.FileMode) error {
	return walk(src, dest, false,
		func(src string, dest string) error {
			return appendFile(src, dest, fileMode)
		})
}

// TODO: unit test
//
// Copies from 'src' to 'dest', appending to any existing file.
func appendFile(src string, dest string, mode os.FileMode) error {
	// Open the source file for reading.
	srcFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	destStat, err := os.Stat(dest)
	if os.IsNotExist(err) {
		// The dest file does not exist. We'll create it below.
	} else {
		// TODO:
	}

	// TODO: audit all of this code

	// TODO: in the Python version, we make sure the source file ends with a
	// double newline before appending anything else to it.

	// TODO: it would be nice to print out a line whenever appending takes
	// place. This is rare enough and interesting.

	// Open the destination file for append, creating it if it doesn't exist.
	destFile, err := os.OpenFile(dest, os.O_APPEND|os.O_CREATE|os.O_WRONLY, mode)
	if err != nil {
		return err
	}
	defer destFile.Close()

	// Copy the file contents.
	_, err = io.Copy(destFile, srcFile)
	if err != nil {
		return err
	}

	return nil
}

// TODO: comment, unit test
func linkDotfiles(src string, dest string) error {
	// Add a dot to the top-level file or directory.
	return walk(src, dest, true, forceSymlink)
}

func forceSymlink(src string, dest string) error {
	// Use Lstat so that we can see symlinks to directories as symlinks.
	destStat, err := os.Lstat(dest)
	if os.IsNotExist(err) {
		// No need to delete anything before making the link.
	} else {
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
		err := os.Remove(dest)
		if err != nil {
			return err
		}
	}

	return os.Symlink(src, dest)
}

// TODO: unit test
//
// Recursively traverses the directory tree rooted at 'src'. Ensures that
// 'dest' has a similar directory tree, and invokes 'process' for each file.
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

	srcDir, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcDir.Close()

	srcChildren, err := srcDir.ReadDir(0)
	if err != nil {
		return err
	}

	dot := ""
	if addDot {
		dot = "."
	}

	for _, child := range srcChildren {
		srcChild := path.Join(src, child.Name())
		destChild := path.Join(dest, dot+child.Name())

		if addDot {
			printLink(srcChild, destChild)
		}

		if child.IsDir() {
			// Recursively process the child directory. Don't add any more dots.
			err = walk(srcChild, destChild, false, process)
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
