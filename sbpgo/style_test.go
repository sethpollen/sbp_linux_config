package sbpgo_test

import (
	"strconv"
	"testing"
)
import . "github.com/sethpollen/sbp_linux_config/sbpgo"

func TestEmpty(t *testing.T) {
	var p StyledString
	if p.AnsiString() != "" {
		t.Error("String ==", strconv.Quote(p.AnsiString()))
	}
	if p.PlainString() != "" {
		t.Error("PlainString ==", strconv.Quote(p.PlainString()))
	}
}

// TODO: more test coverage

func TestStyle(t *testing.T) {
	var p StyledString = StylizeBold("abc", Red, nil)
	if p.AnsiString() != "\x1b[0;38;2;255;0;0;1mabc\x1b[0m" {
		t.Error("String ==", strconv.Quote(p.AnsiString()))
	}
	if p.PlainString() != "abc" {
		t.Error("PlainString ==", strconv.Quote(p.PlainString()))
	}
}

func TestAppend(t *testing.T) {
	var p StyledString = StylizeBold("ab", Red, nil)
	p = append(p, StylizeBold("cd", Red, nil)...)
	p = append(p, StylizeBold(" ef", nil, Black)...)
	if p.AnsiString() !=
		"\x1b[0;38;2;255;0;0;1mabcd\x1b[0;48;2;0;0;0;1m ef\x1b[0m" {
		t.Error("String ==", strconv.Quote(p.AnsiString()))
	}
	if p.PlainString() != "abcd ef" {
		t.Error("PlainString ==", strconv.Quote(p.PlainString()))
	}
}
