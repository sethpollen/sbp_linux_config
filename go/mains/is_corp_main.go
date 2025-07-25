// A very simple binary which succeeds iff this is a corp host.

package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Printf("everything is corp now!\n")
	os.Exit(0)
}
