// Library for constructing prompt strings of the specific form that I like.
package sbpgo

// TODO: tmux does not pass through my terminal title

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
	now time.Time,
	callTmux bool) *PromptEnv {

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
	if callTmux {
		self.TmuxStatus = GetTmuxStatus()
	}

	self.Workspace = ""
	self.ExitCode = exitCode
	self.Width = width

	return self
}

const leftArrow string = ""
const leftHollowArrow string = ""
const rightArrow string = ""
const rightHollowArrow string = ""

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

type promptStyler struct {
	Styled StyledString
	LastBg *Color
}

func (self *promptStyler) AddSection(s *section) {
	if s == nil {
		return
	}

	switch s.Sep {
	case NormalSep:
		self.Styled =
			append(self.Styled, Stylize(rightArrow, self.LastBg, &s.Bg)...)
	case BackwardSep:
		self.Styled =
			append(self.Styled, Stylize(leftArrow, &s.Bg, self.LastBg)...)
	}

	self.Styled = append(self.Styled, Stylize(s.Text, &s.Fg, &s.Bg)...)
	self.LastBg = &s.Bg
}

func (self *promptStyler) EndLine() {
	// Terminate the line.
	self.Styled = append(self.Styled, Stylize(rightArrow, self.LastBg, nil)...)
	self.Styled = append(self.Styled, Stylize("\n", &White, nil)...)
	self.LastBg = nil
}

// Renders the terminal prompt to use.
func (self *Prompt) prompt() StyledString {
	var styler promptStyler

	styler.AddSection(&self.time)
	styler.AddSection(self.hostname)
	styler.AddSection(self.tmux)
	styler.AddSection(self.workspace)

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

	var availablePwdWidth = self.width - len(styler.Styled) - reserved
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
	styler.EndLine()

	if pwdOnNewLine {
		styler.AddSection(&pwd)
		styler.EndLine()
	}

	// Add the actual prompt character on a new line.
	styler.Styled = append(styler.Styled, Stylize(" $", &White, &self.endBg)...)
	styler.Styled = append(styler.Styled, Stylize(" ", &White, nil)...)

	return styler.Styled
}

func (self *Prompt) tmuxStatusLine() StyledString {
	var styler promptStyler

	styler.AddSection(&section{
		NoSep,
		" tmux ",
		White,
		baseBg,
	})
	styler.AddSection(self.hostname)
	styler.AddSection(&section{
		BackwardSep,
		"#S", // Tmux will replace this with the session name.
		Black,
		Yellow,
	})
	styler.EndLine()

	return styler.Styled
}

// Renders the terminal title to use.
func (self *Prompt) title() string {
	var buf bytes.Buffer

	// For some reason, terminator gets into some Unicode confusion with the
	// angle bracket characters below. It tries to interpret a normal space after
	// an angle bracket as a "00E0" special sequence. This doesn't happen if we
	// use underscores instead of spaces, and terminator displays underscores
	// the same as spaces in the title bar anyway (go figure).
	var needUnderscore = false
	var pad = func() {
		if buf.Len() == 0 {
			return
		}
		if needUnderscore {
			fmt.Fprint(&buf, "_")
			needUnderscore = false
		} else {
			fmt.Fprint(&buf, " ")
		}
	}

	// Don't show time.

	if self.hostname != nil {
		fmt.Fprint(&buf, strings.TrimSpace(self.hostname.Text))
	}

	if self.tmux != nil {
		pad()
		fmt.Fprintf(&buf, "%s", strings.TrimSpace(self.tmux.Text))
		needUnderscore = true
	}

	if self.workspace != nil {
		pad()
		fmt.Fprintf(&buf, "[%s]", strings.TrimSpace(self.workspace.Text))
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

	// Tmux, if we have any active sessions.
	if self.TmuxStatus != nil && len(self.TmuxStatus.Sessions()) > 0 {
		p.tmux = &section{
			BackwardSep,
			// If we aren't attached to any of the sessions, we'll just show an
			// empty yellow diamond.
			self.TmuxStatus.AttachedSession(),
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

// TODO: remove every reference to tmux
func (self *PromptEnv) TmuxStatusLine() StyledString {
	var prompt = self.makePrompt()
	return prompt.tmuxStatusLine()
}

func (self *PromptEnv) FishPrompt() StyledString {
	var prompt = self.makePrompt()
	return prompt.prompt()
}

func (self *PromptEnv) TerminalTitle() string {
	var prompt = self.makePrompt()
	return prompt.title()
}
