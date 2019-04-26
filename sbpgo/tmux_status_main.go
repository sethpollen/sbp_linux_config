// Generates my tmux status line (displayed at the bottom of the tmux session).

package main

import (
	"fmt"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"strings"
	"time"
)

func main() {
	now := time.Now()
	var env = sbpgo.NewPromptEnv("", 0, 0, now,
		// Don't call tmux from within our status line script.
		false)
	fmt.Print(strings.TrimRight(env.TmuxStatusLine().TmuxString(), "\n"))
}
