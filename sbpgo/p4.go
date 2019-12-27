// Library for querying info from the local p4 repository which contains this
// process's working directory.

package sbpgo

import (
	"errors"
)

func P4Status(futz Futurizer, corp CorpContext) (*WorkspaceStatus, error) {
	cmd := corp.P4StatusCommand()
	if cmd == nil {
		return nil, errors.New("No P4StatusCommand")
	}

	var cmds = map[string]string{
		"p4-status": *cmd,
	}
	results, err := futz(cmds)
	if err != nil {
		return nil, err
	}

	var info WorkspaceStatus

	if len(results) == 0 {
		return &info, nil
	}

	return corp.P4Status(results["p4-status"])
}
