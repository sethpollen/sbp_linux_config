// Library for saving small bits of state to /dev/shm.

package sbpgo

import (
	"fmt"
	"io/ioutil"
	"os"
	"path"
)

func filename(id string) string {
	if len(id) == 0 {
		panic("filename: empty ID")
	}
	var me string = path.Base(os.Args[0])
	return fmt.Sprintf("/dev/shm/sbp-%s-%s", me, id)
}

func LoadShm(id string) string {
	text, err := ioutil.ReadFile(filename(id))
	if err != nil {
		// The file probably just doesn't exist.
		return ""
	}
	return string(text)
}

func SaveShm(id, text string) {
	file := filename(id)
	err := ioutil.WriteFile(file, []byte(text), 0660)
	if err != nil {
		panic("SaveShm: " + file)
	}
}
