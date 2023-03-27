// Top-level information for each of my machines. When setting up a new computer,
// add its configuration here.

package hosts

import (
	"os"
	"path"
)

// Gets the list of source directories to install from for 'hostname'.
func GetInstallSrcDirs(hostname string) ([]string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return nil, err
	}
	sbp := path.Join(home, "sbp")

	var dirs []string

	// All installations use this directory.
	dirs = append(dirs,
		path.Join(sbp, "sbp_linux_config", "base"))

	if IsCorp(hostname) {
		// All corp installations use this directory.
		dirs = append(dirs,
			path.Join(sbp, "corp_linux_config", "base"))

		if hasProdaccess(hostname) {
			dirs = append(dirs,
				path.Join(sbp, "corp_linux_config", "prodaccess"))
		}

		if hasHostSpecificDir(hostname) {
			dirs = append(dirs,
				path.Join(sbp, "corp_linux_config", hostname))
		}
	}

	return dirs, nil
}

// Returns true if 'hostname' is a corp machine, for which we should
// probably download corp_linux_config.
func IsCorp(hostname string) bool {
	return (hostname == "holroyd" || hostname == "montero" || hostname == "pollen1")
}

// Returns true if 'hostname' is a corp machine with access to prod.
func hasProdaccess(hostname string) bool {
	return (hostname == "holroyd" || hostname == "montero")
}

// Returns true if 'hostname' is a corp machine with a host-specific directory.
func hasHostSpecificDir(hostname string) bool {
	return (hostname == "holroyd" || hostname == "pollen1")
}
