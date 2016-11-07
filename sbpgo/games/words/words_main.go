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

func main() {
	flag.Parse()
	rand.Seed(time.Now().UTC().UnixNano())

	if *sample_size < 0 {
		log.Fatalln("--sample_size must be nonnegative")
	}

	fmt.Println()

	sampler := words.NewIndex(embed.GetWordList())

	// Use a value of 1000000 here to get more interesting adjectives.
	adjective := sampler.SamplePartOfSpeech(1, 'j', 1000000)
	fmt.Println("TARGET WORD: ", adjective.Words[0].Word)
	fmt.Println()

	// The least frequent words in our top-5000 corpus occur about 5000 times, so
	// this value of 1000 provides only a small boost to unlikely words.
	wordList := sampler.Sample(*sample_size, 1000)
	sort.Sort(wordList)

	fmt.Println("AVAILABLE WORDS:")
	fmt.Println()
	printWords(wordList)
	fmt.Println()

	sbpgo.VerboseSleep(*duration, true)
	fmt.Println("TIME'S UP")
	fmt.Println()
}

// Pretty-print words in columns on the terminal.
func printWords(wordList *words.WordList) {
	screenWidth := *outputWidth
	if screenWidth < 1 {
		screenWidth = 1
	}

	// We take a simple approach by using the same width for all columns. Find
	// the longest word to determine that width.
	var maxWordLength int = 0
	for _, word := range wordList.Words {
		if len(word.Word) > maxWordLength {
			maxWordLength = len(word.Word)
		}
	}
	columnWidth := maxWordLength + 3

	columns := int(screenWidth) / columnWidth
	if columns < 1 {
		columns = 1
	}
	rows := (wordList.Len() + columns - 1) / columns

	// We print down each column, then across.
	for row := 0; row < rows; row++ {
		for col := 0; col < columns; col++ {
			var index = row + (col * rows)
			if index >= wordList.Len() {
				continue
			}
			fmt.Print(wordList.Words[index].Word)
			for i := 0; i < columnWidth-len(wordList.Words[index].Word); i++ {
				fmt.Print(" ")
			}
		}
		fmt.Println()
	}
}
