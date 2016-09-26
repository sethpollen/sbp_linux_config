package sbpgo_test

import (
  "testing"
  "time"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo"

func TestRate(t *testing.T) {
  now := time.Unix(0, 0)
  rate := NewRate(now, 9)
  
  if rate.Rate != 0 {
    t.Error("Initial rate should be zero")
  }
  
  rate.Update(now.Add(2 * time.Second), 10)
  if rate.Rate != 0.5 {
    t.Error("Expected 0.5, got ", rate.Rate)
  }
  
  // Ignore back-in-time updates.
  rate.Update(now, 999)
  if rate.Rate != 0.5 {
    t.Error("Expected 0.5, got ", rate.Rate)
  }  
}
