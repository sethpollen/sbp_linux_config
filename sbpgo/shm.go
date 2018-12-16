// Library for saving small bits of state to /dev/shm.

package sbpgo

import (
	"fmt"
	"io/ioutil"
	"os"
	"path"
)

func historyFile(id string) string {
	if len(id) == 0 {
		panic("historyFile: empty ID")
	}
	var me string = path.Base(os.Args[0])
	return fmt.Sprintf("/dev/shm/%s-%s", me, id)
}

func LoadHistory(id string) string {
	text, err := ioutil.ReadFile(historyFile(id))
	if err != nil {
		// The file probably just doesn't exist.
		return ""
	}
	return string(text)
}

func SaveHistory(id, text string) {
	file := historyFile(id)
	err := ioutil.WriteFile(file, []byte(text), 0660)
	if err != nil {
		panic("SaveHistory: " + file)
	}
}
