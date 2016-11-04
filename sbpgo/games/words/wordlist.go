package words

import (
	"encoding/csv"
	"fmt"
	"io"
	"os"
  "sort"
  "strconv"
)

type Word struct {
	Word        string
	Occurrences int64
}

type WordList struct {
  // Sorted by descending occurrence count.
  Words            []Word
	TotalOccurrences int64
}

// Reads in the list of words from a file.
func ReadWordList(path string) (*WordList, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}

	reader := csv.NewReader(file)
	// Disable field count checking.
	reader.FieldsPerRecord = -1
	
	// Our raw data may contain 2 lines with the same word if that word can be
	// used as more than one part of speech. We just add the occurrence counts
	// of these lines together.
	var words = make(map[string]*Word)
  var totalOccurrences int64 = 0

	for i := 0; true; i++ {
		record, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			return nil, err
		}
		if i < 2 {
			// Skip the first 2 lines; they are headers.
			continue
		}
		if len(record) != 5 {
			return nil, fmt.Errorf(
				"Wrong number of columns (", len(record), ") on line ", i)
		}
		occurrences, err := strconv.ParseInt(record[3], 10, 64)
		if err != nil {
			return nil, fmt.Errorf("Invalid occurrences on line ", i)
		}
		var word = record[1]
		
		// Blacklist specific words we don't like from the data file.
		if word == "n't" {
      continue
    }
		
    totalOccurrences += occurrences
		if existing, found := words[word]; found {
      existing.Occurrences += occurrences
    } else {
      words[word] = &Word{word, occurrences}
    }
	}
	
	// Convert the map to a WordList object.
	var wordList = &WordList{make([]Word, 0, len(words)), totalOccurrences}
  for _, word := range words {
    wordList.Words = append(wordList.Words, *word)
  }
  
  sort.Sort(wordSorter{wordList})
	return wordList, nil
}

// Supports sorting of WordList objects.
type wordSorter struct {
  Target *WordList
}

func (self wordSorter) Len() int {
  return len(self.Target.Words)
}

func (self wordSorter) Swap(i, j int) {
  self.Target.Words[i], self.Target.Words[j] =
      self.Target.Words[j], self.Target.Words[i]
}

func (self wordSorter) Less(i, j int) bool {
  return self.Target.Words[i].Occurrences > self.Target.Words[j].Occurrences
}