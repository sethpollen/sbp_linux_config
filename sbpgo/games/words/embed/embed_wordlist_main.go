// Tool for converting the CSV wordlist file into a Go source file providing
// programmatic access to it without any runtime file dependencies.

package main

import (
	"flag"
	"github.com/sethpollen/sbp_linux_config/sbpgo/games/words"
	"log"
	"os"
)

var sourceFile = flag.String("source_file", "",
	"CSV file containing wordlist data")
var destFile = flag.String("dest_file", "",
	"Go file to write")

func main() {
	flag.Parse()

	if *sourceFile == "" {
		log.Fatalln("--source_file is required")
	}
	if *destFile == "" {
		log.Fatalln("--dest_file is required")
	}

	_, err := words.ReadWordList(*sourceFile)
	if err != nil {
		log.Fatalln(err)
	}

	out, err := os.Create(*destFile)
	if err != nil {
		log.Fatalln(err)
	}

	// TODO: more
	var text = `
    package embed

    import "github.com/sethpollen/sbp_linux_config/sbpgo/games/words"

    func GetWordList() *words.WordList {
      return nil
    }`
	out.Write([]byte(text))
}
