// Library for querying info from the local Git repository which contains this
// process's working directory.

// TODO: drop the 2 from this file's name
package sbpgo

import (
	"bufio"
  "bytes"
  "strings"
	"regexp"
)

// TODO: drop the 2
//
// Fields may be absent if we haven't computed the answer yet.
type GitInfo2 struct {
	// True iff there are uncommitted local changes.
	Dirty *bool
	// True iff there are unpushed local commits.
	Ahead *bool
}

// TODO: need a cron to clean out back-homes for dead fish shells

// TODO: drop the 2
func GetGitInfo2(ws WorkspaceInfo, futz Futurizer) (*GitInfo2, error) {
  var cmds = map[string]string{
    "git-status": "git status --branch --porcelain",
  }
  results, err := futz(cmds)
  if err != nil {
    return nil, err
  }

	var info GitInfo2

  if len(results) == 0 {
    return &info, nil
  }

  info.Ahead = new(bool)
  info.Dirty = new(bool)

	// Parse the git status result.
  status := results["git-status"]
	var scanner = bufio.NewScanner(bytes.NewReader(status))

  // Regex to match the "branch" line from git status --branch --porcelain. If
  // this matches, the local branch is ahead of the remote branch.
  statusBranchAheadRegex := regexp.MustCompile("^\\#\\# .* \\[ahead [0-9]+\\]$")

	// Stop looping if we set both Ahead and Dirty to true.
	for scanner.Scan() && !(*info.Ahead && *info.Dirty) {
		var line = scanner.Text()
		if strings.HasPrefix(line, "## ") {
			// This is the "branch" line.
			if statusBranchAheadRegex.FindStringIndex(line) != nil {
				*info.Ahead = true
			}
		} else {
			// This is not the "branch" line, so it must indicate that a file is
			// dirty.
			*info.Dirty = true
		}
	}

	return &info, nil
}

// Formats a GitInfo as a string, suitable for display in a prompt.
func (info *GitInfo2) String() string {
  var str = ""
	if info.Ahead != nil && *info.Ahead {
		str += "^"
	}
	if info.Dirty != nil && *info.Dirty {
		str += "*"
	}
	return str
}
