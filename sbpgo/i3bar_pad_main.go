// Pads i3blocks status entries with spaces as necessary.

package main

import (
  "bytes"
  "fmt"
  "io"
  "os"
  "strings"
)

func padLine(line string) string {
  if len(line) == 0 {
    return line
  }
  if !strings.HasPrefix(line, "▕") && !strings.HasPrefix(line, " ") {
    line = " " + line
  }
  if !strings.HasSuffix(line, "▏") && !strings.HasSuffix(line, " ") {
    line = line + " "
  }
  return line
}

func main() {
  var buf bytes.Buffer
  io.Copy(&buf, os.Stdin)
  var text string = buf.String()

  lines := strings.Split(text, "\n")
  for i := range lines {
    // Only pad the first 2 lines, since they contain the display text.
    if i < 2 {
      lines[i] = padLine(lines[i])
    }
  }

  fmt.Print(strings.Join(lines, "\n"))
}
