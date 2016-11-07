package main

import (
	"flag"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/sbpgo"
	"github.com/sethpollen/sbp_linux_config/sbpgo/games/words"
	"github.com/sethpollen/sbp_linux_config/sbpgo/games/words/embed"
	"log"
	"math/rand"
	"sort"
	"time"
)

var sample_size = flag.Int("sample_size", 35,
	"Number of words to sample.")
var outputWidth = flag.Int("output_width", -1,
	"Width of the terminal where output will be shown.")
var duration = flag.Duration("duration", 0*time.Second,
	"Duration for the game timer which runs after words are printed.")

// The least frequent words in our top-5000 corpus occur abou 5000 times, so
// this default value of 1000 provides only a small boost to unlikely words.
var baseOccurrences = flag.Int64("base_occurrences", 1000,
	"Amount by which to bias up the sampling weight of all words.")

func main() {
	flag.Parse()
	rand.Seed(time.Now().UTC().UnixNano())

	if *sample_size < 0 {
		log.Fatalln("--sample_size must be nonnegative")
	}

	sampler := words.NewIndex(embed.GetWordList())

	// TODO: Consider getting rid of the Apples To Apples green cards. Instead,
	// we can sample our own corpus for adjectives:
	//   adjective := sampler.SamplePartOfSpeech(1, 'j', 1000)

	sample := sampler.Sample(*sample_size, *baseOccurrences)
	sort.Sort(sample)
	printWords(sample)
}

// Pretty-print words in columns on the terminal.
func printWords(words *words.WordList) {
	screenWidth := *outputWidth
	if screenWidth < 1 {
		screenWidth = 1
	}

	// We take a simple approach by using the same width for all columns. Find
	// the longest word to determine that width.
	var maxWordLength int = 0
	for _, word := range words.Words {
		if len(word.Word) > maxWordLength {
			maxWordLength = len(word.Word)
		}
	}
	columnWidth := maxWordLength + 3

	columns := int(screenWidth) / columnWidth
	if columns < 1 {
		columns = 1
	}
	rows := (words.Len() + columns - 1) / columns

	// We print down each column, then across.
	fmt.Println()
	for row := 0; row < rows; row++ {
		for col := 0; col < columns; col++ {
			var index = row + (col * rows)
			if index >= words.Len() {
				continue
			}
			fmt.Print(words.Words[index].Word)
			for i := 0; i < columnWidth-len(words.Words[index].Word); i++ {
				fmt.Print(" ")
			}
		}
		fmt.Println()
	}
	fmt.Println()

	sbpgo.VerboseSleep(*duration, true)
	fmt.Println("TIME'S UP")
}
