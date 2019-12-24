// Covers both back_main.go and future.go by invoking back_main as a child
// process.

package sbpgo_test

import (
  "bytes"
  "os/exec"
  "strings"
  "testing"
  "time"
)

const backMain = "./linux_amd64_stripped/back_main_for_test"
const job = "test_job"

func call(t *testing.T,
          argv []string,
          expectSuccess bool,
          expectedStdout string,
          expectedStderr string) {
  c := exec.Command(backMain, argv...)

  argvStr := strings.Join(argv, " ")

  var stdout bytes.Buffer
  var stderr bytes.Buffer
  c.Stdout = &stdout
  c.Stderr = &stderr

  err := c.Run()
  if err != nil {
    _, ok := err.(*exec.ExitError)
    if !ok {
      t.Errorf("[%s] Unexpected exec failure: %v", argvStr, err)
      return
    }
    if expectSuccess {
      t.Errorf("[%s] Unexpected command failure: %v", argvStr, err)
    }
  } else if !expectSuccess {
    t.Errorf("[%s] Unexpected command success")
  }

  if bytes.Compare(stdout.Bytes(), []byte(expectedStdout)) != 0 {
    t.Errorf("[%s] Unexpected stdout:\n%s", argvStr, stdout.Bytes())
  }
  if bytes.Compare(stderr.Bytes(), []byte(expectedStderr)) != 0 {
    t.Errorf("[%s] Unexpected stderr:\n%s", argvStr, stderr.Bytes())
  }
}

func TestHelp(t *testing.T) {
  call(t, []string{}, false,
       "", "No subcommand. Try one of these:\n  ls fork join peek kill\n")
}

// TODO: test other wrong number of args cases
// TODO: test passing the command as one big string

func TestBasicWorkflow(t *testing.T) {
  call(t, []string{"ls"}, true, "", "")
  call(t, []string{"fork", job, "echo", "foo"}, true, "", "")
  time.Sleep(100 * time.Millisecond)
  call(t, []string{"ls"}, true, job + " *\n", "")
  call(t, []string{"peek", job}, true, "", "")
  call(t, []string{"join", job}, true, "", "")
}

