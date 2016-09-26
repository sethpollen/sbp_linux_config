package sbpgo

import (
  "time"
)

// Tracks the instantaneous rate of a monotonically nondecreasing counter.
type Rate struct {
  Time time.Time
  Value int64
  Rate float64
}

func NewRate(now time.Time, value int64) Rate {
  return Rate{now, value, 0}
}

func (self *Rate) Update(now time.Time, value int64) {
  var deltaT float64 = now.Sub(self.Time).Seconds()
  if deltaT < 0 {
    return
  }
  self.Rate = float64(value - self.Value) / deltaT
  self.Value = value
  self.Time = now
}
