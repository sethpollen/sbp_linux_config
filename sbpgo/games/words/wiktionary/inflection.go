// Go wrapper for the Wiktionary Lua scripts for English inflections. We
// could use something like
// https://github.com/Shopify/go-lua/blob/master/README.md to execute Lua
// within our Go program, but for the time being we just shell out to the
// Lua command.

package wiktionary

import (
  "bufio"
  "bytes"
  "fmt"
  "os/exec"
  "strings"
)

// 'pos' should be "nouns", "verbs", etc. 'title' should be the base word
// of the Wiktionary page. 'args' should be the args passed to the en-verb
// or en-noun template. The return value contains the expanded list of
// inflections, along with the original 'title' word.
func ExpandInflections(pos, title string, args []string) ([]string, error) {
  cmdArgs := []string{"en-headword.lua", pos, title}
  cmdArgs = append(cmdArgs, args...)
  
  cmd := exec.Command("lua", cmdArgs...)
  cmd.Dir = "./sbpgo/games/words/wiktionary"
  
  var stdout bytes.Buffer
  cmd.Stdout = &stdout
  var stderr bytes.Buffer
  cmd.Stderr = &stderr
  
  err := cmd.Run()
  if err != nil {
    return nil, fmt.Errorf(stderr.String())
  }

  results := []string{title}
  scanner := bufio.NewScanner(strings.NewReader(stdout.String()))
  for scanner.Scan() {
    results = append(results, scanner.Text())
  }
  return results, nil
}
