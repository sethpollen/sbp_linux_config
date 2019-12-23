package sbpgo

import (
  "errors"
  "path"
)

// Workspace types.
const (
  NoWorkspace = iota
  Git
  Hg
  G4
)

type WorkspaceInfo struct {
  Type int
  Root string
}

func FindWorkspace(pwd string, corp CorpContext) (*WorkspaceInfo, error) {
  for ;; {
    hg, err := DirExists(path.Join(pwd, ".hg"))
    if err != nil {
      return nil, err
    }
    if hg {
      return &WorkspaceInfo{Hg, pwd}, nil
    }

    git, err := DirExists(path.Join(pwd, ".git"))
    if err != nil {
      return nil, err
    }
    if git {
      return &WorkspaceInfo{Git, pwd}, nil
    }

    if pwd == "/" {
      return nil, errors.New("No workspace found")
    }
    dir := path.Dir(pwd)

    if dir == corp.G4Root() {
      return &WorkspaceInfo{G4, path.Base(pwd)}, nil
    }

    pwd = dir
  }
}
