package words

import (
	"encoding/csv"
	"fmt"
	"io"
	"os"
	"strconv"
)

type Word struct {
	Word        string
	Occurrences int64
}

type WordList struct {
	Words            []Word
	TotalOccurrences int64
}

// Reads in the list of words from a file.
func ReadWordList(path string) (*WordList, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}

	words := WordList{make([]Word, 5000), 0}
	reader := csv.NewReader(file)
	// Disable field count checking.
	reader.FieldsPerRecord = -1

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

		words.Words = append(words.Words, Word{record[1], occurrences})
		words.TotalOccurrences += occurrences
	}

	return &words, nil
}
