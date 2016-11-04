package words

import (
	"log"
	"math/rand"
)

func checkSampleArgs(list *WordList, n int) {
	if n > len(list.Words) {
		log.Fatalf(
			"Requested sample size (%v) exceeds population size (%v)\n",
			n, len(list.Words))
	}
}

// Samples 'list' uniformly, with each word having equal weight.
func SampleUniform(list *WordList, n int) []string {
	checkSampleArgs(list, n)
	used := make(map[int]bool)
	result := make([]string, 0, n)

	for len(result) < n {
		i := rand.Intn(len(list.Words))
		if used[i] {
			continue
		}
		used[i] = true
		result = append(result, list.Words[i].Word)
	}
	return result
}

// Samples 'list', weighting each word by its occurrence count.
func SampleOccurrence(list *WordList, n int) []string {
	checkSampleArgs(list, n)
	used := make(map[int]bool)
	result := make([]string, 0, n)

	for len(result) < n {
		occurrence := rand.Int63n(list.TotalOccurrences)
		var i int
		for i = 0; occurrence > list.Words[i].Occurrences; i++ {
			occurrence -= list.Words[i].Occurrences
		}
		if used[i] {
			continue
		}
		used[i] = true
		result = append(result, list.Words[i].Word)
	}
	return result
}
