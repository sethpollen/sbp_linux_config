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
    t.Errorf("[%s] Unexpected command success", argvStr)
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

func TestBasicWorkflow(t *testing.T) {
  call(t, []string{"ls"}, true, "", "")
  call(t, []string{"fork", "job", "echo foo"}, true, "", "")
  time.Sleep(100 * time.Millisecond)
  call(t, []string{"ls"}, true, "job *\n", "")
  call(t, []string{"peek", "job"}, true, "foo\n", "")
  call(t, []string{"join", "job"}, true, "foo\n", "")
}

func TestJobPassedAsMultiplePieces(t *testing.T) {
  call(t, []string{"fork", "job", "echo", "foo;", "and echo bar"}, true, "", "")
  time.Sleep(100 * time.Millisecond)
  call(t, []string{"join", "job"}, true, "foo\nbar\n", "")
}

func TestKill(t *testing.T) {
  call(t, []string{"fork", "job", "echo foo; and sleep 100000"}, true, "", "")
  time.Sleep(100 * time.Millisecond)
  call(t, []string{"join", "job"}, false, "", "Job still running: job\n")
  call(t, []string{"ls"}, true, "job\n", "")
  call(t, []string{"kill", "job"}, true, "foo\n", "")

  // Kill should have fully reclaimed the job.
  call(t, []string{"join", "job"}, false, "", "Job does not exist: job\n")
}

func TestKillCompletedJob(t *testing.T) {
  call(t, []string{"fork", "job", "echo foo"}, true, "", "")
  time.Sleep(100 * time.Millisecond)
  call(t, []string{"kill", "job"}, true, "foo\n", "")
}

func TestJobNotFound(t *testing.T) {
  call(t, []string{"peek", "job"}, false, "", "Job does not exist: job\n")
  call(t, []string{"kill", "job"}, false, "", "Job does not exist: job\n")
  call(t, []string{"join", "job"}, false, "", "Job does not exist: job\n")
}

func TestEmptyJob(t *testing.T) {
  call(t, []string{"fork", "job"}, true, "", "")
  time.Sleep(100 * time.Millisecond)
  call(t, []string{"join", "job"}, true, "", "")
}

func TestLs(t *testing.T) {
  call(t, []string{"fork", "a", "sleep 100000"}, true, "", "")
  call(t, []string{"fork", "b"}, true, "", "")
  call(t, []string{"fork", "c", "sleep 100000"}, true, "", "")
  call(t, []string{"fork", "d"}, true, "", "")
  time.Sleep(100 * time.Millisecond)

  call(t, []string{"ls"}, true, "b *\nd *\na\nc\n", "")
  call(t, []string{"ls_completed"}, true, "b\nd\n", "")

  // Clean up.
  call(t, []string{"kill", "a"}, true, "", "")
  call(t, []string{"kill", "b"}, true, "", "")
  call(t, []string{"kill", "c"}, true, "", "")
  call(t, []string{"kill", "d"}, true, "", "")
}

func TestMissingArgs(t *testing.T) {
  call(t, []string{"fork"}, false, "", "No job specified\n")
  call(t, []string{"peek"}, false, "", "No job specified\n")
  call(t, []string{"join"}, false, "", "No job specified\n")
  call(t, []string{"kill"}, false, "", "No job specified\n")
}

func TestTooManyArgs(t *testing.T) {
  call(t, []string{"ls", "foo"}, false, "", "Too many args: foo\n")
  call(t, []string{"peek", "job", "foo"}, false, "", "Too many args: foo\n")
  call(t, []string{"join", "job", "foo"}, false, "", "Too many args: foo\n")
  call(t, []string{"kill", "job", "foo"}, false, "", "Too many args: foo\n")
}

