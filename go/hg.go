// Library for querying info from the local Mercurial repository which contains
// this process's working directory.

package hg

import (
	"bufio"
	"bytes"
	"github.com/sethpollen/sbp_linux_config/futures"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"regexp"
	"strings"
)

func Status(futz futures.Futurizer) (*sbpgo.WorkspaceStatus, error) {
	var cmds = map[string]string{
		"hg-status": "hg status",
		"hg-log":    "hg log --rev smart --template google_compact",
	}

	results, err := futz(cmds)
	if err != nil {
		return nil, err
	}

	var info sbpgo.WorkspaceStatus

	if log, ok := results["hg-log"]; ok {
		pInfo, err := processHgLogOutput(log)
		if err != nil {
			return nil, err
		}
		info = *pInfo
	}

	// If hg status reports anything, we know there are uncommited changes.
	// Note that there may be other ways for Dirty to get set to true.
	if status, ok := results["hg-status"]; ok {
		processHgStatusOutput(&info, status)
	}

	return &info, nil
}

func processHgLogOutput(
	output []byte) (*sbpgo.WorkspaceStatus, error) {
	var exportedAsRegexp = regexp.MustCompile("<exported as http://cl/[0-9]+>")

	var info sbpgo.WorkspaceStatus
	var scanner = bufio.NewScanner(bytes.NewReader(output))
	var lineNumber = 1

	for scanner.Scan() {
		if info.Ahead && info.PendingCl {
			break
		}
		if lineNumber%2 == 0 {
			// Every second line is a commit description and can be dropped.
			continue
		}
		lineNumber++

		// Pad with a space to make it easier to match tokens at the end.
		var line = scanner.Text() + " "

		if strings.Contains(line, " p4head ") {
			// Ignore this line; it is always present.
			continue
		}

		// We have a commit, which is basically an unsubmitted CL.
		info.PendingCl = true

		if !exportedAsRegexp.MatchString(line) {
			// This CL still needs to be exported.
			info.Ahead = true
		} else if strings.Contains(line, " orphan ") {
			// We need to do some merges to get the exported CL back into a coherent
			// state.
			info.Ahead = true
		}
	}

	return &info, nil
}

func processHgStatusOutput(info *sbpgo.WorkspaceStatus, output []byte) {
	unfinishedStateRegex := regexp.MustCompile("repository is in an unfinished [^ ]* state")

	var scanner = bufio.NewScanner(bytes.NewReader(output))

	for scanner.Scan() {
		if info.Dirty && info.MergeConflict {
			break
		}
		var line = scanner.Text()

		if len(line) == 0 {
			continue
		}

		if line[0] == '#' {
			if unfinishedStateRegex.MatchString(strings.ToLower(line)) {
				info.MergeConflict = true
			}
			continue
		}

		// If we get here, it's a normal "hg status" line, which
		// indicates a dirty file.
		info.Dirty = true
	}
}
