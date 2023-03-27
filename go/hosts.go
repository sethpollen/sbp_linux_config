// Top-level information for each of my machines.

package hosts

import (
	"os"
	"path"
)

// Gets the list of source directories to install from for the current host.
// When setting up a new computer, add an entry here.
func GetInstallSrcDirs() ([]string, error) {
	host, err := os.Hostname()
	if err != nil {
		return nil, err
	}

	home, err := os.UserHomeDir()
	if err != nil {
		return nil, err
	}

	hostIsCorp, err := IsCorp()
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

	if hostIsCorp {
		// TODO: rename to base
		dirs = append(dirs, path.Join(home, "common"))
	}

	switch host {
	case "holroyd":
		dirs = append(dirs,
			path.Join(corp, "workstation"),
			path.Join(corp, "hosts/holroyd"))

	case "montero":
		dirs = append(dirs,
			path.Join(corp, "workstation"))

	case "pollen":
		dirs = append(dirs,
			path.Join(corp, "hosts/pollen"))

	case "penguin":
		// Nothing extra.
	}

	return dirs, nil
}

// Returns true if the current host is a corp machine, for which we should
// probably download corp_linux_config.
func IsCorp() (bool, error) {
	host, err := os.Hostname()
	if err != nil {
		return false, err
	}
	return (host == "holroyd" || host == "montero" || host == "pollen"), nil
}
