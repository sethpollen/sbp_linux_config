package main

import (
	"flag"
	"fmt"
  "github.com/sethpollen/sbp_linux_config/sbpgo/games/words"
  "github.com/sethpollen/sbp_linux_config/sbpgo/games/words/embed"
  "log"
  "math/rand"
  "sort"
  "time"
)

var sample_size = flag.Int("sample_size", 30,
	"Number of words to sample.")
var sampler = flag.String("sampler", "occurrence",
	"Sampling strategy to use. Supported values are \"occurrence\" "+
		"(the default) and \"uniform\".")
var outputWidth = flag.Int("output_width", -1,
  "Width of the terminal where output will be shown.")

func main() {
	flag.Parse()
  rand.Seed(time.Now().UTC().UnixNano())

	if *sample_size < 0 {
		log.Fatalln("--sample_size must be nonnegative")
	}

	var samplerFunc func(*words.WordList, int) []string
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
  sort.Strings(sample)
  printWords(sample)
}

// Pretty-print words in columns on the terminal.
func printWords(words []string) {
  screenWidth := *outputWidth
  if screenWidth < 1 {
    screenWidth = 1
  }
  
  // We take a simple approach by using the same width for all columns. Find
  // the longest word to determine that width.
  var maxWordLength int = 0
  for _, word := range words {
    if len(word) > maxWordLength {
      maxWordLength = len(word)
    }
  }
  columnWidth := maxWordLength + 2
  
  columns := int(screenWidth) / columnWidth
  if columns < 1 {
    columns = 1
  }
  rows := (len(words) + columns - 1) / columns
  
  // We print down each column, then across.
  for row := 0; row < rows; row++ {
    for col := 0; col < columns; col++ {
      var index = row + (col * rows)
      if index >= len(words) {
        continue
      }
      fmt.Print(words[index])
      for i := 0; i < columnWidth - len(words[index]); i++ {
        fmt.Print(" ")
      }
    }
    fmt.Println()
  }
}