package stator

import (
	"strconv"
)
import "github.com/sethpollen/sbp_linux_config/sbpgo"

// Gets the current backlight brightness, as a value in the range [0, 100].
func GetBacklight() (int, error) {
	out, err := sbpgo.EvalCommandSync("/", "xbacklight", "-get")
	if err != nil {
		return 0, err
	}
	percentage, err := strconv.ParseFloat(out, 64)
	if err != nil {
		return 0, err
	}
	return int(percentage + 0.5), nil
}

// Sets the current backlight brightness, as a value in the range [0, 100].
func SetBacklight(level int) error {
	_, err :=
		sbpgo.EvalCommandSync("/", "xbacklight", "-set", strconv.Itoa(level))
	return err
}

func AdjustBacklight(delta int) error {
	var subcommand string
	if delta >= 0 {
		subcommand = "-inc"
	} else {
		subcommand = "-dec"
		delta = -delta
	}

	_, err :=
		sbpgo.EvalCommandSync("/", "xbacklight", subcommand, strconv.Itoa(delta))
	return err
}
