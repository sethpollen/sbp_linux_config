// Program to stem and count words from input text files. The results are
// emitted as a CSV file with lines of the form word,count.

package main

import (
	"bufio"
	"flag"
	"fmt"
	"github.com/reiver/go-porterstemmer"
	"io"
	"log"
	"os"
	"strings"
	"unicode"
)

// Reads word from 'file', returning the stemmed word counts.
func processFile(file io.Reader) map[string]int64 {
	scanner := bufio.NewScanner(file)
	scanner.Split(bufio.ScanWords)
	for scanner.Scan() {
		var word string
		word = scanner.Text()
		word = strings.TrimFunc(word,
			func(r rune) bool { return !unicode.IsLetter(r) })
		word = porterstemmer.StemString(word)
		fmt.Println(word) // TODO:
	}
	return nil
}

// Input files are provided as bare command-line arguments. The output file is
// provided here:
var destFile = flag.String("dest_file", "",
	"CSV file to write")

func main() {
	flag.Parse()
	for _, filename := range flag.Args() {
		file, err := os.Open(filename)
		if err != nil {
			log.Fatalln(err)
		}
		processFile(file)
	}
}
