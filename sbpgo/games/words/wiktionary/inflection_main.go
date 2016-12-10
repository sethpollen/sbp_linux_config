package main

import (
	"encoding/csv"
  "flag"
  "fmt"
	"github.com/sethpollen/sbp_linux_config/sbpgo/games/words/wiktionary"
	"io"
	"log"
	"os"
  "regexp"
	"strings"
)

const inputCsvFile = "./sbpgo/games/words/wiktionary/dump/data/en-templates.csv"

func main() {
	flag.Parse()

	file, err := os.Open(inputCsvFile)
	if err != nil {
		log.Fatalln(err)
	}

	inflector, err := wiktionary.NewInflector()
	if err != nil {
		log.Fatalln(err)
	}
	
	// Regexes to match MediaWiki-style link expressions, such as the following:
	//  [[link]]        (simple)
	//  [[link|title]]  (aliased)
  simpleLinkRe := regexp.MustCompile("\\[\\[([^\\|\\]]+)\\]\\]")
  aliasedLinkRe := regexp.MustCompile("\\[\\[[^\\|\\]]+\\|([^\\|\\]]+)\\]\\]")

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
    invocation = simpleLinkRe.ReplaceAllString(invocation, "$1")
    invocation = aliasedLinkRe.ReplaceAllString(invocation, "$1")
    
    // TODO: Some invocations have nested invocations which mess this up.
    // Example: {{en-adj|head=[[able]]-[[body|bodied]]}}
		var invocationParts []string = strings.Split(invocation, "|")

		var partOfSpeech = invocationParts[0]
		var posEnum int
		switch partOfSpeech {
		case "noun":
			posEnum = wiktionary.Noun
    case "verb":
      posEnum = wiktionary.Verb
    case "adj":
      posEnum = wiktionary.Adjective
    case "adv":
      posEnum = wiktionary.Adverb
		default:
			log.Fatalf("Unrecognized part of speech on line %d: %s",
				line, partOfSpeech)
		}

		var args []string = invocationParts[1:]

		expanded, err := inflector.ExpandInflections(posEnum, title, args)
		if err != nil {
			log.Fatalf("Inflector failed on CSV line %d:\n%s", line, err)
		}
		
		fmt.Printf("%s -> %s\n", title, strings.Join(expanded, ", "))
	}
}
