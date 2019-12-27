package sbpgo

import (
	"path"
)

// Workspace types.
const (
	Git = iota
	Hg
	P4
)

func WorkspaceIndicator(workspaceType int) string {
	switch workspaceType {
	case Git:
		return "🠵"
	case Hg:
		return "☿"
	case P4:
		return "⠶"
	default:
		return ""
	}
}

// Information about a workspace which can be determined cheaply.
type WorkspaceInfo struct {
	Type int

	// Path to the workspace root.
	Root string

	// Path from the workspace root to the PWD. 'path.Join(Root, Path)' yields
	// the original PWD.
	Path string
}

// Information about a workspace which can be more expensive to compute
// (generally requiring a subprocess call).
type WorkspaceStatus struct {
	// Does the workspace contain uncommited changes? This includes untracked
	// files.
	Dirty bool

	// Does the workspace contain commits which have not been pushed/uploaded?
	Ahead bool

	// Number of pending changelists (for Perforce-based workspaces only).
	PendingCls int
}

// Returns nil if none of the workspace types matches.
func FindWorkspace(pwd string, corp CorpContext) (*WorkspaceInfo, error) {
	var info WorkspaceInfo
	info.Root = pwd
	info.Path = ""

	corpP4Root := corp.P4Root()

	for {
		hg, err := DirExists(path.Join(info.Root, ".hg"))
		if err != nil {
			return nil, err
		}
		if hg {
			info.Type = Hg
			return &info, nil
		}

		git, err := DirExists(path.Join(info.Root, ".git"))
		if err != nil {
			return nil, err
		}
		if git {
			info.Type = Git
			return &info, nil
		}

		if info.Root == "/" {
			// We searched the entire path and found no evidence of a workspace.
			return nil, nil
		}

		// Shift one piece from the end of Root to the beginning of Path.
		var info2 WorkspaceInfo
		info2.Root = path.Dir(info.Root)
		info2.Path = path.Join(path.Base(info.Root), info.Path)

		if corpP4Root != nil && info2.Root == *corpP4Root {
			// Return info, not info2, since the path component
			// right after the P4Root is still part of the workspace
			// root.
			info.Type = P4
			return &info, nil
		}

		info = info2
	}
}

// Renders workspace status as a few characters, suitable for use in a prompt.
func (self WorkspaceStatus) String() string {
	var s = ""
	if self.Dirty {
		s += "*"
	}
	if self.Ahead {
		s += "^"
	}
	if self.PendingCls >= 1 {
		s += "o"
	}
	if self.PendingCls >= 2 {
		s += "o"
	}
	return s
}
