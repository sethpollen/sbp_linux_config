// Extracts information about verb conjugations from a Wiktionary page.

package wiktionary

import (
	"bufio"
	"io"
	"strings"
)

func ParseVerbInfo(file io.Reader) ([]string, error) {
	scanner := bufio.NewScanner(file)
	scanner.Split(bufio.ScanLines)
	var info []string

	for scanner.Scan() {
		var line string
		line = scanner.Text()
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "{{en-verb") {
			info = append(info, line)
		}
	}
	return info, nil
}
