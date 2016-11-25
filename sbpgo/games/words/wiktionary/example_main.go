package main

import (
  "flag"
  "fmt"
  "github.com/sethpollen/sbp_linux_config/sbpgo/games/words/wiktionary"
  "log"
  "os"
)

func main() {
  flag.Parse()
  
  file, err := os.Open("/home/pollen/Downloads/go.wikt")
  if err != nil {
    log.Fatalln(err)
  }
  
  page, err := wiktionary.ParsePage(file)
  if err != nil {
    log.Fatalln(err)
  }
  
  fmt.Println(page.DebugString())
}