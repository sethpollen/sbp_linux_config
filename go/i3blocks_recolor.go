// Tweaks the color on i3blocks status entries.

package i3blocks_recolor

import (
	"flag"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"strings"
)

var fgColor = flag.String("fg_color", "#FFFFFF", "New foreground color to apply.")

func Main() {
	flag.Parse()

	var text string = sbpgo.ReadStdin()

	lines := strings.Split(text, "\n")
	if len(lines) > 2 {
		lines[2] = *fgColor
	} else if len(lines) == 2 {
		lines = append(lines, *fgColor)
	}

	fmt.Print(strings.Join(lines, "\n"))
}
