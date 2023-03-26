package prompt

import (
	"flag"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/futures"
	"github.com/sethpollen/sbp_linux_config/git"
	"github.com/sethpollen/sbp_linux_config/hg"
	"github.com/sethpollen/sbp_linux_config/p4"
	"github.com/sethpollen/sbp_linux_config/prompt_builder"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"io/ioutil"
	"log"
	"os"
	"path"
	"time"
)

var mode = flag.String("mode", "",
	"There are 3 modes:\n"+
		"  fast: For standard interactive prompts; renders the prompt\n"+
		"    incrementally, signalling fish to redraw it every time new\n"+
		"    information becomes available.\n"+
		"  slow: For use by 'back'. Blocks until the prompt can be rendered\n"+
		"    completely.\n"+
		"  purge: Doesn't ouptut anything; just purges the cache of information\n"+
		"    used in 'fast' mode.")

var output = flag.String("output", "",
	"What to print. Legal values are {'fish_prompt', 'terminal_title'}.")

var fishPid = flag.Int("fish_pid", 0,
	"PID of the fish shell which spawned this process. Required when \n"+
		"--mode=fast or --mode=purge.")

var exitCode = flag.Int("exit_code", 0,
	"Exit code of previous command. If absent, 0 is assumed.")

var width = flag.Int("width", 100,
	"Maximum number of characters which the output may occupy.")

var dollar = flag.Bool("dollar", true,
	"Whether to print the $ line when --output=fish_prompt.")

var showBack = flag.Bool("show_back", true,
	"Whether to display the status of pending 'back' jobs.")

// Body of main() for the binary which generates my fish shell prompt.
func Main() {
	flag.Parse()

	if *mode != "slow" && *fishPid == 0 {
		log.Fatalln("--fish_pid is required when --mode is not 'slow'")
	}

	futureHome := fmt.Sprintf("/dev/shm/sbp-fish-%d", *fishPid)
	var futz futures.Futurizer

	switch *mode {
	case "fast":
		// Use real asynchrony.
		futz = func(cmds map[string]string) (map[string][]byte, error) {
			return futures.Futurize(futureHome, cmds, fishPid)
		}

	case "slow":
		// Use a fake Futurizer which actually does everything synchronously.
		futz = func(cmds map[string]string) (map[string][]byte, error) {
			var env map[string]string
			return futures.FuturizeSync(cmds, env)
		}

	case "purge":
		err := futures.Clear(futureHome)
		if err != nil {
			log.Fatalln(err)
		}
		// Don't print any output.
		return

	default:
		log.Fatalln("Invalid --mode setting: " + *mode)
	}

	// If possible, get the pwd from $PWD, as this usually does the right thing
	// with symlinks (i.e. it shows the path you used to get here, not the
	// actual physical path). If $PWD fails, fall back on os.Getwd().
	pwd := os.Getenv("PWD")
	if len(pwd) == 0 {
		pwd, _ = os.Getwd()
	}

	// Write the PWD to a file in /dev/shm. This allows other shells to jump
	// to the directory in use by the most recent shell.
	ioutil.WriteFile("/dev/shm/sbp-last-pwd", []byte(pwd), 0660)

	env, err := buildPromptEnv(pwd, futz)
	if err != nil {
		log.Fatalln(err)
	}

	switch *output {
	case "fish_prompt":
		fmt.Print(env.FishPrompt().AnsiString())
	case "terminal_title":
		fmt.Print(env.TerminalTitle())
	default:
		log.Fatalln("Invalid --output setting: " + *output)
	}
}

// Construct a PromptEnv based on information from the local filesystem.
func buildPromptEnv(
	pwd string, futz futures.Futurizer) (*prompt_builder.PromptEnv, error) {
	var err error
	e := prompt_builder.NewPromptEnv(pwd, *width, *exitCode, *dollar, time.Now())

	if *showBack {
		e.BackJobs, err = futures.List(path.Join(e.Home, ".back"))
		if err != nil {
			return nil, err
		}
	}

	pwdExists, err := sbpgo.DirExists(pwd)
	if err != nil {
		return nil, err
	}
	if !pwdExists {
		// The PWD doesn't even exist, so don't try to query workspace info.
		e.PwdError = true
		return e, nil
	}

	ws, err := sbpgo.FindWorkspace(pwd)
	if err != nil {
		return nil, err
	}
	if ws == nil {
		// There is no workspace.
		return e, nil
	}

	e.Pwd = ws.Path
	e.Workspace = path.Base(ws.Root)
	e.WorkspaceType = sbpgo.WorkspaceIndicator(ws.Type)

	var status *sbpgo.WorkspaceStatus
	switch ws.Type {
	case sbpgo.Git:
		status, err = git.Status(futz)

	case sbpgo.Hg:
		status, err = hg.Status(futz)

	case sbpgo.P4:
		status, err = p4.Status(futz)
	}

	if err != nil {
		return nil, err
	}

	if status != nil {
		e.WorkspaceStatus = status.String()
	}

	return e, nil
}
