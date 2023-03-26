// Library for constructing prompt strings of the specific form that I like.
package sbpgo

import (
	"bytes"
	"fmt"
	"log"
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
	PwdError       bool
	Hostname       string
	ShortHostname  string
	RunningOverSsh bool

	// Summary of extant 'back' jobs.
	BackJobs []FutureStat

	// Information about the workspace (hg, git, etc.).
	WorkspaceType   string
	Workspace       string
	WorkspaceStatus string

	// Exit code of the last process run in the shell.
	ExitCode int
	// Maximum number of characters which prompt may occupy horizontally.
	Width int

	// Whether to show the final line of the prompt, which just has a dollar sign.
	Dollar bool
}

// Generates a PromptEnv based on current environment variables. The maximum
// number of characters which the prompt may occupy must be passed as 'width'.
// If 'now' is nil, the current date/time will be omitted from the prompt
// string.
func NewPromptEnv(
	pwd string,
	width int,
	exitCode int,
	dollar bool,
	now time.Time) *PromptEnv {

	timezone, err := time.LoadLocation("America/Los_Angeles")
	if err != nil {
		log.Fatalln(err)
	}

	var self = new(PromptEnv)
	self.Now = now.In(timezone)

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

	self.ExitCode = exitCode
	self.Width = width
	self.Dollar = dollar

	// These fields may be filled in later.
	self.BackJobs = nil
	self.WorkspaceType = ""
	self.Workspace = ""
	self.WorkspaceStatus = ""
	self.PwdError = false

	return self
}

const leftArrow string = ""
const rightArrow string = ""

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
	time            section
	hostname        *section
	back            *section
	workspaceType   *section
	workspace       *section
	workspaceStatus *section
	pwd             section
	status          *section

	// For PWD truncation.
	width int

	// Color to put right before the cursor at the end of the prompt.
	endBg Color

	// See PromptEnv.Dollar
	dollar bool
}

type promptStyler struct {
	styled StyledString
	lastBg *Color

	// Length of the last line of 'Styled'.
	lastLineLength int
}

func (self *promptStyler) Styled() StyledString {
	return self.styled
}

func (self *promptStyler) Append(s StyledString) {
	self.styled = append(self.styled, s...)
	self.lastLineLength += len(s)
}

func (self *promptStyler) EndLine(newline bool, maxColumns int) {
	// Terminate the line.
	self.Append(Stylize(rightArrow, self.lastBg, nil))

	// Pad lines with spaces in case we are redrawing the prompt after a
	// previous, longer prompt.
	var padding int = maxColumns - self.lastLineLength
	for i := 0; i < padding; i++ {
		self.Append(Stylize(" ", &White, nil))
	}

	if newline {
		self.Append(Stylize("\n", &White, nil))
	}

	self.lastBg = nil
	self.lastLineLength = 0
}

func (self *promptStyler) AddSection(s *section) {
	if s == nil {
		return
	}

	switch s.Sep {
	case NormalSep:
		self.Append(Stylize(rightArrow, self.lastBg, &s.Bg))
	case BackwardSep:
		self.Append(Stylize(leftArrow, &s.Bg, self.lastBg))
	}

	self.Append(Stylize(s.Text, &s.Fg, &s.Bg))
	self.lastBg = &s.Bg
}

// Renders the terminal prompt to use.
func (self *Prompt) prompt() StyledString {
	var styler promptStyler

	styler.AddSection(&self.time)
	styler.AddSection(self.hostname)
	styler.AddSection(self.back)
	styler.AddSection(self.workspaceType)
	styler.AddSection(self.workspace)
	styler.AddSection(self.workspaceStatus)

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

	var availablePwdWidth = self.width - len(styler.Styled()) - reserved
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
		styler.AddSection(&pwd)
	}

	styler.AddSection(self.status)

	if pwdOnNewLine {
		styler.EndLine(true, self.width)
		styler.AddSection(&pwd)
	}

	if self.dollar {
		// Add the actual prompt character on a new line.
		styler.EndLine(true, self.width)
		styler.Append(Stylize(" $", &White, &self.endBg))
		styler.Append(Stylize(" ", &White, nil))
	} else {
		// Close out the line, but don't start a new line.
		styler.EndLine(false, self.width)
	}

	return styler.Styled()
}

