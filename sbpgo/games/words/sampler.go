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
func SampleUniform(list *WordList, n int) *WordList {
	checkSampleArgs(list, n)
	used := make(map[int]bool)
	result := NewWordList()

	for result.Len() < n {
		i := rand.Intn(len(list.Words))
		if used[i] {
			continue
		}
		used[i] = true
		result.AddWord(list.Words[i])
	}
	return result
}

// Samples 'list', weighting each word by its occurrence count.
func SampleOccurrence(list *WordList, n int) *WordList {
	checkSampleArgs(list, n)
	used := make(map[int]bool)
	result := NewWordList()

	for result.Len() < n {
		occurrence := rand.Int63n(list.TotalOccurrences)
		var i int
		for i = 0; occurrence > list.Words[i].Occurrences; i++ {
			occurrence -= list.Words[i].Occurrences
		}
		if used[i] {
			continue
		}
		used[i] = true
		result.AddWord(list.Words[i])
	}
	return result
}

// Flexible sampling function. Sampling is weighted by occurrence count, but
// every word's occurence count is biased upwards by 'baseOccurrences'.
func Sample(list *WordList, n int, baseOccurrences int) *WordList {
  // TODO:
  return nil
}
