package main

import (
	"bufio"
	"bytes"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"log"
	"os/user"
	"regexp"
	"strings"
)

type GoogleCorpContext struct {
	User string
}

func pointerTo(s string) *string {
	var p = new(string)
	*p = s
	return p
}

func (self GoogleCorpContext) P4StatusCommand() *string {
	return pointerTo("g4 pending")
}

func (self GoogleCorpContext) P4Status(
	output []byte) (*sbpgo.WorkspaceStatus, error) {
	dirtyRegexp := regexp.MustCompile(
		"^(Locally modified files)|(Default change :)")
	pendingClRegexp := regexp.MustCompile(
		"^Change [0-9]+ :")

	var info sbpgo.WorkspaceStatus
	var scanner = bufio.NewScanner(bytes.NewReader(output))

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

func (self GoogleCorpContext) HgLogCommand() *string {
	// This is exactly what 'hg xl' does, except we don't pass -G and
	// thus avoid getting ASCII art.
	return pointerTo("hg log --rev smart --template google_compact")
}

func (self GoogleCorpContext) HgLog(
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

func main() {
	u, err := user.Current()
	if err != nil {
		log.Fatalln(err)
	}

	var corp GoogleCorpContext
	corp.User = u.Username

	sbpgo.DoMain(corp)
}
