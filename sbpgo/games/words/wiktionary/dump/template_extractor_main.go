// Utility to search over a Wiktionary dump and extract invocations of a
// particular template, such as en-verb or en-noun.

package main

import (
	"encoding/csv"
	"flag"
	"github.com/sethpollen/sbp_linux_config/sbpgo/games/words/wiktionary/dump"
	"log"
	"os"
	"regexp"
	"strings"
)

var inputFile = flag.String("input", "", "XML file to read")
var outputFile = flag.String("output", "",
	"CSV file to write. The result will have 2 columns. The first column "+
		"gives the page name where the template invocation was found, and the "+
		"second gives the template invocation, with the surrounding {{ }}")
var templateName = flag.String("template", "",
	"Name of the template whose invocations should be extracted. "+
		"Example: en-verb.")

func main() {
	flag.Parse()
	if len(*inputFile) == 0 {
		log.Fatalln("--input is required")
	}
	if len(*outputFile) == 0 {
		log.Fatalln("--output is required")
	}
	if len(*templateName) == 0 {
		log.Fatalln("--template is required")
	}

	inFile, err := os.Open(*inputFile)
	if err != nil {
		log.Fatalln(err)
	}
	outFile, err := os.Create(*outputFile)
	if err != nil {
		log.Fatalln(err)
	}
	csv := csv.NewWriter(outFile)

	re := regexp.MustCompile("\\{\\{" + *templateName + "[^\\}]*\\}\\}")
	dump.ReadDump(inFile, func(page *dump.Page) {
		for _, prefix := range []string{
			"Module:", "Wiktionary:", "Template:", "MediaWiki:"} {
			if strings.HasPrefix(page.Title, prefix) {
				// Skip these metapages.
				return
			}
		}

		for _, match := range re.FindAllString(page.Text, -1) {
			err = csv.Write([]string{page.Title, match})
			if err != nil {
				log.Fatalln(err)
			}
		}
	})

	csv.Flush()
}
