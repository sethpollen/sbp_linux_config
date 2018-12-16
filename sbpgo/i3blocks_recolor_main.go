// Tweaks the color on i3blocks status entries.

package main

import (
	"flag"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"strings"
)

var fg = flag.String("fg", "#FFFFFF", "New foreground color to apply.")

func main() {
	flag.Parse()

	var text string = sbpgo.ReadStdin()

	lines := strings.Split(text, "\n")
	if len(lines) > 2 {
		lines[2] = *fg
	}

	fmt.Print(strings.Join(lines, "\n"))
}
