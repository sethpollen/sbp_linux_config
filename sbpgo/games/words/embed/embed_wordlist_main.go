// Tool for converting the CSV wordlist file into a Go source file providing
// programmatic access to it without any runtime file dependencies.

package main

import (
  "flag"
  "fmt"
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

	list, err := words.ReadWordList(*sourceFile)
	if err != nil {
		log.Fatalln(err)
	}

	out, err := os.Create(*destFile)
	if err != nil {
		log.Fatalln(err)
	}

	// TODO: more
	var header = `
    package embed

    import "github.com/sethpollen/sbp_linux_config/sbpgo/games/words"

    func GetWordList() *words.WordList {
      return &words.WordList{[]words.Word{`
  var footer = fmt.Sprintf(`
      }, %d}
    }`, list.TotalOccurrences)

  out.Write([]byte(header))
  for _, word := range list.Words {
    out.Write([]byte(fmt.Sprintf("words.Word{%q, %d},\n",
                                 word.Word, word.Occurrences)))
  }
  out.Write([]byte(footer))
}
