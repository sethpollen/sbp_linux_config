// Spawns an i3status process. i3status already has code to fetch lots of
// useful stats, so we run it and just add our own custom stats on top.

package stator

import (
	"os/exec"
	"strings"
)

// i3status has to monitor different disk paths on different systems;
// we use this placeholder for the monitored path in the heredoc below.
const diskPathPlaceholder = "__DISK_PATH__"

// i3status.conf file we feed into the child process.
const i3statusConf = `
general {
  # Let i3status pick colors in most cases.
  colors = true
  # Update every 2 seconds. We use this clock to drive the Go part of
  # the system, too.
  interval = 2
  output_format = "i3bar"
}

# The format strings we use below are not intended to look pretty. We just
# read them in and format them nicely in Go.

order += "volume master"
volume master {
  format = "%volume"
  device = "default"
  mixer = "Master"
  mixer_idx = 0
}

order += "wireless wlan0"
wireless wlan0 {
  format_up = "%essid %ip %quality"
  format_down = ""
}

order += "ethernet em1"
ethernet em1 {
  format_up = "%ip %speed"
  format_down = ""
}

order += "cpu_usage"
cpu_usage {
  format = "%usage"
}

order += "disk __DISK_PATH__"
disk "__DISK_PATH__" {
  format = "%avail"
}

order += "cpu_temperature 0"
cpu_temperature 0 {
  format = "%degrees"
}
`

// Represents a snapshot of i3status's output, as configured above.
type I3Status struct {
}

func getI3StatusConf(diskPath string) string {
	return strings.Replace(i3statusConf, diskPathPlaceholder, diskPath, -1)
}

// TODO: Check that the spawned process exits when the Go process exits.
func StartI3Status() <-chan *I3Status {
	cmd := exec.Command("i3status", "-c")
	cmd.Start()
	channel := make(chan *I3Status)
	return channel
}
