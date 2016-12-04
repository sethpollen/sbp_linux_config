package wiktionary_test

import (
	"testing"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo/games/words/wiktionary"

type Case struct {
	Pos   string
	Title string
	Args  []string
	// Expected results.
	Inflections []string
}

func MakeCases() []Case {
	return []Case{
		Case{"verb", "pound",
			[]string{},
			[]string{"pound", "pounds", "pounding", "pounded"}},
		Case{"verb", "dictionary",
			[]string{"dictionar", "ies"},
			[]string{"dictionary", "dictionaries", "dictionarying", "dictionaried"}},
		Case{"verb", "free",
			[]string{"d"},
			[]string{"free", "frees", "freeing", "freed"}},
		Case{"verb", "cat",
			[]string{"catt"},
			[]string{"cat", "cats", "catting", "catted"}},
		// TODO: this case is failing. I think it's because things like past2=crew
		// have to be passed under the key "past2" in the Lua table, rather than
		// a numeric key. Experimentation indicates that named parameters do not take
    // up spaces in the numeric parameter list, meaning "crowed" would go at index
    // 4 (1-based).
		Case{"verb", "crow",
			[]string{"crows", "crowing", "crowed", "past2=crew", "past2_qual=UK", "crowed"},
			[]string{"crow", "crows", "crowing", "crew", "crowed"}},
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
		for i := range actual {
			if actual[i] != c.Inflections[i] {
				t.Fatalf("Unexpected result: %v\n%v", actual, c)
				break
			}
		}
	}
}
