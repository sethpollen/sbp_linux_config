// Pads i3blocks status entries with spaces as necessary.

package i3blocks_pad

import (
	"flag"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/util"
	"strings"
)

func padLine(line string) string {
	if len(line) == 0 {
		return line
	}
	if !strings.HasPrefix(line, "▕") {
		line = " " + line
	}
	if !strings.HasSuffix(line, "▏") {
		line = line + " "
	}
	return line
}

func Main() {
	flag.Parse()

	var text string = util.ReadStdin()

	lines := strings.Split(text, "\n")
	for i := range lines {
		// Only pad the first 2 lines, since they contain the display text.
		if i < 2 {
			lines[i] = padLine(lines[i])
		}
	}

	fmt.Print(strings.Join(lines, "\n"))
}
