// Go wrapper for the Wiktionary Lua scripts for English inflections. We
// could use something like
// https://github.com/Shopify/go-lua/blob/master/README.md to execute Lua
// within our Go program, but for the time being we just shell out to the
// Lua command.

package wiktionary

import (
	"bufio"
	"bytes"
	"errors"
	"os"
	"os/exec"
	"strings"
)

// TODO: add a test case which passes now, then add more as corner cases
// are discovered in the data dump

type Inflector struct {
	// Directory where the Lua files may be found.
	luaDir string
}

const mainLuaScript = "en-headword.lua"

func NewInflector() (*Inflector, error) {
	// We must search for the Lua files, as binaries and tests run in different
	// directories. In binaries, the Lua files may be found at
	// ./sbpgo/games/words/wiktionary. In unit tests, the Lua files are in the
	// current directory (.).
	cwd, err := os.Open(".")
	if err != nil {
		return nil, err
	}
	dirList, err := cwd.Readdir(-1)
	if err != nil {
		return nil, err
	}
	for _, fileInfo := range dirList {
		if fileInfo.Name() == mainLuaScript {
			return &Inflector{"."}, nil
		}
	}
	return &Inflector{"./sbpgo/games/words/wiktionary"}, nil
}

// 'pos' should be "noun", "verb", etc. 'title' should be the base word
// of the Wiktionary page. 'args' should be the args passed to the en-verb
// or en-noun template. The return value contains the expanded list of
// inflections, along with the original 'title' word.
func (self *Inflector) ExpandInflections(
	pos, title string, args []string) ([]string, error) {
	cmdArgs := []string{mainLuaScript, pos + "s", title}
	cmdArgs = append(cmdArgs, args...)

	cmd := exec.Command("lua", cmdArgs...)
	cmd.Dir = self.luaDir

	var stdout bytes.Buffer
	cmd.Stdout = &stdout
	var stderr bytes.Buffer
	cmd.Stderr = &stderr

	err := cmd.Run()
	if err != nil {
		if stderr.Len() == 0 {
			return nil, err
		}
		return nil, errors.New(stderr.String())
	}

	results := []string{title}
	scanner := bufio.NewScanner(strings.NewReader(stdout.String()))
	for scanner.Scan() {
		results = append(results, scanner.Text())
	}
	return results, nil
}
