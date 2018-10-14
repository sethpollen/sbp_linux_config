// Pads i3blocks status entries with spaces as necessary.

package main

import (
  "flag"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"strings"
)

var left = flag.Bool("left", true, "Pad on the left.")
var right = flag.Bool("right", true, "Pad on the right.")

func padLine(line string) string {
	if len(line) == 0 {
		return line
	}
	if *left && !strings.HasPrefix(line, "▕") {
		line = " " + line
	}
	if *right && !strings.HasSuffix(line, "▏") {
		line = line + " "
	}
	return line
}

func main() {
  flag.Parse()

	var text string = sbpgo.ReadStdin()

	lines := strings.Split(text, "\n")
	for i := range lines {
		// Only pad the first 2 lines, since they contain the display text.
		if i < 2 {
			lines[i] = padLine(lines[i])
		}
	}

	fmt.Print(strings.Join(lines, "\n"))
}
