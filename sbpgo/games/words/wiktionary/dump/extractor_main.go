// Utility to search over a Wiktionary dump and extract page contents.

package main

import (
	"flag"
	"github.com/sethpollen/sbp_linux_config/sbpgo/games/words/wiktionary/dump"
	"io/ioutil"
	"log"
	"os"
	"path"
	"strconv"
	"strings"
)

var inputFile = flag.String("input", "", "XML file to read")
var outputDir = flag.String("output_dir", "",
	"Directory to dump Module: page contents")

func main() {
	flag.Parse()
	if len(*inputFile) == 0 {
		log.Fatalln("--input is required")
	}
	if len(*outputDir) == 0 {
		log.Fatalln("--output_dir is required")
	}

	file, err := os.Open(*inputFile)
	if err != nil {
		log.Fatalln(err)
	}

	filesWritten := 0
	dump.ReadDump(file, func(page *dump.Page) {
		if strings.HasPrefix(page.Title, "Module:") {
			// We can't use page.Title as the output filename, since page Titles
			// can contain characters like '/'.
			outputFile := path.Join(*outputDir, strconv.Itoa(filesWritten)+".txt")
			filesWritten++

			// Include the page title at the beginning of the file.
			err = ioutil.WriteFile(outputFile,
				[]byte(page.Title+"\n\n"+page.Text), 0660)
			if err != nil {
				log.Fatalln(err)
			}

			log.Println("Extracted ", page.Title)
		}
	})
}
