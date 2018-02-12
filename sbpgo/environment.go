// Defines some environment variables I like to have in all contexts.

package sbpgo

import (
	"errors"
	"os"
	"path"
)

func isDir(path string) bool {
	f, err := os.Open(path)
	if err != nil {
		return false
	}
	info, err := f.Stat()
	if err != nil {
		return false
	}
	return info.IsDir()
}

func StandardEnviron() (*EnvironMod, error) {
	var env = NewEnvironMod()

	var sentinel = os.Getenv("SBP_ENVIRONMENT_SENTINEL")
	if len(sentinel) > 0 {
		// Looks like the environment has already been applied.
		return env, nil
	}
	env.SetVar("SBP_ENVIRONMENT_SENTINEL", "1")

	var home = os.Getenv("HOME")
	if len(home) == 0 {
		return nil, errors.New("$HOME not set")
	}
	var pathVar = os.Getenv("PATH")
	if len(pathVar) == 0 {
		return nil, errors.New("$PATH not set")
	}
	var pythonPathVar = os.Getenv("PYTHONPATH")
	if len(pythonPathVar) == 0 {
		return nil, errors.New("$PYTHONPATH not set")
	}

	env.SetVar("EDITOR", "vim")
	env.SetVar("TERMINAL", "terminator")
	env.SetVar("MAILDIR", path.Join(home, "Maildir"))

	pathVar = path.Join(home, "bin") + ":" + pathVar
	if isDir("/usr/games") {
		pathVar += ":/usr/games"
	}
	env.SetVar("PATH", pathVar)

	var homePython = path.Join(home, "python")
	if isDir(homePython) {
		pythonPathVar += ":" + homePython
	}
	env.SetVar("PYTHONPATH", pythonPathVar)

	return env, nil
}
