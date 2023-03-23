package main

import (
  "bytes"
	"io"
	"io/ioutil"
	"log"
	"os"
	"path"
)

const directoryMode = 0750
const executableMode = 0550

func main() {
	homedir, err := os.UserHomeDir()
	if err != nil {
		log.Fatalln(err)
	}

	// Delete everything in the bin directory, so we can rebuild it from scratch.
	bin := path.Join(homedir, "sbp/bin")
	if err = os.RemoveAll(bin); err != nil {
	  log.Fatalln(err)
	}

  // Set up the destination directories which this installer will populate.
	binScripts := path.Join(bin, "scripts")
	if err = os.MkdirAll(binScripts, directoryMode); err != nil {
	  log.Fatalln(err)
	}
	binDotfiles := path.Join(bin, "dotfiles")
	if err = os.MkdirAll(binDotfiles, directoryMode); err != nil {
	  log.Fatalln(err)
	}

  // Install sbpgo_main, which is a data dependency of this program.
	err = appendFile(
	  "./sbpgo/sbpgo_main_/sbpgo_main", path.Join(binScripts, "sbpgo_main"),
	  executableMode)
	if err != nil {
	  log.Fatalln(err)
	}

	// TODO: do the rest
}

// TODO: unit test this
//
// Copies from 'src' to 'dest', appending to any existing file.
func appendFile(src string, dest string, perm os.FileMode) error {
  // Read in the entire source file as a byte slice.
  text, err := ioutil.ReadFile(src)
  if err != nil {
    return err
  }

  // Open the file for append, creating it if it doesn't exist.
  outFile, err := os.OpenFile(dest, os.O_APPEND|os.O_CREATE|os.O_WRONLY, perm)
  if err != nil {
    return err
  }

  // Write out the file contents.
  _, err = io.Copy(outFile, bytes.NewReader(text))
  if err != nil {
    return err
  }

  return nil
}
