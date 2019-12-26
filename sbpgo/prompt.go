// Coordinates construction of a PromptEnv.
package sbpgo

import (
  "flag"
  "fmt"
  "io/ioutil"
  "log"
  "os"
  "path"
  "time"
)

var fishPid = flag.Int("fish_pid", 0,
  "PID of the fish shell which spawned this process.")

var exitCode = flag.Int("exit_code", 0,
	"Exit code of previous command. If absent, 0 is assumed.")

var width = flag.Int("width", 100,
	"Maximum number of characters which the output may occupy.")

var output = flag.String("output", "none",
	"What to print. Legal values are {'none', 'fish_prompt', 'terminal_title'}.")

var dollar = flag.Bool("dollar", true,
	"Whether to print the $ line when --output=fish_prompt.")

var showBack = flag.Bool("show_back", true,
  "Whether to display the status of pending 'back' jobs.")

var purge = flag.Bool("purge", false,
  "Whether to throw away any cached workspace information. If this is true, " +
  "we treat --output as if it were 'none'.")

// A functor which calls through to Futurize.
type Futurizer func(map[string]string) (map[string][]byte, error)

// Body of main() for the sbp-prompt binary.
func DoMain(corp CorpContext) {
  flag.Parse()

	// A homedir to use with the future.go library.
  futureHome := fmt.Sprintf("/dev/shm/sbp-fish-%d", *fishPid)

  if *purge {
    err := ClearFutures(futureHome)
    if err != nil {
      log.Fatalln(err)
    }
    // Don't print any output.
    return
  }

  futz := func(cmds map[string]string) (map[string][]byte, error) {
    return Futurize(futureHome, cmds, fishPid)
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

  env, err := buildPromptEnv(pwd, futz, corp)
  if err != nil {
    log.Fatalln(err)
  }

	switch *output {
	case "none":
	  // Do nothing.
	case "fish_prompt":
		fmt.Print(env.FishPrompt().AnsiString())
	case "terminal_title":
		fmt.Print(env.TerminalTitle())
	default:
		log.Fatalln("Invalid --output setting")
	}
}

// Construct a PromptEnv based on information from the local filesystem.
func buildPromptEnv(
    pwd string, futz Futurizer, corp CorpContext) (*PromptEnv, error) {
  e := NewPromptEnv(pwd, *width, *exitCode, *dollar, time.Now())

  pwdExists, err := DirExists(pwd)
  if err != nil {
    return nil, err
  }
  if !pwdExists {
    // The PWD doesn't even exist, so don't try to query workspace info.
    e.PwdError = true
    return e, nil
  }

  ws, err := FindWorkspace(pwd, corp)
  if err != nil {
    return nil, err
  }
  if ws == nil {
    // There is no workspace.
    return e, nil
  }

  e.Workspace = path.Base(ws.Root)
  e.WorkspaceType = WorkspaceIndicator(ws.Type)

  switch ws.Type {
  case Git:
    git, err := GetGitInfo(futz)
    if err != nil {
      return nil, err
    }
    gitStr := git.String()
    if len(gitStr) > 0 {
      e.Workspace += " " + gitStr
    }

  case Hg:
    // TODO:

  case P4:
    // TODO:
  }

  return e, nil
}
