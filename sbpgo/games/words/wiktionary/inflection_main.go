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

var skipLines = flag.Int("skip_lines", 0, "Initial CSV lines to be skipped.")

const inputCsvFile = "./sbpgo/games/words/wiktionary/dump/data/en-templates.csv"
const concurrency = 16

// Argument/return types for the ExpandInflections call.
type InflectionRequest struct {
	Line      int
	CsvRecord []string
}
type InflectionResponse struct {
	Line        int
	Pos         int
	Title       string
	Inflections []string
}

// Method run by worker threads. Will send nil to 'responseChan' once it
// finishes processing everything from 'requestChan'.
func worker(requestChan <-chan InflectionRequest,
	responseChan chan<- *InflectionResponse) {
	inflector, err := wiktionary.NewInflector()
	if err != nil {
		log.Fatalln(err)
	}

	// Regexes to match MediaWiki-style link expressions, such as the following:
	//  [[link]]        (simple)
	//  [[link|title]]  (aliased)
	simpleLinkRe := regexp.MustCompile("\\[\\[([^\\|\\]]+)\\]\\]")
	aliasedLinkRe := regexp.MustCompile("\\[\\[[^\\|\\]]+\\|([^\\|\\]]+)\\]\\]")

	for request := range requestChan {
		var title string = request.CsvRecord[0]
		if strings.Index(title, " ") >= 0 {
			// Drop any multi-word forms, as we only process corpora one word at a
			// time.
			continue
		}

		var invocation string = request.CsvRecord[1]
		invocation = strings.TrimPrefix(invocation, "{{en-")
		invocation = strings.TrimSuffix(invocation, "}}")
		invocation = simpleLinkRe.ReplaceAllString(invocation, "$1")
		invocation = aliasedLinkRe.ReplaceAllString(invocation, "$1")

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
				request.Line, partOfSpeech)
		}

		var args []string = invocationParts[1:]
		expanded, err := inflector.ExpandInflections(posEnum, title, args)
		if err != nil {
			log.Fatalf("Inflector failed on CSV line %d:\n%s", request.Line, err)
		}

		// TODO: pass regularity (i.e. did any of the expanded forms appear explicitly
		// in the invocation?)
		responseChan <- &InflectionResponse{request.Line, posEnum, title, expanded}
	}
	responseChan <- nil
}

func main() {
	flag.Parse()

	file, err := os.Open(inputCsvFile)
	if err != nil {
		log.Fatalln(err)
	}
	csv := csv.NewReader(file)

	// We farm out the Lua invocations to several goroutines for parallelism.
	requestChan := make(chan InflectionRequest, 100)
	responseChan := make(chan *InflectionResponse, 100)
	for i := 0; i < concurrency; i++ {
		go worker(requestChan, responseChan)
	}

	// Spawn another goroutine to read in the CSV file and distribute its lines
	// to the workers.
	go func() {
		for line := 1; ; line++ {
			record, err := csv.Read()
			if err == io.EOF {
				break
			} else if err != nil {
				log.Fatalln(err)
			}
			if line <= *skipLines {
				continue
			}
			requestChan <- InflectionRequest{line, record}
		}
		close(requestChan)
	}()

	// TODO: build the map of inflection to base word. If multiple base words
	// match the same inflection, choose the shortest base word.

	// Collect and print the results in the main thread.
	// TODO: inflectionToBaseWord := make(map[string]string]

	// Count the number of nils; this indicates how many workers have
	// completed.
	nils := 0
	for nils < concurrency {
		response := <-responseChan
		if response == nil {
			nils++
			continue
		}

		fmt.Printf("%06d: %s (%s) -> %s\n",
			response.Line,
			response.Title,
			wiktionary.PosName(response.Pos),
			strings.Join(response.Inflections, ", "))

		// TODO:
	}
}
