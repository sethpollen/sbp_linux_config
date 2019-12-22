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

var exitCode = flag.Int("exit_code", 0,
	"Exit code of previous command. If absent, 0 is assumed.")

var width = flag.Int("width", 100,
	"Maximum number of characters which the output may occupy.")

var dollar = flag.Bool("dollar", true,
	"Whether to print the $ line in fish_prompt mode.")

var backLsTop = flag.String("back_ls_top", "",
	"(Optional) top line from running `back ls`. Used to add information about "+
		"detached jobs to the prompt.")

// TODO: clean up w.r.t. prepare mode
var output = flag.String("output", "",
	"What to print. Legal values are 'fish_prompt', 'terminal_title'.")

// TODO: If this is true, run all the modules but have them dump their results
// to files in /dev/shm. Then send SIGUSR1 to the fish shell to make it redraw
// the prompt using these values. Maybe send SIGUSR1 after each update to
// /dev/shm to get incremental updates.
var prepare = flag.Bool("prepare", false, "")

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
	var env = NewPromptEnv(pwd, *width, *exitCode, *backLsTop, now)
	env.Dollar = *dollar

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
		fmt.Print(env.FishPrompt().AnsiString())
	case "terminal_title":
		fmt.Print(env.TerminalTitle())
	default:
		return errors.New("Invalid --output setting")
	}

	return nil
}
