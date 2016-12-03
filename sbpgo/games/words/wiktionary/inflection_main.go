package main

import (
	"encoding/csv"
	"flag"
	"github.com/sethpollen/sbp_linux_config/sbpgo/games/words/wiktionary"
	"io"
	"log"
	"os"
	"strings"
)

var inputFile = flag.String("input", "", "CSV file to read")

func main() {
	flag.Parse()
	if len(*inputFile) == 0 {
		log.Fatalln("--input is required")
	}

	file, err := os.Open(*inputFile)
	if err != nil {
		log.Fatalln(err)
	}

	inflector, err := wiktionary.NewInflector()
	if err != nil {
		log.Fatalln(err)
	}

	csv := csv.NewReader(file)
	var line int = 0

	for {
		record, err := csv.Read()
		line++
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatalln(err)
		}

		var title string = record[0]

		var invocation string = record[1]
		invocation = strings.TrimPrefix(invocation, "{{en-")
		invocation = strings.TrimSuffix(invocation, "}}")
		var invocationParts []string = strings.Split(invocation, "|")

		var partOfSpeech = invocationParts[0]
		if partOfSpeech != "noun" && partOfSpeech != "verb" {
			log.Fatalf("Unrecognized part of speech on line %d: %s",
				line, partOfSpeech)
		}

		var args []string = invocationParts[1:]

		_, err = inflector.ExpandInflections(partOfSpeech, title, args)
		if err != nil {
			log.Fatalf("Lua invocation failed on line %d:\n%s", line, err)
		}
	}
}
