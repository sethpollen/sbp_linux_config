// A prompt module which handles the case where the PWD doesn't exist. This is
// useful if you delete your PWD out from under yourself.
package sbpgo

import (
	"os"
)

type missingPwdModule struct {
	missing chan bool
	err     chan error
}

func (self *missingPwdModule) Prepare(env *PromptEnv) {
	go func() {
		_, err := os.Stat(env.Pwd)
		if err == nil {
			self.missing <- false
		} else if os.IsNotExist(err) {
			self.missing <- true
		} else {
			self.err <- err
		}
	}()
}

func (self *missingPwdModule) Match(env *PromptEnv) bool {
	select {
	case <-self.err:
		return false
	case missing := <-self.missing:
		if !missing {
			return false
		}
		env.PwdError = true
		return true
	}
}

func MissingPwdModule() *missingPwdModule {
	return &missingPwdModule{make(chan bool), make(chan error)}
}
