// Libraries for dealing with environment variable mappings.

package sbpgo

import (
	"bytes"
	"errors"
	"fmt"
	"os"
	"path"
	"sort"
	"strings"
)

// Represents a set of variables to set or unset in the environment.
type EnvironMod struct {
	// Keys are variable names. Values are nil for variables to unset. Otherwise,
	// values are pointers to variable values to set.
	mods map[string]*string
}

func NewEnvironMod() *EnvironMod {
	var mod = new(EnvironMod)
	mod.mods = make(map[string]*string)
	return mod
}

func (self *EnvironMod) SetVar(key, value string) {
	self.mods[key] = &value
}

func (self *EnvironMod) UnsetVar(key string) {
	self.mods[key] = nil
}

// Generates a shell script which can be sourced in a shell to apply this
// EnvironMod.
func (self *EnvironMod) ToScript() string {
	// We want to output the keys in sorted order. We have to do this sorting
	// ourselves.
	var keys []string
	for key := range self.mods {
		keys = append(keys, key)
	}
	sort.Strings(keys)

	var buf = bytes.NewBufferString("")
	for _, key := range keys {
		var value = self.mods[key]
		if value == nil {
			fmt.Fprintf(buf, "unset %s\n", key)
		} else {
			fmt.Fprintf(buf, "export %s=%s\n", key, quote(*value))
		}
	}
	return buf.String()
}

// Applies the given EnvironMod to this process's own environment.
func (self *EnvironMod) Apply() {
	for key, value := range self.mods {
		if value == nil {
			os.Unsetenv(key)
		} else {
			os.Setenv(key, *value)
		}
	}
}

// Defines some environment variables I like to have in all contexts.
func StandardEnviron() (*EnvironMod, error) {
	var env = NewEnvironMod()

	var home = os.Getenv("HOME")
	if len(home) == 0 {
		return nil, errors.New("$HOME not set")
	}

	env.SetVar("EDITOR", "vim")
	env.SetVar("TERMINAL", "terminator")
	env.SetVar("MAILDIR", path.Join(home, "Maildir"))

	var pathList = strings.Split(os.Getenv("PATH"), ":")

	if isDir("/usr/games") && !contains(pathList, "/usr/games") {
		pathList = append(pathList, "/usr/games")
	}

  // Append $HOME/bin to the end of $PATH.
	var homeBin = path.Join(home, "bin")
  if !contains(pathList, homeBin) {
	  pathList = append(pathList, homeBin)
  }

	env.SetVar("PATH", strings.Join(pathList, ":"))

	var pythonPathList = strings.Split(os.Getenv("PYTHONPATH"), ":")
	var homePython = path.Join(home, "python")
	if !contains(pythonPathList, homePython) {
		pythonPathList = append(pythonPathList, homePython)
	}
	env.SetVar("PYTHONPATH", strings.Join(pythonPathList, ":"))

	return env, nil
}

func contains(haystack []string, needle string) bool {
	for _, hay := range haystack {
		if hay == needle {
			return true
		}
	}
	return false
}

// Escapes and quotes 'text' so it may safely be embedded into a shell script.
func quote(text string) string {
	var buf = bytes.NewBuffer(make([]byte, 0, 2+2*len(text)))
	// Use single quote to avoid variable substitution.
	fmt.Fprint(buf, "'")
	for _, c := range text {
		if c == '\'' {
			fmt.Fprint(buf, "\\'")
		} else {
			// In a POSIX shell, this works even for newlines!
			fmt.Fprintf(buf, "%c", c)
		}
	}
	fmt.Fprint(buf, "'")
	return buf.String()
}

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
