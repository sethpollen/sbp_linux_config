// Implements futures between processes, using `back` to manage background work.

package sbpgo

import (
)

// `back` homedir.
const backHome = "/dev/shm/sbp-future"

// Manipulates a named future. All futures exist in a global namespace rooted
// at 'backHome'.
//
// If 'purge' is true, cancels any in-progress future and deletes the result
// of any completed future. Spawns a new background process to run 'cmd'.
// Returns an error.
//
// If 'purge' is false:
//
// If no completed or in-progress future exists, spawns a background process to
// run 'cmd'. Returns an error.
//
// If an in-progress future exists, returns an error.
//
// If a completed future exists, returns its stdout.
func Future(name string, cmd string, purge bool) (string, error) {
  // TODO: purge -> `back join --kill --script`
  // Reading output -> `back join --peek --script'
  return "", nil
}
