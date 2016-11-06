package main

// TODO: Think about weighting the less frequent words a little more.
//       Perhaps add a constant offset to all occurrence counts, thus
//       mixing the two samplers we have now?

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
var sampler = flag.String("sampler", "occurrence",
	"Sampling strategy to use. Supported values are \"occurrence\" "+
		"(the default) and \"uniform\".")
var outputWidth = flag.Int("output_width", -1,
	"Width of the terminal where output will be shown.")
var duration = flag.Duration("duration", 3 * time.Minute,
  "Duration for the game timer which runs after words are printed.")

func main() {
	flag.Parse()
	rand.Seed(time.Now().UTC().UnixNano())

	if *sample_size < 0 {
		log.Fatalln("--sample_size must be nonnegative")
	}

	var samplerFunc func(*words.WordList, int) *words.WordList
	switch *sampler {
	case "occurrence":
		samplerFunc = words.SampleOccurrence
	case "uniform":
		samplerFunc = words.SampleUniform
	default:
		log.Fatalln("Unrecognized value for --sampler")
	}

	list := embed.GetWordList()

	sample := samplerFunc(list, *sample_size)
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
