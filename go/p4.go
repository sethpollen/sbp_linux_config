// Library for querying info from the local p4 repository which contains this
// process's working directory.

package p4

import (
	"bufio"
	"bytes"
	"github.com/sethpollen/sbp_linux_config/futures"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"regexp"
)

func Status(futz futures.Futurizer) (*sbpgo.WorkspaceStatus, error) {
	var cmds = map[string]string{
		"p4-status": "p4 pending",
	}
	results, err := futz(cmds)
	if err != nil {
		return nil, err
	}

	if len(results) == 0 {
		var info sbpgo.WorkspaceStatus
		return &info, nil
	}

	dirtyRegexp := regexp.MustCompile(
		"^(Locally modified files)|(Default change :)")
	pendingClRegexp := regexp.MustCompile(
		"^Change [0-9]+ :")

	var info sbpgo.WorkspaceStatus
	var scanner = bufio.NewScanner(bytes.NewReader(results["p4-status"]))

	for scanner.Scan() {
		if info.Dirty && info.PendingCl {
			break
		}
		var line = scanner.Text()

		if dirtyRegexp.MatchString(line) {
			info.Dirty = true
		}
		if pendingClRegexp.MatchString(line) {
			info.PendingCl = true
		}
	}

	return &info, nil
}
