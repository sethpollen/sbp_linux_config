// Top-level information for each of my machines.

package hosts

import (
	"os"
	"path"
)

// Gets the list of source directories to install from for the current host.
// When setting up a new computer, add an entry here.
func InstallSrcDirs() ([]string, error) {
	host, err := os.Hostname()
	if err != nil {
		return nil, err
	}

	home, err := os.UserHomeDir()
	if err != nil {
		return nil, err
	}

	var dirs = []string{
		// All installations use this source directory.
		//
		// TODO: also find standard names for the corp dirs
		path.Join(home, "sbp/sbp_linux_config/base"),
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

	return dirs, nil
}
