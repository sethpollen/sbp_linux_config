// Helper library for implementers of main functions which use build prompts.
// Prints to stdout a shell script which should then be sourced to set up the
// shell.
package sbpgo

import (
  "errors"
	"flag"
	"fmt"
	"io/ioutil"
	"time"
)

var width = flag.Int("width", 100,
	"Maximum number of characters which the output may occupy.")
var output = flag.String("output", "",
  "What to print. Legal values are 'fish_prompt', 'terminal_title'")

var processStart = time.Now()

// An invoker of this helper must assemble a list of "modules" to be executed
// for each command prompt.
type Module interface {
	// Always invoked on every Module before trying to match any of them.
	Prepare(env *PromptEnv)

	// If the match succeeds, modifies 'env' in-place and returns true. Otherwise,
	// returns false.
	Match(env *PromptEnv) bool
}

// Entry point. Executes 'modules' against the current PWD, stopping once one
// of them returns true.
func DoMain(modules []Module) error {
	flag.Parse()

	var pwd = GetPwd()

	// Write the PWD to a file in /dev/shm. This allows other shells to jump
	// to the directory in use by the most recent shell.
	ioutil.WriteFile("/dev/shm/last-pwd", []byte(pwd), 0660)

  var now = time.Now()
	var env = NewPromptEnv(pwd, *width, *exitCode, now,
		// Call into tmux.
		true)

	for _, module := range modules {
		module.Prepare(env)
	}

	for _, module := range modules {
		var done bool = module.Match(env)

		if done {
			break
		}
	}

	// Write results.
  switch *output {
  case "fish_prompt":
	  fmt.Println(env.FishPrompt().AnsiString())
  case "terminal_title":
  	fmt.Println(env.TerminalTitle())
  default:
    return errors.New("Invalid --output setting")
  }

	return nil
}
