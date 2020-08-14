// Library for invoking dmenu to get user input.

package sbpgo

import (
  "os/exec"
  "strings"
)

// Shows a dmenu with the given 'prompt' and 'options' to the user. Waits for
// the user to respond. Returns the selected option, or "" if the user closed
// the menu without choosing an option.
func Dmenu(prompt string, options []string) (string, error) {
  var argv []string
  if len(prompt) > 0 {
    argv = append(argv, "-p", prompt)
  }

  cmd := exec.Command("sbp-dmenu", argv...)
  cmd.Stdin = strings.NewReader(strings.Join(options, "\n"))
  result, err := cmd.Output()
  if err != nil {
    return "", err
  }

  return strings.TrimSpace(string(result)), nil
}
