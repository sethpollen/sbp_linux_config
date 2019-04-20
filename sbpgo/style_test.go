package sbpgo_test

import (
	"strconv"
	"testing"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo"

func TestEmpty(t *testing.T) {
	var p StyledString
	if p.AnsiString(true) != "" {
		t.Error("String ==", strconv.Quote(p.AnsiString(true)))
	}
	if p.PlainString() != "" {
		t.Error("PlainString ==", strconv.Quote(p.PlainString()))
	}
}

// TODO: more test coverage

func TestStyle(t *testing.T) {
	var p StyledString = Stylize("abc", Red, nil, true)
	if p.AnsiString(true) != "%{\x1b[0;38;2;255;0;0;1m%}abc%{\x1b[0m%}" {
		t.Error("String ==", strconv.Quote(p.AnsiString(true)))
	}
	if p.PlainString() != "abc" {
		t.Error("PlainString ==", strconv.Quote(p.PlainString()))
	}
}

func TestAppend(t *testing.T) {
	var p StyledString = Stylize("ab", Red, nil, true)
	p = append(p, Stylize("cd", Red, nil, true)...)
	p = append(p, Stylize(" ef", Black, nil, true)...)
	if p.AnsiString(true) !=
		"%{\x1b[0;38;2;255;0;0;1m%}abcd %{\x1b[0;38;2;0;0;0;1m%}ef%{\x1b[0m%}" {
		t.Error("String ==", strconv.Quote(p.AnsiString(true)))
	}
	if p.PlainString() != "abcd ef" {
		t.Error("PlainString ==", strconv.Quote(p.PlainString()))
	}
}
