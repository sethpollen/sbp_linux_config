// Interface to network adapter statistics.
package stator

import (
	"bufio"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"os"
	"strconv"
	"strings"
	"time"
)

const (
	NetStatsFile = "/proc/net/dev"

	// Describes the format of statsFile.
	headerLines   = 2
	ifaceColumn   = 0
	rxBytesColumn = 1
	txBytesColumn = 9

	EthInterface  = "eth0"
	WifiInterface = "wlan0"
)

type NetInterfaceStats struct {
	RxBytes sbpgo.Rate
	TxBytes sbpgo.Rate
}

type NetworkMonitor struct {
	ifaces map[string]*NetInterfaceStats
}

func NewNetworkMonitor() *NetworkMonitor {
	return &NetworkMonitor{make(map[string]*NetInterfaceStats)}
}

func (self *NetworkMonitor) GetInterfaceStats(iface string) (
  NetInterfaceStats, error) {
	stats, ok := self.ifaces[iface]
	if !ok {
		return NetInterfaceStats{},
			fmt.Errorf("Network interface \"%s\" not found", iface)
	}
	return *stats, nil
}

// Updates stats by reading from 'statsFile'. Expects the same format as that
// given by /proc/net/dev.
func (self *NetworkMonitor) Update(
  statsFile string, now time.Time) error {
	f, err := os.Open(statsFile)
	if err != nil {
		return err
	}
	scanner := bufio.NewScanner(f)

	// Skip header lines.
	for i := 0; i < headerLines && scanner.Scan(); i++ {
	}

	// Begin GC pass.
	var deleteKey map[string]bool
	for key := range self.ifaces {
		deleteKey[key] = true
	}

	for scanner.Scan() {
		line := bufio.NewScanner(strings.NewReader(scanner.Text()))
		line.Split(bufio.ScanWords)

		if !line.Scan() {
			return fmt.Errorf("Could not parse %s: bad line", statsFile)
		}
		key := strings.TrimRight(line.Text(), ":")

		if !line.Scan() {
			return fmt.Errorf("Could not parse %s: bad line", statsFile)
		}
		rxBytes, err := strconv.ParseInt(line.Text(), 10, 64)
		if err != nil {
			return fmt.Errorf("Could not parse %s: bad Rx bytes", statsFile)
		}

		for i := 0; i < 8; i++ {
			if !line.Scan() {
				return fmt.Errorf("Could not parse %s: bad line", statsFile)
			}
		}
		txBytes, err := strconv.ParseInt(line.Text(), 10, 64)
		if err != nil {
			return fmt.Errorf("Could not parse %s: bad Tx bytes", statsFile)
		}

		iface, ok := self.ifaces[key]
		if !ok {
			self.ifaces[key] = &NetInterfaceStats{
				sbpgo.NewRate(now, rxBytes), sbpgo.NewRate(now, txBytes)}
		} else {
			deleteKey[key] = false
			iface.RxBytes.Update(now, rxBytes)
			iface.TxBytes.Update(now, txBytes)
		}
	}

	// Garbage collect.
	for key, performDelete := range deleteKey {
		if performDelete {
			delete(self.ifaces, key)
		}
	}

	return nil
}
