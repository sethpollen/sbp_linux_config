package stator_test

import (
  "testing"
  "time"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo/stator"

func TestNetworkMonitor(t *testing.T) {
  monitor := NewNetworkMonitor()
  var err error
  
  _, err = monitor.GetInterfaceStats(EthInterface)
  if err == nil {
    t.Error("Expected empty monitor initially")
  }
  _, err = monitor.GetInterfaceStats(WifiInterface)
  if err == nil {
    t.Error("Expected empty monitor initially")
  }

  err = monitor.Update(time.Now(), "./proc-net-dev-sample.txt")
  if err != nil {
    t.Error(err)
  }
  
  eth, err := monitor.GetInterfaceStats(EthInterface)
  if err != nil {
    t.Error(err)
  }
  if eth.RxBytes.Value != 0 {
    t.Error("Wrong eth Rx bytes")
  }
  if eth.TxBytes.Value != 0 {
    t.Error("Wrong eth Tx bytes")
  }
  
  wifi, err := monitor.GetInterfaceStats(WifiInterface)
  if err != nil {
    t.Error(err)
  }
  if wifi.RxBytes.Value != 34250283 {
    t.Error("Wrong wifi Rx bytes")
  }
  if wifi.TxBytes.Value != 58662599 {
    t.Error("Wrong wifi Tx bytes")
  }
}