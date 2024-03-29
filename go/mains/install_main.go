// Installs stuff from my linux_config repos into $HOME.

package main

import (
	"fmt"
	"github.com/sethpollen/sbp_linux_config/fs"
	"github.com/sethpollen/sbp_linux_config/hosts"
	"log"
	"os"
	"os/exec"
	"path"
)

func main() {
	hostname, err := hosts.GetHostname()
	if err != nil {
		log.Fatalln(err)
	}

	home, err := os.UserHomeDir()
	if err != nil {
		log.Fatalln(err)
	}

	// Delete everything in the bin directory, so we can rebuild it from scratch.
	bin := path.Join(home, "sbp/bin")
	err = os.RemoveAll(bin)
	if err != nil {
		log.Fatalln(err)
	}

	binScripts := path.Join(bin, "scripts")
	binDotfiles := path.Join(bin, "dotfiles")

	installSrcDirs, err := hosts.GetInstallSrcDirs(hostname)
	if err != nil {
		log.Fatalln(err)
	}

	// Install the proper set of files for this host.
	for _, srcDir := range installSrcDirs {
		fmt.Printf("Installing %s\n", srcDir)

		// Copy over executables with "r-x" mode.
		err = fs.MergeDir(path.Join(srcDir, "scripts"), binScripts)
		if err != nil {
			log.Fatalln(err)
		}

		// Copy over dotfiles with "rw-" mode. "w" enables us to append to them.
		err = fs.MergeDir(path.Join(srcDir, "dotfiles"), binDotfiles)
		if err != nil {
			log.Fatalln(err)
		}
	}

	// Install sbp_main, which is built as a data dependency of this program.
	err = fs.CopyFile(
		"./go/mains/sbp_main_/sbp_main",
		path.Join(bin, "scripts/sbp_main"),
		// Don't allow appends.
		false)
	if err != nil {
		log.Fatalln(err)
	}

	// Add symlinks to all of my installed dotfiles.
	fmt.Printf("Linking dotfiles under %s\n", home)
	err = fs.Walk(binDotfiles, home, true, fs.ForceSymlink)
	if err != nil {
		log.Fatalln(err)
	}

	// Add a symlink from ~/bin to ~/sbp/bin. ~/bin should already be on $PATH.
	homeBin := path.Join(home, "bin")
	fmt.Printf("Linking %s\n", homeBin)
	err = fs.ForceSymlink(binScripts, homeBin)
	if err != nil {
		log.Fatalln(err)
	}

	// Install my crontab file.
	fmt.Printf("Installing crontab\n")
	err = exec.Command("crontab", path.Join(home, ".crontab")).Run()
	if err != nil {
		log.Fatalln(err)
	}
}
