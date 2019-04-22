// Library for constructing prompt strings of the specific form that I like.
package sbpgo

import (
	"bytes"
	"fmt"
	"os"
	"os/user"
	"strings"
	"time"
	"unicode/utf8"
)

// Collects information during construction of a prompt string.
type PromptEnv struct {
	// If nil, the current date/time will be omitted from the prompt string.
	Now            time.Time
	Home           string
	Pwd            string
	Hostname       string
	ShortHostname  string
	RunningOverSsh bool
	TmuxStatus     *TmuxStatus
	// Information about the workspace (hg, git, etc.).
	Workspace string
	// Exit code of the last process run in the shell.
	ExitCode int
	// Maximum number of characters which prompt may occupy horizontally.
	Width int
	// Environment variables which should be emitted to the shell which uses this
	// prompt.
	EnvironMod EnvironMod
}

func GetPwd() string {
	// If possible, get the pwd from $PWD, as this usually does the right thing
	// with symlinks (i.e. it shows the path you used to get here, not the
	// actual physical path). If $PWD fails, fall back on os.Getwd().
	pwd := os.Getenv("PWD")
	if len(pwd) == 0 {
		pwd, _ = os.Getwd()
	}
	return pwd
}

// Generates a PromptEnv based on current environment variables. The maximum
// number of characters which the prompt may occupy must be passed as 'width'.
// If 'now' is nil, the current date/time will be omitted from the prompt
// string.
func NewPromptEnv(
	pwd string,
	width int,
	exitCode int,
	now time.Time) *PromptEnv {

	var self = new(PromptEnv)
	self.Now = now

	user, err := user.Current()
	if err != nil {
		self.Home = ""
	} else {
		self.Home = user.HomeDir
	}

	self.Pwd = pwd
	self.Hostname, _ = os.Hostname()
	self.ShortHostname = strings.SplitN(self.Hostname, ".", 2)[0]
	self.RunningOverSsh = (os.Getenv("SSH_TTY") != "")
	self.TmuxStatus = GetTmuxStatus()

	self.Workspace = ""
	self.ExitCode = exitCode
	self.Width = width
	self.EnvironMod = *NewEnvironMod()

	return self
}

const leftArrow string = ""
const leftHollowArrow string = ""
const rightArrow string = ""
const rightHollowArrow string = ""

// TODO: clean up and nicely format all of this Go code

const (
	// Opens a section with a rightArrow.
	NormalSep = iota
	// Opens a section with a leftArrow.
	BackwardSep
	// Disables the opening separator.
	NoSep
)

type section struct {
	Sep  int
	Text string // May begin or end with a space for padding.
	Fg   Color
	Bg   Color
}

type Prompt struct {
	// Some sections may be nil.
	time      section
	hostname  *section
	tmux      *section
	workspace *section
	pwd       section
	status    *section

	// For PWD truncation.
	width int

	// Color to put right before the cursor at the end of the prompt.
	endBg Color
}

// TODO: more test coverage

// TODO: Dim slashes and ... in the PWD by darkening the FG color.

// Renders the terminal prompt to use.
func (self *Prompt) Prompt() StyledString {
	var buf StyledString
	var lastBg *Color = nil

	var addSection = func(s *section) {
		if s == nil {
			return
		}
		switch s.Sep {
		case NormalSep:
			buf = append(buf, Stylize(rightArrow, lastBg, &s.Bg)...)
		case BackwardSep:
			buf = append(buf, Stylize(leftArrow, &s.Bg, lastBg)...)
		}
		buf = append(buf, Stylize(s.Text, &s.Fg, &s.Bg)...)
		lastBg = &s.Bg
	}

	var endLine = func() {
		// Terminate the line.
		buf = append(buf, Stylize(rightArrow, lastBg, nil)...)
		buf = append(buf, Stylize("\n", &White, nil)...)
		lastBg = nil
	}

	addSection(&self.time)
	addSection(self.hostname)
	addSection(self.tmux)
	addSection(self.workspace)

	// Reserve some space before deciding how to truncate the PWD. Here are the
	// things we reserve for:
	//   * sep introducing the PWD
	//   * space before the PWD
	//   * space after the PWD
	//   * sep after the PWD
	//   * newline (just to make sure we don't get too close to the edge)
	//   * (potentially) the size of the status section and its sep
	var reserved = 5
	if self.status != nil {
		if self.status.Sep != NoSep {
			reserved += 1
		}
		reserved += utf8.RuneCountInString(self.status.Text)
	}

	// Make a copy so we can apply truncation and padding.
	var pwd section = self.pwd

	var availablePwdWidth = self.width - len(buf) - reserved
	var pwdOnNewLine bool = availablePwdWidth < 20 &&
		utf8.RuneCountInString(self.pwd.Text) > availablePwdWidth
	if pwdOnNewLine {
		// We still have to reserve a bit of space:
		//   * space before the PWD
		//   * space after the PWD
		//   * sep after the PWD
		//   * newline (just to make sure we don't get too close to the edge)
		availablePwdWidth = self.width - 4
		pwd.Sep = NoSep
	}

	// Truncate and pad the PWD.
	pwd.Text = fmt.Sprintf(" %s ", truncate(pwd.Text, availablePwdWidth))

	if !pwdOnNewLine {
		addSection(&pwd)
	}

	addSection(self.status)
	endLine()

	if pwdOnNewLine {
		addSection(&pwd)
		endLine()
	}

	// Add the actual prompt character on a new line.
	buf = append(buf, Stylize(" $", &White, &self.endBg)...)
	buf = append(buf, Stylize(" ", &White, nil)...)

	return buf
}

