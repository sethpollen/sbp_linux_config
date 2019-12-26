package main

import (
	"github.com/sethpollen/sbp_linux_config/sbpgo"
)

type DummyCorpContext struct {}

func (self DummyCorpContext) P4Root() *string {
  return nil
}

func main() {
  var corp DummyCorpContext
	sbpgo.DoMain(corp)
}
