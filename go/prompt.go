package prompt

import (
	"bytes"
	"flag"
	"fmt"
	"github.com/sethpollen/sbp_linux_config/fs"
	"github.com/sethpollen/sbp_linux_config/futures"
	"github.com/sethpollen/sbp_linux_config/git"
	"github.com/sethpollen/sbp_linux_config/hg"
	"github.com/sethpollen/sbp_linux_config/p4"
	"github.com/sethpollen/sbp_linux_config/style"
	"github.com/sethpollen/sbp_linux_config/workspace"
	"log"
	"os"
	"os/user"
	"path"
	"strings"
	"time"
	"unicode/utf8"
)

var mode = flag.String("mode", "",
	"There are 3 modes:\n"+
		"  fast: For standard interactive prompts; renders the prompt\n"+
		"    incrementally, signalling fish to redraw it every time new\n"+
		"    information becomes available.\n"+
		"  slow: For use by 'back'. Blocks until the prompt can be rendered\n"+
		"    completely.\n"+
		"  purge: Doesn't ouptut anything; just purges the cache of information\n"+
		"    used in 'fast' mode.")

var output = flag.String("output", "",
	"What to print. Legal values are {'fish_prompt', 'terminal_title'}.")

var fishPid = flag.Int("fish_pid", 0,
	"PID of the fish shell which spawned this process. Required when \n"+
		"--mode=fast or --mode=purge.")

var exitCode = flag.Int("exit_code", 0,
	"Exit code of previous command. If absent, 0 is assumed.")

var width = flag.Int("width", 100,
	"Maximum number of characters which the output may occupy.")

var dollar = flag.Bool("dollar", true,
	"Whether to print the $ line when --output=fish_prompt.")

var showBack = flag.Bool("show_back", true,
	"Whether to display the status of pending 'back' jobs.")

// Body of main() for the binary which generates my fish shell prompt.
func Main() {
	flag.Parse()

	if *mode != "slow" && *fishPid == 0 {
		log.Fatalln("--fish_pid is required when --mode is not 'slow'")
	}

	futureHome := fmt.Sprintf("/dev/shm/sbp-fish-%d", *fishPid)
	var futz futures.Futurizer

	switch *mode {
	case "fast":
		// Use real asynchrony.
		futz = func(cmds map[string]string) (map[string][]byte, error) {
			return futures.Futurize(futureHome, cmds, fishPid)
		}

	case "slow":
		// Use a fake Futurizer which actually does everything synchronously.
		futz = func(cmds map[string]string) (map[string][]byte, error) {
			var env map[string]string
			return futures.FuturizeSync(cmds, env)
		}

	case "purge":
		err := futures.Clear(futureHome)
		if err != nil {
			log.Fatalln(err)
		}
		// Don't print any output.
		return

	default:
		log.Fatalln("Invalid --mode setting: " + *mode)
	}

	// If possible, get the pwd from $PWD, as this usually does the right thing
	// with symlinks (i.e. it shows the path you used to get here, not the
	// actual physical path). If $PWD fails, fall back on os.Getwd().
	pwd := os.Getenv("PWD")
	if len(pwd) == 0 {
		pwd, _ = os.Getwd()
	}

	// Write the PWD to a file in /dev/shm. This allows other shells to jump
	// to the directory in use by the most recent shell.
	os.WriteFile("/dev/shm/sbp-last-pwd", []byte(pwd), 0660)

	env, err := buildPromptEnv(pwd, futz)
	if err != nil {
		log.Fatalln(err)
	}

	switch *output {
	case "fish_prompt":
		fmt.Print(env.FishPrompt().AnsiString())
	case "terminal_title":
		fmt.Print(env.TerminalTitle())
	default:
		log.Fatalln("Invalid --output setting: " + *output)
	}
}

