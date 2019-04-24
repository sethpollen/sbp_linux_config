// Helper library for implementers of main functions which use build prompts.
// Prints to stdout a shell script which should then be sourced to set up the
// shell.
package sbpgo

import (
	"flag"
	"fmt"
	"io/ioutil"
	"time"
)

var width = flag.Int("width", 100,
	"Maximum number of characters which the output may occupy.")
var printTiming = flag.Bool("print_timing", false,
	"True to log diagnostics about how long each part of the program takes.")

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

	pwd := GetPwd()

	// Write the PWD to a file in /dev/shm. This allows other shells to jump
	// to the directory in use by the most recent shell.
	ioutil.WriteFile("/dev/shm/last-pwd", []byte(pwd), 0660)

	now := time.Now()
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

	// Report the amount of time we spent generating the prompt.
	var elapsed = time.Now().Sub(processStart)
	env.EnvironMod.SetVar("PROMPT_GENERATION_SECONDS",
		fmt.Sprintf("%f", elapsed.Seconds()))

	// Write results.
	fmt.Println(env.ToScript())

	return nil
}