// Renders the terminal title to use.
func (self *Prompt) title() string {
	var buf bytes.Buffer
	var pad = func() {
		if buf.Len() > 0 {
			fmt.Fprint(&buf, " ")
		}
	}

	// Don't show time.

	if self.hostname != nil {
		pad()
		fmt.Fprint(&buf, strings.TrimSpace(self.hostname.Text))
	}

	if self.workspaceType != nil || self.workspace != nil {
		pad()
		fmt.Fprint(&buf, "[")

		if self.workspaceType != nil {
			fmt.Fprint(&buf, strings.TrimSpace(self.workspaceType.Text))
		}

		if self.workspace != nil {
			if self.workspaceType != nil {
				fmt.Fprint(&buf, " ")
			}
			fmt.Fprint(&buf, strings.TrimSpace(self.workspace.Text))
		}

		if self.workspaceStatus != nil {
			if self.workspace != nil {
				fmt.Fprint(&buf, " ")
			}
			fmt.Fprint(&buf, strings.TrimSpace(self.workspaceStatus.Text))
		}

		fmt.Fprint(&buf, "]")
	}

	// Pad before PWD.
	pad()

	// Truncate PWD, if necessary.
	fmt.Fprint(&buf, truncate(self.pwd.Text, self.width-buf.Len()))

	// Don't show status.

	// Trim any excess padding.
	return strings.Trim(buf.String(), " ")
}

var baseBg = Rgb(32, 80, 160)

// Generates a shell prompt string.
func (self *PromptEnv) makePrompt() Prompt {
	var p Prompt
	p.width = self.Width
	p.dollar = self.Dollar
	p.endBg = baseBg

	// Date and time, always.
	p.time = section{
		NoSep,
		self.Now.Format(" 1/2 15:04 "),
		White,
		baseBg,
	}

	// Hostname, only if it isn't the local host.
	if self.RunningOverSsh {
		p.hostname = &section{
			NormalSep,
			fmt.Sprintf(" %s ", self.ShortHostname),
			Yellow,
			Rgb(0, 70, 0),
		}
	}

	if len(self.BackJobs) > 0 {
		var text string
		for _, j := range self.BackJobs {
			if j.Complete {
				// At least one `back` job is ready to be joined. Show its name.
				text = j.Name
				break
			}
		}

		// If no jobs are joinable, just show an empty yellow diamond to indicate
		// that some jobs are running.
		p.back = &section{
			BackwardSep,
			text,
			Black,
			Yellow,
		}
	}

	// A red wine color for the workspace background.
	var wine = Rgb(120, 24, 60)

	// Workspace, if there is one.
	if len(self.WorkspaceType) > 0 {
		p.workspaceType = &section{
			NormalSep,
			fmt.Sprintf(" %s", self.WorkspaceType),
			Yellow,
			wine,
		}
	}

	if len(self.Workspace) > 0 {
		var sep = NormalSep
		if len(self.WorkspaceType) > 0 {
			sep = NoSep
		}

		p.workspace = &section{
			sep,
			fmt.Sprintf(" %s ", self.Workspace),
			White,
			wine,
		}
	}

	if len(self.WorkspaceStatus) > 0 {
		p.workspaceStatus = &section{
			NoSep,
			fmt.Sprintf("%s ", self.WorkspaceStatus),
			Yellow,
			wine,
		}
	}

	// Pwd, always.
	var pwdFg = White
	if self.PwdError {
		pwdFg = Red
	}
	p.pwd = section{
		NormalSep,
		self.shortPwd(),
		pwdFg,
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

func (self *PromptEnv) FishPrompt() StyledString {
	var prompt = self.makePrompt()
	return prompt.prompt()
}

func (self *PromptEnv) TerminalTitle() string {
	var prompt = self.makePrompt()
	return prompt.title()
}
