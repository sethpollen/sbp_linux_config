package stator_test

import (
  "testing"
  "time"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo/stator"

func TestPowerSupplyMonitor(t *testing.T) {
  monitor := NewPowerSupplyMonitor(4)
  var err error
  
  _, err = monitor.GetStats()
  if err == nil {
    t.Error("Expected GetStats to return an error")
  }
  _, err = monitor.GetBatteryPower()
  if err == nil {
    t.Error("Expected GetBatteryPower to return an error")
  }
  
  now := time.Unix(0, 0)
  monitor.Update("./power-supply-sample-1", now)
  
  stats, err := monitor.GetStats()
  if err != nil {
    t.Error(err)
  }
  if !stats.Ac {
    t.Error("Expected stats.Ac")
  }
  if stats.NumBatteries != 1 {
    t.Error("Wrong NumBatteries: ", stats.NumBatteries)
  }
  if stats.BatteryCapacity != 180288 {
    t.Error("Wrong BatteryCapacity: ", stats.BatteryCapacity)
  }
  if stats.BatteryCharge != 177624 {
    t.Error("Wrong BatteryCharge: ", stats.BatteryCharge)
  }
  _, err = monitor.GetBatteryPower()
  if err == nil {
    t.Error("Expected GetBatteryPower to return an error")
  }
  
  now = now.Add(10 * time.Second)
  monitor.Update("./power-supply-sample-2", now)
  
  stats, err = monitor.GetStats()
  if err != nil {
    t.Error(err)
  }
  if stats.Ac {
    t.Error("Expected !stats.Ac")
  }

  power, err := monitor.GetBatteryPower()
  if err != nil {
    t.Error(err)
  }
  if power != 360 {
    t.Error("Wrong power: ", power)
  }
}