// Formats percentages as bar-charts for use in i3blocks status lines.

package format_percent

import (
	"flag"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/num_format"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"regexp"
	"strconv"
	"strings"
	"unicode/utf8"
)

var label = flag.String("label", "",
	"Label to prepend to the bar graph.")
var keepNumber = flag.Bool("keep_number", false,
	"If true, keep the numerical percentage too.")
var history = flag.Int("history", 0,
	"If positive, show a historical bar chart with this many bars.")
var formatPercentHistoryId = flag.String("format_percent_history_id", "",
	"A unique ID for history storage.")

func Main() {
	flag.Parse()
	percentRe := regexp.MustCompile(" *([0-9]+\\.?[0-9]*)\\% *")

	var text string = sbpgo.ReadStdin()

	match := percentRe.FindStringSubmatch(text)
	if match != nil {
		var percentStr string = match[0]
		percent, err := strconv.ParseFloat(match[1], 32)
		if err != nil {
			panic("main")
		}
		fraction := float32(percent / 100.0)

		var graph string = *label
		var newBar string = num_format.FractionToBar(fraction)

		if *history > 1 && len(*formatPercentHistoryId) > 0 {
			// Ignore errors and fall back to an empty string.
			graphHistoryBytes, _ := sbpgo.LoadShm(*formatPercentHistoryId)
			var graphHistory = string(graphHistoryBytes)
			graphHistory += newBar

			// Pad or trim to the desired size.
			for utf8.RuneCountInString(graphHistory) < *history {
				graphHistory = " " + graphHistory
			}
			for utf8.RuneCountInString(graphHistory) > *history {
				_, width := utf8.DecodeRuneInString(graphHistory)
				graphHistory = graphHistory[width:]
			}

			sbpgo.SaveShm(*formatPercentHistoryId, []byte(graphHistory))
			graph += graphHistory
		} else {
			graph += "▕" + newBar
		}
		graph += "▏"

		if *keepNumber {
			var percentInt = int64(percent)
			// Make sure it fits into 2 digits.
			if percentInt > 99 {
				percentInt = 99
			}
			graph += fmt.Sprintf("%02d%%", percentInt)
		}

		text = strings.Replace(text, percentStr, graph, -1)
	}

	fmt.Print(text)
}
