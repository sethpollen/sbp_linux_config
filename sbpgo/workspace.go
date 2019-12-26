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

type WorkspaceInfo struct {
	Type int

	// Path to the workspace root.
	Root string

	// Path from the workspace root to the PWD. 'path.Join(Root, Path)' yields
	// the original PWD.
	Path string
}

// Returns nil if none of the workspace types matches.
func FindWorkspace(pwd string, corp CorpContext) (*WorkspaceInfo, error) {
	var info WorkspaceInfo
	info.Root = pwd
	info.Path = ""

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
		piece := path.Base(info.Root)
		info.Root = path.Dir(info.Root)
		info.Path = path.Join(piece, info.Path)

		if info.Root == corp.P4Root() {
			info.Type = P4
			return &info, nil
		}
	}
}
