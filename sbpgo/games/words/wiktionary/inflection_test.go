package wiktionary_test

import (
  "sort"
	"testing"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo/games/words/wiktionary"

type Case struct {
	Pos   int
	Title string
	Args  []string
	// Expected results.
	Inflections []string
}

func MakeCases() []Case {
	return []Case{
		Case{Verb, "pound",
			[]string{},
			[]string{"pound", "pounds", "pounding", "poundings", "pounded"}},
		Case{Verb, "dictionary",
			[]string{"dictionar", "ies"},
			[]string{"dictionary", "dictionaries", "dictionarying", "dictionaryings",
        "dictionaried"}},
		Case{Verb, "free",
			[]string{"d"},
			[]string{"free", "frees", "freeing", "freeings", "freed"}},
		Case{Verb, "cat",
			[]string{"catt"},
			[]string{"cat", "cats", "catting", "cattings", "catted"}},
		Case{Verb, "crow",
			[]string{"crows", "crowing", "crowed", "past2=crew", "past2_qual=UK", "crowed"},
			[]string{"crow", "crows", "crowing", "crowings", "crew", "crowed"}},
	}
}

//crow,{{en-verb|crows|crowing|crowed|past2=crew|past2_qual=UK|crowed}}

func TestInflector(t *testing.T) {
	inflector, err := NewInflector()
	if err != nil {
		t.Fatal(err)
	}

	for _, c := range MakeCases() {
		actual, err := inflector.ExpandInflections(c.Pos, c.Title, c.Args)
		if err != nil {
			t.Fatalf("Got error: %v\n%v", err, c)
		}
		if len(actual) != len(c.Inflections) {
			t.Fatalf("Unexpected result: %v\n%v", actual, c)
		}
		
		sort.Strings(actual)
    sort.Strings(c.Inflections)
    
		for i := range actual {
			if actual[i] != c.Inflections[i] {
				t.Fatalf("Unexpected result: %v\n%v", actual, c)
				break
			}
		}
	}
}
