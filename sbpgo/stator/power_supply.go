// Interface to (laptop) power supply statistics.
package stator

import (
	"container/list"
	"errors"
	"io/ioutil"
	"math"
	"path"
	"strconv"
	"strings"
	"time"
)

const (
	PowerSupplyStatsRoot = "/sys/class/power_supply"
)

type PowerSupplyStats struct {
	// Whether we are on AC power.
	Ac              bool
	NumBatteries    int
	BatteryCapacity float64 // Joules
	BatteryCharge   float64 // Joules
	// Time this sample was taken.
	Time time.Time
}

type PowerSupplyMonitor struct {
	// Number of samples to retain in 'stats' for computing power over time.
	aggregationSamples int
	// Sequence of *PowerSupplyStats collected recently. Ordered by ascending
	// timestamp.
	stats *list.List
}

func NewPowerSupplyMonitor(aggregationSamples int) *PowerSupplyMonitor {
	return &PowerSupplyMonitor{aggregationSamples, list.New()}
}

// Gets the latest PowerSupplyStats.
func (self *PowerSupplyMonitor) GetStats() (PowerSupplyStats, error) {
	if self.stats.Len() == 0 {
		return PowerSupplyStats{}, errors.New("No power supply stats collected")
	}
	return *self.stats.Back().Value.(*PowerSupplyStats), nil
}

// Gets the discharge rate (in Watts) of the battery over the last
// 'aggregationSamples' calls to Update(). Returns zero if the battery is
// not discharging.
//
// Note that /sys/class/power_supply does provide a 'power_now' file, but
// its value seems to fluctuate rapidly. So I compute my own power rate
// over an interval of my own choosing.
func (self *PowerSupplyMonitor) GetBatteryPower() (float64, error) {
	if self.stats.Len() < 2 {
		return math.NaN(), errors.New("Need at least 2 samples to compute power")
	}
	back := self.stats.Back()
	front := self.stats.Front()
	deltaE := back.Value.(*PowerSupplyStats).BatteryCharge -
		front.Value.(*PowerSupplyStats).BatteryCharge
	deltaT := back.Value.(*PowerSupplyStats).Time.Sub(
		front.Value.(*PowerSupplyStats).Time).Seconds()
	return math.Max(0, -deltaE/deltaT), nil
}

// Updates stats by reading from 'statsRoot'. Expects the same directory
// structure as that /sys/class/power_supply.
func (self *PowerSupplyMonitor) Update(
	statsRoot string, time time.Time) error {
	sample, err := readPowerSupplyStats(statsRoot, time)
	if err != nil {
		return err
	}
	self.stats.PushBack(sample)
	for self.stats.Len() > self.aggregationSamples {
		self.stats.Remove(self.stats.Front())
	}
	return nil
}

func readPowerSupplyStats(statsRoot string, time time.Time) (
	*PowerSupplyStats, error) {
	devices, err := ioutil.ReadDir(statsRoot)
	if err != nil {
		return nil, err
	}

	stats := new(PowerSupplyStats)
	stats.Time = time
	for _, device := range devices {
		deviceRoot := path.Join(statsRoot, device.Name())

		switch strings.ToLower(readFile(path.Join(deviceRoot, "type"))) {
		case "mains":
			if readFile(path.Join(deviceRoot, "online")) == "1" {
				stats.Ac = true
			}

		case "battery":
			stats.NumBatteries++

			capacity, err := strconv.ParseInt(readFile(
				path.Join(deviceRoot, "energy_full_design")), 10, 64)
			if err == nil {
				stats.BatteryCapacity += microWattHoursToJoules(capacity)
			}

			charge, err := strconv.ParseInt(readFile(
				path.Join(deviceRoot, "energy_now")), 10, 64)
			if err == nil {
				stats.BatteryCharge += microWattHoursToJoules(charge)
			}
		}
	}

	if stats.NumBatteries == 0 {
		// Something must be powering the machine. Assume it's AC.
		stats.Ac = true
	}

	return stats, nil
}

func microWattHoursToJoules(x int64) float64 {
	return float64(x) * 3600 * 1e-6
}

func readFile(path string) string {
	text, err := ioutil.ReadFile(path)
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(text))
}
