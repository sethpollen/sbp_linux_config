// Formats percentages as bar-charts for use in i3blocks status lines.

package main

import (
  "flag"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
  "io/ioutil"
  "regexp"
  "strconv"
  "strings"
)

var label = flag.String("label", "",
  "Label to prepend to the bar graph.")
var keepNumber = flag.Bool("keep_number", false,
  "If true, keep the numerical percentage too.")
var history = flag.Int("history", 0,
  "If positive, show a historical bar chart with this many bars.")
var historyId = flag.String("history_id", "",
  "A unique ID for history storage.")

func historyFile() string {
  return fmt.Sprintf("/dev/shm/format_percent-%s", *historyId)
}

func loadHistory() string {
  // Ignore errors. If this fails, we will just start over with an empty
  // history.
  text, _ := ioutil.ReadFile(historyFile())
  return string(text)
}

func saveHistory(text string) {
  // Ignore errors. If this fails, we will just start over with an empty
  // history.
  ioutil.WriteFile(historyFile(), []byte(text), 0770)
}

func main() {
  flag.Parse()
  percentRe := regexp.MustCompile(" *([0-9]+\\.?[0-9]*)\\% *")

	var text string = sbpgo.ReadStdin()

  match := percentRe.FindStringSubmatch(text)
  var percentStr string = match[0]
  percent, err := strconv.ParseFloat(match[1], 32)
  if err != nil {
    return
  }
  fraction := float32(percent / 100.0)

  var graph string = *label
  var newBar string = sbpgo.FractionToBar(fraction)

  if *history > 1 && len(*historyId) > 0 {
    var graphHistory string = loadHistory()
    graphHistory += newBar

    // Pad or trim to the desired size.
    for len(graphHistory) < *history {
      graphHistory = " " + graphHistory
    }
    for len(graphHistory) > *history {
      graphHistory = graphHistory[1:]
    }

    saveHistory(graphHistory)
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

  fmt.Print(strings.Replace(text, percentStr, graph, -1))
}
