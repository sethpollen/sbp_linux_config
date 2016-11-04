package main

import (
	"flag"
	"fmt"
  "github.com/sethpollen/sbp_linux_config/sbpgo/games/words"
  "github.com/sethpollen/sbp_linux_config/sbpgo/games/words/embed"
	"log"
)

var sample_size = flag.Int("sample_size", 20,
	"Number of words to sample.")
var sampler = flag.String("sampler", "occurrence",
	"Sampling strategy to use. Supported values are \"occurrence\" "+
		"(the default) and \"uniform\".")

func main() {
	flag.Parse()

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
	for _, word := range sample {
		fmt.Println(word)
	}
}
