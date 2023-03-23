package main

import (
	"io/ioutil"
	"log"
	"os"
	"path"
)

func main() {
	homedir, err := os.UserHomeDir()
	if err != nil {
		log.Fatalln(err)
	}

  // Set up the destination directires which this installer will populate.
	binScripts := path.Join(homedir, "sbp/bin/scripts")
	err = os.MkdirAll(binScripts, 0750)
	if err != nil {
	  log.Fatalln(err)
	}

	err = installSbpgoMain(binScripts)
	if err != nil {
	  log.Fatalln(err)
	}
}

func installSbpgoMain(binScripts string) error {
  var err error

	// Delete any existing sbpgo_main at the destination location.
  dest := path.Join(binScripts, "sbpgo_main")
  err = os.Remove(dest)
  if err != nil {
    return err
  }

  // Read in the entire sbpgo_main binary as a byte slice.
  text, err := ioutil.ReadFile("./sbpgo/sbpgo_main_/sbpgo_main")
  if err != nil {
    return err
  }

  // Write the binary out to its new location.
  err = ioutil.WriteFile(dest, text, 0750)
  if err != nil {
    return err
  }

  return nil
}