// Construct a PromptEnv based on information from the local filesystem.
func buildPromptEnv(
	pwd string, futz futures.Futurizer) (*PromptEnv, error) {
	var err error
	e := newPromptEnv(pwd, *width, *exitCode, *dollar, time.Now())

	if *showBack {
		e.BackJobs, err = futures.List(path.Join(e.Home, ".back"))
		if err != nil {
			return nil, err
		}
	}

	pwdExists, err := fs.DirExists(pwd)
	if err != nil {
		return nil, err
	}
	if !pwdExists {
		// The PWD doesn't even exist, so don't try to query workspace info.
		e.PwdError = true
		return e, nil
	}

	ws, err := workspace.Find(pwd)
	if err != nil {
		return nil, err
	}
	if ws == nil {
		// There is no workspace.
		return e, nil
	}

	e.Pwd = ws.Path
	e.Workspace = path.Base(ws.Root)
	e.WorkspaceType = workspace.Indicator(ws.Type)

	var status *workspace.Status
	switch ws.Type {
	case workspace.Git:
		status, err = git.Status(futz)

	case workspace.Hg:
		status, err = hg.Status(futz)

	case workspace.P4:
		status, err = p4.Status(futz)
	}

	if err != nil {
		return nil, err
	}

	if status != nil {
		e.WorkspaceStatus = status.String()
	}

	return e, nil
}

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
	BackJobs []futures.Stat

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
func newPromptEnv(
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
	Fg   style.Color
	Bg   style.Color
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
	endBg style.Color

	// See PromptEnv.Dollar
	dollar bool
}

type promptStyler struct {
	styled style.StyledString
	lastBg *style.Color

	// Length of the last line of 'Styled'.
	lastLineLength int
}

func (self *promptStyler) Styled() style.StyledString {
	return self.styled
}

func (self *promptStyler) Append(s style.StyledString) {
	self.styled = append(self.styled, s...)
	self.lastLineLength += len(s)
}

func (self *promptStyler) EndLine(newline bool, maxColumns int) {
	// Terminate the line.
	self.Append(style.Stylize(rightArrow, self.lastBg, nil))

	// Pad lines with spaces in case we are redrawing the prompt after a
	// previous, longer prompt.
	var padding int = maxColumns - self.lastLineLength
	for i := 0; i < padding; i++ {
		self.Append(style.Stylize(" ", &style.White, nil))
	}

	if newline {
		self.Append(style.Stylize("\n", &style.White, nil))
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
		self.Append(style.Stylize(rightArrow, self.lastBg, &s.Bg))
	case BackwardSep:
		self.Append(style.Stylize(leftArrow, &s.Bg, self.lastBg))
	}

	self.Append(style.Stylize(s.Text, &s.Fg, &s.Bg))
	self.lastBg = &s.Bg
}

// Renders the terminal prompt to use.
func (self *Prompt) prompt() style.StyledString {
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
		styler.Append(style.Stylize(" $", &style.White, &self.endBg))
		styler.Append(style.Stylize(" ", &style.White, nil))
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

var baseBg = style.Rgb(32, 80, 160)

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
		style.White,
		baseBg,
	}

	// Hostname, only if it isn't the local host.
	if self.RunningOverSsh {
		p.hostname = &section{
			NormalSep,
			fmt.Sprintf(" %s ", self.ShortHostname),
			style.Yellow,
			style.Rgb(0, 70, 0),
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
			style.Black,
			style.Yellow,
		}
	}

	// A red wine color for the workspace background.
	var wine = style.Rgb(120, 24, 60)

	// Workspace, if there is one.
	if len(self.WorkspaceType) > 0 {
		p.workspaceType = &section{
			NormalSep,
			fmt.Sprintf(" %s", self.WorkspaceType),
			style.Yellow,
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
			style.White,
			wine,
		}
	}

	if len(self.WorkspaceStatus) > 0 {
		p.workspaceStatus = &section{
			NoSep,
			fmt.Sprintf("%s ", self.WorkspaceStatus),
			style.Yellow,
			wine,
		}
	}

	// Pwd, always.
	var pwdFg = style.White
	if self.PwdError {
		pwdFg = style.Red
	}
	p.pwd = section{
		NormalSep,
		self.shortPwd(),
		pwdFg,
		style.Rgb(16, 40, 80),
	}

	// Status, if the last command failed.
	if self.ExitCode != 0 {
		p.status = &section{
			BackwardSep,
			fmt.Sprintf("%d", self.ExitCode),
			style.White,
			style.Red,
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

func (self *PromptEnv) FishPrompt() style.StyledString {
	var prompt = self.makePrompt()
	return prompt.prompt()
}

func (self *PromptEnv) TerminalTitle() string {
	var prompt = self.makePrompt()
	return prompt.title()
}
