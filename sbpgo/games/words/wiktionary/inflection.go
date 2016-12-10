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
  "fmt"
  "log"
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

func checkForLuaScript(dir string) (bool, error) {
	cwd, err := os.Open(".")
	if err != nil {
		return false, err
	}
	dirList, err := cwd.Readdir(-1)
	if err != nil {
		return false, err
	}
	for _, fileInfo := range dirList {
		if fileInfo.Name() == mainLuaScript {
			return true, nil
		}
	}
	return false, nil
}

func NewInflector() (*Inflector, error) {
	// We must search for the Lua files, as binaries and tests run in different
	// directories. In binaries, the Lua files may be found at
	// ./sbpgo/games/words/wiktionary. In unit tests, the Lua files are in the
	// current directory (.).
	for _, dir := range []string{".", "./sbpgo/games/words/wiktionary"} {
		found, err := checkForLuaScript(dir)
		if err != nil {
			return nil, err
		}
		if found {
			return &Inflector{dir}, nil
		}
	}
	return nil, errors.New("Could not find Lua scripts")
}

// Parts of speech which can be passed to ExpandInflections.
const (
  Noun = iota
  Verb
  // TODO: Adjective
  // TODO: Adverb
)

// 'title' should be the base word of the Wiktionary page. 'args' should be
// the args passed to the en-verb or en-noun template. The return value
// contains the expanded list of inflections, along with the original
// 'title' word.
func (self *Inflector) ExpandInflections(
	pos int, title string, args []string) ([]string, error) {
  var posStr string
  switch pos {
    case Noun:
      posStr = "nouns"
    case Verb:
      posStr = "verbs"
  }
  
	cmdArgs := []string{mainLuaScript, posStr, title}
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

	results := make(map[string]bool)
	var debugLines []string
	
	// Include the base form of the word.
	results[title] = true

	// Split the stdout into lines.
	scanner := bufio.NewScanner(strings.NewReader(stdout.String()))
	for scanner.Scan() {
    parts := strings.Split(scanner.Text(), ":")
    if len(parts) != 2 {
      return nil, fmt.Errorf("Could not parse Lua output line: \"%s\"",
                             scanner.Text())
    }
    
    key := strings.TrimSpace(parts[0])
    value := strings.TrimSpace(parts[1])
    switch key {
      case "debug":
        debugLines = append(debugLines, value)
      default:
        results[value] = true
        // Include the plural form of the present participle, e.g. "wanderings".
        if key == "present participle" && strings.HasSuffix(value, "ing") {
          results[value + "s"] = true
        }
    }
	}
	
	if len(debugLines) > 0 {
    log.Println("Lua debug logs:\n" + strings.Join(debugLines, "\n"))
  }
  
  var resultsList []string
  for result, _ := range results {
    resultsList = append(resultsList, result)
  }
	return resultsList, nil
}
