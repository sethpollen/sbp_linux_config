// Library for saving small bits of state to /dev/shm.

package shm

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

func Load(id string) ([]byte, error) {
	return ioutil.ReadFile(filename(id))
}

func Save(id string, text []byte) {
	file := filename(id)
	err := ioutil.WriteFile(file, text, 0660)
	// Writing to /dev/shm should never fail.
	if err != nil {
		panic("SaveShm: " + file)
	}
}
