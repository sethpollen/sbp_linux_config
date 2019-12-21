// A prompt module which handles the case where the PWD doesn't exist. This is
// useful if you delete your PWD out from under yourself.
package sbpgo

import (
	"errors"
	"os"
	"path"
)

type missingPwdModule struct {
	missing chan bool
	err     chan error
}

// TODO: rest of this file

func (self *hgModule) Prepare(env *PromptEnv) {
	go func() {
		result, err := GetHgInfo(env.Pwd)
		if err != nil {
			self.err <- err
		} else {
			self.result <- result
		}
	}()
}

func (self *hgModule) Match(env *PromptEnv) bool {
	select {
	case <-self.err:
		return false
	case hgInfo := <-self.result:
		env.WorkspaceType = "☿"
		env.Workspace = hgInfo.RepoName
		env.Pwd = hgInfo.RelativePwd
		return true
	}
}

func HgModule() *hgModule {
	return &hgModule{make(chan *HgInfo), make(chan error)}
}
