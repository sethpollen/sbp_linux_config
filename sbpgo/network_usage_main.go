// Tool for succinctly reporting network up/down byte rates. Indented for use
// in i3blocks blocklets.

package main

import (
	"flag"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"io/ioutil"
  "log"
	"strconv"
  "strings"
  "time"
)

var iface = flag.String("iface", "",
	"Name of the network interface to use.")
var historyId = flag.String("history_id", "",
  "A unique ID for history storage.")

func readNumberFile(file string) int64 {
	text, err := ioutil.ReadFile(file)
	if err != nil {
		panic("readNumberFile: " + file)
	}
	num, err := strconv.ParseInt(strings.TrimSpace(string(text)), 10, 64)
	if err != nil {
		panic("readNumberFile: " + file)
	}
	return num
}

func readRxBytes() int64 {
	return readNumberFile(fmt.Sprintf("/sys/class/net/%s/statistics/rx_bytes",
                                    *iface))
}

func readTxBytes() int64 {
	return readNumberFile(fmt.Sprintf("/sys/class/net/%s/statistics/tx_bytes",
                                    *iface))
}

func shortBytes(x int64) string {
  // Round rates down to the nearest kibibyte and drop the "K" suffix.
  return sbpgo.ShortBytes(x / 1024, " MGT")
}

const historyFormat = "%d %d %d"

func main() {
	flag.Parse()

  if len(*iface) == 0 {
    log.Fatalln("--iface is required")
  }

  var fullHistoryId = fmt.Sprintf("%s-%s", *iface, *historyId)

  var t, rx, tx int64
  t = time.Now().UnixNano()
  rx = readRxBytes()
  tx = readTxBytes()

  // We'll assume these initial values if the history file doesn't exist.
  var oldT int64 = t
  var oldRx int64 = 0
  var oldTx int64 = 0
  fmt.Sscanf(sbpgo.LoadHistory(fullHistoryId), historyFormat,
             &oldT, &oldRx, &oldTx)

  sbpgo.SaveHistory(fullHistoryId, fmt.Sprintf(historyFormat, t, rx, tx))

  var elapsedSeconds = float64(t - oldT) / 1e9
  var rxRate, txRate float64
  if elapsedSeconds == 0 {
    // Avoid division by zero on startup.
    rxRate = 0
    txRate = 0
  } else {
    rxRate = float64(rx - oldRx) / elapsedSeconds
    txRate = float64(tx - oldTx) / elapsedSeconds
  }

  fmt.Printf("%s↑ %s↓", shortBytes(int64(txRate)), shortBytes(int64(rxRate)))
}
