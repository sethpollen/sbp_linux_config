// Covers both back.go and future.go by invoking back_main as a child process.

package sbpgo_test

import (
	"fmt"
	"os"
	"reflect"
	"testing"
	"time"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo"

// Useful for pretty-printing the results of a Futurize command.
func formatResults(results map[string][]byte) string {
	var s string
	for k, v := range results {
		s += fmt.Sprintf("\n%s -> %v", k, string(v))
	}
	return s
}

func TestFuturize(t *testing.T) {
	home := os.Getenv("TEST_TMPDIR")

	var cmds = map[string]string{
		"a": "echo a",
		"b": "",
		"c": "echo c; and sleep 100000",
		// It doesn't matter that the job fails.
		"d": "echo d; false",
	}

	// The first call to futurize starts all the jobs and returns no results.
	results, err := Futurize(home, cmds, nil)
	if err != nil {
		t.Error(err)
	}
	if !reflect.DeepEqual(results, map[string][]byte{}) {
		t.Error(formatResults(results))
	}
	time.Sleep(100 * time.Millisecond)

	// Subsequent calls receive results from two of the commands.
	for i := 0; i < 2; i++ {
		results, err = Futurize(home, cmds, nil)
		if !reflect.DeepEqual(results, map[string][]byte{
			"a": []byte("a\n"),
			"b": []byte(""),
			"d": []byte("d\n")}) {
			t.Error(formatResults(results))
		}
	}

	// Clean up.
	err = ClearFutures(home)
	if err != nil {
		t.Error(err)
	}
}

func TestFuturizeSync(t *testing.T) {
	var cmds = map[string]string{
		"a": "echo a",
		"b": "",
		// It doesn't matter that the job fails.
		"c": "echo c; false",
	}

	results, err := FuturizeSync(cmds, nil)
	if err != nil {
		t.Error(err)
	}
	if !reflect.DeepEqual(results, map[string][]byte{
		"a": []byte("a\n"),
		"b": []byte(""),
		"c": []byte("c\n")}) {
		t.Error(formatResults(results))
	}
}
