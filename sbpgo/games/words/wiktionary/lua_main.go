// Go wrapper for the Wiktionary Lua scripts. We could use something like
// https://github.com/Shopify/go-lua/blob/master/README.md to execute Lua
// within our Go program, but for the time being we just shell out to the
// Lua command.

package main

import (
  "fmt"
  "github.com/sethpollen/sbp_linux_config/sbpgo/games/words/wiktionary"
  "log"
)

func main() {
  inflections, err := wiktionary.ExpandInflections(
    "verbs", "entrench", []string{})
  if err != nil {
    log.Fatalln(err)
  }
  fmt.Print(inflections)
}