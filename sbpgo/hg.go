// Library for querying info from the local Mercurial repository which contains
// this process's working directory.

package sbpgo

import (
	"bytes"
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
		if len(bytes.TrimSpace(status)) > 0 {
			info.Dirty = true
		}
	}

	return &info, nil
}