// Renders the terminal title to use.
func (self *Prompt) Title() string {
	var buf bytes.Buffer

	// Don't show time.

	if self.hostname != nil {
		fmt.Fprint(&buf, strings.TrimSpace(self.hostname.Text))
	}

	if self.tmux != nil {
    // TODO: this puts a weird unprintable in my terminal title :(
		fmt.Fprintf(&buf, " %s", strings.TrimSpace(self.tmux.Text))
	}

	if self.workspace != nil {
		fmt.Fprintf(&buf, " [%s]", strings.TrimSpace(self.workspace.Text))
	}

	// Pad before PWD.
	fmt.Fprint(&buf, " ")

	// Truncate PWD, if necessary.
	fmt.Fprint(&buf, truncate(self.pwd.Text, self.width-buf.Len()))

	// Don't show status.

	// Trim any excess padding.
	return strings.TrimSpace(buf.String())
}

// TODO: check all of this stuff visually
// TODO: bring back some foreground colors and maybe boldness

// Generates a shell prompt string.
func (self *PromptEnv) makePrompt() Prompt {
	var p Prompt
	p.width = self.Width
	p.endBg = Rgb(32, 80, 160)

	// Date and time, always.
	p.time = section{
		NoSep,
		self.Now.Format(" 1/2 15:04 "),
		White,
		Rgb(32, 80, 160),
	}

	// Hostname, only if it isn't the local host.
	if self.RunningOverSsh {
		p.hostname = &section{
			NormalSep,
			fmt.Sprintf(" %s ", self.ShortHostname),
			White,
			Rgb(24, 60, 120),
		}
	}

	// Tmux, if we have any active sessions.
	if self.TmuxStatus != nil && len(self.TmuxStatus.Sessions()) > 0 {
		// This will be the empty string if we have no attached session.
		var text = self.TmuxStatus.AttachedSession()
		for _, v := range self.TmuxStatus.Sessions() {
			if v {
				text += "!"
				break
			}
		}

		p.tmux = &section{
			BackwardSep,
			text,
			Black,
			Yellow,
		}
	}

	// Workspace, if there is one.
	if len(self.Workspace) > 0 {
		p.workspace = &section{
			NormalSep,
			fmt.Sprintf(" %s ", self.Workspace),
			White,
			Rgb(120, 24, 60),
		}
	}

	// Pwd, always.
	p.pwd = section{
		NormalSep,
		self.shortPwd(),
		White,
		Rgb(16, 40, 80),
	}

	// Status, if the last command failed.
	if self.ExitCode != 0 {
		p.status = &section{
			BackwardSep,
			fmt.Sprintf("%d", self.ExitCode),
			White,
			Red,
		}
	}

	return p
}

func (self *PromptEnv) shortPwd() string {
	var home = strings.TrimSuffix(self.Home, "/")
	var pwd = self.Pwd
	if strings.HasPrefix(pwd, home) {
		pwd = "~" + strings.TrimPrefix(pwd, home)
	}
	if pwd == "" {
		pwd = "/"
	}
	return pwd
}

func truncate(s string, width int) string {
	if width <= 0 {
		return "…"
	}

	var runes int = utf8.RuneCountInString(s)
	if runes <= width {
		return s
	}

	// Add 1 so we have space for the ellipsis.
	var toTrim int = runes - width + 1
	return "…" + s[toTrim:]
}

// Renders all the information from this PromptEnv into a shell script which
// may be sourced. The following variables will be set:
//   PROMPT
//   TERM_TITLE
//   ... plus any other variables set in self.EnvironMod.
func (self *PromptEnv) ToScript() string {
	// Start by making a copy of the custom EnvironMod.
	var mod = self.EnvironMod

	// Now add our variables to it.
	var prompt = self.makePrompt()
	mod.SetVar("PROMPT", prompt.Prompt().AnsiString())
	mod.SetVar("TERM_TITLE", prompt.Title())

	// Include the Info string separately, since it is sometimes useful
	// on its own (i.e. as the name of the current repo).
	mod.SetVar("WS", self.Workspace)
	return mod.ToScript()
}
