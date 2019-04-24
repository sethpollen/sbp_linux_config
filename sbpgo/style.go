// Library for inserting ANSI escapes into prompt strings.
package sbpgo

import (
	"bytes"
	"fmt"
	"strings"
	"unicode/utf8"
)

// A string of text, with some formatting markers.
type StyledString []StyledRune

type StyledRune struct {
	Style Style
	Text  rune
}

// 24-bit color.
type Color struct {
	R byte
	G byte
	B byte
}

func Rgb(r, g, b byte) Color {
	return Color{r, g, b}
}

func (self Color) Join(sep string) string {
	return fmt.Sprintf("%d%s%d%s%d", self.R, sep, self.G, sep, self.B)
}

// Some standard colors.
var Black = Rgb(0, 0, 0)
var Red = Rgb(255, 0, 0)
var Green = Rgb(0, 255, 0)
var Blue = Rgb(0, 0, 255)
var Yellow = Rgb(255, 255, 0)
var White = Rgb(255, 255, 255)

type Style struct {
	// Nil means use the default.
	Fg *Color
	Bg *Color
}

// Constructs a StyledString containing the given 'text' with the given
// 'color' and style 'modifier'.
func Stylize(text string, fg *Color, bg *Color) StyledString {
	var runes = utf8.RuneCountInString(text)
	var result StyledString = make([]StyledRune, runes)
	var i int = 0
	for _, r := range text {
		result[i] = StyledRune{Style{fg, bg}, r}
		i++
	}
	return result
}

// Constructs a StyledString containing the given 'text' and a "don't care"
// style. Good for use with whitespace.
func Unstyled(text string) StyledString {
	return Stylize(text, nil, nil)
}

// Formats a Style as an ANSI escape sequence. See
// https://en.wikipedia.org/wiki/ANSI_escape_code#Escape_sequences.
func (self Style) toAnsi() string {
	// Start by clearing any pre-existing style.
	var commands = []string{"0"}

	if self.Fg != nil {
		commands = append(commands, "38;2;"+self.Fg.Join(";"))
	}
	if self.Bg != nil {
		commands = append(commands, "48;2;"+self.Bg.Join(";"))
	}

	return "\033[" + strings.Join(commands, ";") + "m"
}

// Formats a Style as a tmux color escape sequence.
func (self Style) toTmux() string {
	// Tmux doesn't have a concept of "default" style, so we assume a black
	// background and green foreground by default.
	var fg Color = Green
	if self.Fg != nil {
	  fg = *self.Fg
	}
	var bg Color = Black
	if self.Bg != nil {
	  bg = *self.Bg
	}

	var formatColor = func(c Color) string {
	  return fmt.Sprintf("#%02x%02x%02x", c.R, c.G, c.B)
	}

	return fmt.Sprintf("#[bg=%s,fg=%s]", formatColor(bg), formatColor(fg))
}

// Common logic for AnsiString and TmuxString.
func (self StyledString) toString(styler func(Style)string) string {
	var buffer bytes.Buffer
	var first = true
	var lastStyle Style

	for _, r := range self {
		if first || lastStyle != r.Style {
			// The style is changing, so insert a new style escape.
			buffer.WriteString(styler(r.Style))
			lastStyle = r.Style
		}

		buffer.WriteRune(r.Text)
		first = false
	}

	return buffer.String()
}

// Serializes this StyledString to a string with embedded ANSI color escape
// sequences.
func (self StyledString) AnsiString() string {
	var str = self.toString(func(s Style)string{return s.toAnsi()})

	if len(str) == 0 {
	  return str
	}

	// Clear style before ending.
  return str + "\033[0m"
}

// Serializes this StyledString to a string with embedded tmux color escape
// sequences.
func (self StyledString) TmuxString() string {
  return self.toString(func(s Style)string{return s.toTmux()})
}

// Returns just the text from this StyledString, without any formatting.
func (self StyledString) PlainString() string {
	var buf bytes.Buffer
	for _, r := range self {
		buf.WriteRune(r.Text)
	}
	return buf.String()
}
