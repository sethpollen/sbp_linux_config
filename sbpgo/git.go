// Library for querying info from a local Git repository.
package sbpgo

import (
	"bufio"
	"path"
	"regexp"
	"strings"
)

type GitInfo struct {
	// Name of this Git repo.
	RepoName string
	// Pwd, relative to the root repo path.
	RelativePwd string
	// The name of the current branch, or a short hash if we are in a detached
	// head.
	Branch string
	// True iff there are uncommitted local changes.
	Dirty bool
	// True iff there are unpushed local commits.
	Ahead bool
}

// Regex to match the "branch" line from git status --branch --porcelain. If
// this matches, the local branch is ahead of the remote branch.
var statusBranchAheadRegex = regexp.MustCompile("^\\#\\# .* \\[ahead [0-9]+\\]$")

func getBranch(pwd string) (string, error) {
	branch, err := EvalCommandSync(pwd, "git", "symbolic-ref", "HEAD")
	if err == nil {
		var branchParts = strings.Split(branch, "/")
		return branchParts[len(branchParts)-1], nil
	} else {
		// We may be in a detached head. In that case, find the hash of the detached
		// head revision.
		branch, err =
			EvalCommandSync(pwd, "git", "rev-parse", "--short", "HEAD")
		if err != nil {
			return "", err
		}
		return branch, nil
	}
}

// Queries a GitInfo for the repository that parents 'pwd'. If 'pwd' is not in
// a Git repository, returns an error.
func GetGitInfo(pwd string) (*GitInfo, error) {
	repoPath, err :=
		EvalCommandSync(pwd, "git", "rev-parse", "--show-toplevel")
	if err != nil {
		return nil, err
	}

	branchOut := make(chan string)
	branchErr := make(chan error)
	go func() {
		branch, err := getBranch(pwd)
		if err != nil {
			branchErr <- err
		} else {
			branchOut <- branch
		}
	}()

	statusOut := make(chan string)
	statusErr := make(chan error)
	go EvalCommand(statusOut, statusErr, pwd, "git", "status", "--branch", "--porcelain")

	var branch string
	select {
	case err := <-branchErr:
		return nil, err
	case branch = <-branchOut:
	}

	var status string
	select {
	case err := <-statusErr:
		return nil, err
	case status = <-statusOut:
	}

	var info = new(GitInfo)
	info.RepoName = path.Base(repoPath)
	info.RelativePwd = RelativePath(pwd, repoPath)
	info.Branch = branch

	info.Dirty = false
	info.Ahead = false

	// Parse the git status result.
	var scanner = bufio.NewScanner(strings.NewReader(status))
	// Stop looping of we set both Ahead and Dirty to true.
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

	return info, nil
}

// Formats a GitInfo as a string, suitable for use as an 'info' string in a
// prompt.
func (info *GitInfo) String() string {
	var str = info.RepoName
	if info.Branch != "master" {
		str += ": " + info.Branch
	}
	if info.Ahead || info.Dirty {
		str += " "
		if info.Ahead {
			str += "^"
		}
		if info.Dirty {
			str += "*"
		}
	}
	return str
}

// A Module that matches any directory inside a Git repo.
type gitModule struct {
	result chan *GitInfo
	err    chan error
}

func (self *gitModule) Prepare(env *PromptEnv) {
	go func() {
		result, err := GetGitInfo(env.Pwd)
		if err != nil {
			self.err <- err
		} else {
			self.result <- result
		}
	}()
}

func (self *gitModule) Match(env *PromptEnv, updateCache bool) bool {
	select {
	case <-self.err:
		return false
	case gitInfo := <-self.result:
		env.Info = gitInfo.String()
		env.Flag = append(env.Flag, Stylize("git", Red, nil, false)...)
		env.Pwd = gitInfo.RelativePwd
		return true
	}
}

func (self *gitModule) Description() string {
	return "git"
}

func GitModule() *gitModule {
	return &gitModule{make(chan *GitInfo), make(chan error)}
}
