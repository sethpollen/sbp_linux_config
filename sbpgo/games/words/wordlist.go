package words

import (
  "encoding/csv"
  "fmt"
  "io"
  "os"
  "strconv"
)

type Word struct {
  Word string
  Frequency float64
}

const csvFilePath = "./top-5000-words.csv"
const expectedWords = 5000

func GetWordlist() ([]Word, error) {
  file, err := os.Open(csvFilePath)
  if err != nil {
    return nil, err
  }
  
  words := make([]Word, 0, expectedWords)
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
    frequency, err := strconv.ParseFloat(record[3], 64)
    if err != nil {
      return nil, fmt.Errorf("Invalid frequency on line ", i)
    }
    words = append(words, Word{record[1], frequency})
  }
  
  return words, nil
}
