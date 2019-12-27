// Library for querying info from the local Git repository which contains this
// process's working directory.

// TODO: implement similary dirty/ahead for hg and g4. Those should also add
// a circle character if there are pending CLs.

package sbpgo

import (
	"bufio"
  "bytes"
  "strings"
	"regexp"
)

func GitStatus(futz Futurizer) (*WorkspaceStatus, error) {
  var cmds = map[string]string{
    "git-status": "git status --branch --porcelain",
  }
  results, err := futz(cmds)
  if err != nil {
    return nil, err
  }

	var info WorkspaceStatus

  if len(results) == 0 {
    return &info, nil
  }

  // Parse the git status result.
  status := results["git-status"]
	var scanner = bufio.NewScanner(bytes.NewReader(status))

  // Regex to match the "branch" line from git status --branch --porcelain. If
  // this matches, the local branch is ahead of the remote branch.
  statusBranchAheadRegex := regexp.MustCompile("^\\#\\# .* \\[ahead [0-9]+\\]$")

	// Stop looping if we set both Ahead and Dirty to true.
	for scanner.Scan() && !(info.Ahead && info.Dirty) {
		var line = scanner.Text()
		if strings.HasPrefix(line, "## ") {
			// This is the "branch" line.
			if statusBranchAheadRegex.FindStringIndex(line) != nil {
				info.Ahead = true
			}
		} else {
			// This is not the "branch" line, so it must indicate that a file is
			// dirty.
			info.Dirty = true
		}
	}

	return &info, nil
}
