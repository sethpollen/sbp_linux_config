// Library for querying info from the local Mercurial repository which contains
// this process's working directory.

package sbpgo

import (
	"bufio"
	"bytes"
	"regexp"
	"strings"
)

func HgStatus(futz Futurizer, corp CorpContext) (*WorkspaceStatus, error) {
	var cmds = map[string]string{
		"hg-status": "hg status",
	}

	logCmd := corp.HgLogCommand()
	if logCmd != nil {
		cmds["hg-log"] = *logCmd
	}

	results, err := futz(cmds)
	if err != nil {
		return nil, err
	}

	var info WorkspaceStatus

	if log, ok := results["hg-log"]; ok {
		pInfo, err := corp.HgLog(log)
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

func processHgStatusOutput(info *WorkspaceStatus, output []byte) {
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
