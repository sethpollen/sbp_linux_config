// Library for inserting ANSI escapes into prompt strings.
package sbpgo

import (
	"bytes"
	"fmt"
	"unicode"
	"unicode/utf8"
)

// A string of text, with some formatting markers.
type StyledString []StyledRune

type StyledRune struct {
	Style Style
	Text  rune
}

// Colors. Don't mess with the integer values here; they are used to construct
// the ANSI escape sequences.
const (
	// TODO: support more colors and modifiers with fish
	Default = -1
	Black   = 0
	Red     = 1
	Green   = 2
	Yellow  = 3
	Blue    = 4
	Magenta = 5
	Cyan    = 6
	White   = 7
)

// Font/color modifiers.
const (
	Dim = iota
	Intense
	Bold
)

type Style struct {
	Color    int // Black, Red, etc.
	Modifier int // Dim, Intense, or Bold.
}

const resetStyleEscape = "\033[0m"

// Constructs a StyledString containing the given 'text' with the given
// 'color' and style 'modifier'.
func Stylize(text string, color int, modifier int) StyledString {
	var runes = utf8.RuneCountInString(text)
	var result StyledString = make([]StyledRune, runes)
	var i int = 0
	for _, r := range text {
		result[i] = StyledRune{Style{color, modifier}, r}
		i++
	}
	return result
}

// Constructs a StyledString containing the given 'text' and a "don't care"
// style. Good for use with whitespace.
func Unstyled(text string) StyledString {
	return Stylize(text, Default, Dim)
}

// Formats a Style as an ANSI escape sequence and returns the escape sequence.
func (self Style) toAnsi() string {
	var boldness int = 0
	var colorOffset int = 30

	switch self.Modifier {
	case Dim: // Nothing.
	case Intense:
		colorOffset = 90
	case Bold:
		boldness = 1
		colorOffset = 90
	}

	// Always precede the new style escape with a reset to avoid leakage of any
	// style elements.

	if self.Color == Default {
		return fmt.Sprintf("%s\033[%dm", resetStyleEscape, boldness)
	}

	return fmt.Sprintf("%s\033[%d;%dm", resetStyleEscape, boldness,
		self.Color+colorOffset)
}

// Serializes this StyledString to a string with embedded ANSI escape
// sequences. If 'insertPromptEscapes' is true, we will wrap all
// ANSI escape sequences in %{ %} to make them safe for prompt strings.
func (self StyledString) AnsiString(insertPromptEscapes bool) string {
	var buffer bytes.Buffer
	var first = true
	var lastStyle Style

	for _, r := range self {
		if unicode.IsSpace(r.Text) {
			// Don't bother applying style.
			buffer.WriteRune(r.Text)
			continue
		}
		if first || lastStyle != r.Style {
			// The style is changing, so insert a new style escape.
			if insertPromptEscapes {
				buffer.WriteString("%{")
			}
			buffer.WriteString(r.Style.toAnsi())
			if insertPromptEscapes {
				buffer.WriteString("%}")
			}

			first = false
			lastStyle = r.Style
		}
		buffer.WriteRune(r.Text)
	}

	// Clear style before ending.
	if !first {
		if insertPromptEscapes {
			buffer.WriteString("%{")
		}
		buffer.WriteString(resetStyleEscape)
		if insertPromptEscapes {
			buffer.WriteString("%}")
		}
	}
	return buffer.String()
}

// Returns just the text fro this StyledString, without any formatting.
func (self StyledString) PlainString() string {
	var buffer = bytes.NewBuffer(make([]byte, 0, len(self)))
	for _, r := range self {
		buffer.WriteRune(r.Text)
	}
	return buffer.String()
}
