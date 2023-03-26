// Tweaks the color on i3blocks status entries.

package sbpgo

import (
	"flag"
	"fmt"
	"strings"
)

var fgColor = flag.String("fg_color", "#FFFFFF", "New foreground color to apply.")

func I3BlocksRecolorMain() {
	flag.Parse()

	var text string = ReadStdin()

	lines := strings.Split(text, "\n")
	if len(lines) > 2 {
		lines[2] = *fgColor
	} else if len(lines) == 2 {
		lines = append(lines, *fgColor)
	}

	fmt.Print(strings.Join(lines, "\n"))
}
