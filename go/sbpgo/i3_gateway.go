// Library for manipulating a running i3 desktop via i3-msg.

package sbpgo

import (
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"sort"
	"strconv"
	"strings"
)

type Workspace struct {
	Num int

	// Will probably include "<Num>:" as a prefix.
	Name string

	Focused bool

	// Name of the video output to which this workspace is assigned.
	Output string

	// Coordinates of this workspace's top left corner.
	X int
	Y int
}

// Gets the current list of workspaces. The result will be sorted by Num.
func getWorkspaces() ([]Workspace, error) {
	cmd := exec.Command("i3-msg", "-t", "get_workspaces")
	result, err := cmd.Output()
	if err != nil {
		return nil, err
	}

	var rawJson interface{}
	err = json.Unmarshal(result, &rawJson)
	if err != nil {
		return nil, err
	}

	jsonList, ok := rawJson.([]interface{})
	if !ok {
		return nil, fmt.Errorf("get_workspaces result is not a list")
	}

	var workspaces []Workspace
	for _, rawW := range jsonList {
		w, ok := rawW.(map[string]interface{})
		if !ok {
			return nil, fmt.Errorf("get_workspaces result is not a list of maps")
		}

		rawNum, ok := w["num"]
		if !ok {
			return nil, fmt.Errorf("get_workspaces did not return num")
		}
		num, ok := rawNum.(float64)
		if !ok {
			return nil, fmt.Errorf("get_workspaces num is not a number")
		}

		rawName, ok := w["name"]
		if !ok {
			return nil, fmt.Errorf("get_workspaces did not return name")
		}
		name, ok := rawName.(string)
		if !ok {
			return nil, fmt.Errorf("get_workspaces name is not a string")
		}

		rawFocused, ok := w["focused"]
		if !ok {
			return nil, fmt.Errorf("get_workspace did not return focused")
		}
		focused, ok := rawFocused.(bool)
		if !ok {
			return nil, fmt.Errorf("get_workspace focused is not a bool")
		}

		rawOutput, ok := w["output"]
		if !ok {
			return nil, fmt.Errorf("get_workspace did not return output")
		}
		output, ok := rawOutput.(string)
		if !ok {
			return nil, fmt.Errorf("get_workspace output is not a string")
		}

		rawRect, ok := w["rect"]
		if !ok {
			return nil, fmt.Errorf("get_workspace did not return rect")
		}
		rect, ok := rawRect.(map[string]interface{})
		if !ok {
			return nil, fmt.Errorf("get_workspace rect is not a map")
		}

		rawX, ok := rect["x"]
		if !ok {
			return nil, fmt.Errorf("get_workspace did not return rect.x")
		}
		x, ok := rawX.(float64)
		if !ok {
			return nil, fmt.Errorf("get_workspace rect.x is not a number")
		}

		rawY, ok := rect["y"]
		if !ok {
			return nil, fmt.Errorf("get_workspace did not return rect.y")
		}
		y, ok := rawY.(float64)
		if !ok {
			return nil, fmt.Errorf("get_workspace rect.y is not a number")
		}

		workspaces = append(workspaces, Workspace{
			int(num),
			name,
			focused,
			output,
			int(x),
			int(y),
		})
	}

	// Sort by ascending workspace number.
	sort.Slice(workspaces, func(i, j int) bool {
		return workspaces[i].Num < workspaces[j].Num
	})

	return workspaces, nil
}

// Issues a command via i3-msg.
func issueI3Commands(cmds ...string) error {
	return exec.Command("i3-msg", "--quiet", strings.Join(cmds, "; ")).Run()
}

// Returns the index of the focused workspace.
func getCurrentWorkspace(ws []Workspace) (int, error) {
	for i, w := range ws {
		if w.Focused {
			return i, nil
		}
	}
	return -1, fmt.Errorf("No workspace currently focused")
}

// Gets the set of video outputs, sorted by X coordinate and then by Y
// coordinate.
func getOutputs(ws []Workspace) []string {
	// Condense the set of workspaces so that we have just one per output.
	outputMap := make(map[string]Workspace)
	for _, w := range ws {
		outputMap[w.Output] = w
	}

	// Flatten the map.
	var outputs []Workspace
	for _, w := range outputMap {
		outputs = append(outputs, w)
	}

	// Sort by (x,y) coordinates.
	sort.Slice(outputs, func(i, j int) bool {
		if outputs[i].X != outputs[j].X {
			return outputs[i].X < outputs[j].X
		}
		return outputs[i].Y < outputs[j].Y
	})

	// Return the output names.
	var names []string
	for _, w := range outputs {
		names = append(names, w.Output)
	}

	return names
}

// Gets the smallest unused workspace number.
func nextFreeWorkspaceNumber(ws []Workspace) int {
	// 'ws' will already be sorted by Num (ascending), though there may be
	// multiple entries with the same number. Find the first unused positive
	// number.
	maxSeen := 0
	for _, w := range ws {
		next := maxSeen + 1
		if w.Num > next {
			return next
		}
		maxSeen = w.Num
	}
	return maxSeen + 1
}

// Parses the workspace number out of 'name'. Returns -1 if there doesn't appear
// to be a workspace number present.
func parseWorkspaceNumber(name string) int {
	firstPart := strings.SplitN(name, ":", 2)[0]
	num, err := strconv.Atoi(firstPart)
	if err != nil {
		return -1
	}
	// Zero is not a valid workspace number.
	if num <= 0 {
		return -1
	}
	return num
}

// Removes the leading workspace number and colon. Returns an empty string if
// the name is just a number (no colon).
func removeWorkspaceNumber(name string) string {
	parts := strings.SplitN(name, ":", 2)

	_, err := strconv.Atoi(parts[0])
	if err != nil {
		// The first part isn't a number, so don't remove anything.
		return name
	}

	// Return the second part, or an empty string if there is no second part.
	if len(parts) == 1 {
		return ""
	}
	return parts[1]
}

func makeWorkspaceName(num int, rest string) string {
	if len(rest) == 0 {
		return fmt.Sprintf("%d", num)
	}
	return fmt.Sprintf("%d:%s", num, rest)
}

func RenameCurrentWorkspace() error {
	selection, err := Dmenu("New workspace name:", nil)
	if err != nil {
		return err
	}
	if len(selection) == 0 {
		// User aborted.
		return nil
	}

	ws, err := getWorkspaces()
	if err != nil {
		return err
	}

	i, err := getCurrentWorkspace(ws)
	if err != nil {
		return err
	}

	if parseWorkspaceNumber(selection) <= 0 {
		// The user didn't specify a number. Just keep the workspace's existing
		// number.
		num := parseWorkspaceNumber(ws[i].Name)
		if num <= 0 {
			// Something weird is happening. Just use a default.
			num = 1
		}
		selection = fmt.Sprintf("%d:%s", num, selection)
	}

	return issueI3Commands(fmt.Sprintf("rename workspace \"%s\" to \"%s\"",
		ws[i].Name, selection))
}

func SwitchToNewWorkspace() error {
	ws, err := getWorkspaces()
	if err != nil {
		return err
	}

	num := nextFreeWorkspaceNumber(ws)
	return issueI3Commands(fmt.Sprintf("workspace number %d", num))
}

func MoveToNewWorkspace() error {
	ws, err := getWorkspaces()
	if err != nil {
		return err
	}

	num := nextFreeWorkspaceNumber(ws)
	return issueI3Commands(
		fmt.Sprintf("move container to workspace number %d", num),
		fmt.Sprintf("workspace number %d", num))
}

// 'direction' should be 1 to swap right or -1 to swap left.
func SwapWorkspace(direction int) error {
	if direction != 1 && direction != -1 {
		return fmt.Errorf("Bad direction")
	}

	ws, err := getWorkspaces()
	if err != nil {
		return err
	}

	// Find the position of the current workspace in the list.
	i, err := getCurrentWorkspace(ws)
	if err != nil {
		return err
	}

	// Find the adjacent workspace on the same output.
	var j int = i
	for {
		j += direction
		if j < 0 || j >= len(ws) {
			// We didn't find any adjacent workspace on the same output. We must be at
			// the edge. Do nothing.
			return nil
		}
		if ws[j].Output == ws[i].Output {
			break
		}
	}

	// Swap the workspaces at positions i and j.
	oldI := ws[i].Name
	oldJ := ws[j].Name
	newI := makeWorkspaceName(ws[j].Num, removeWorkspaceNumber(oldI))
	newJ := makeWorkspaceName(ws[i].Num, removeWorkspaceNumber(oldJ))

	return issueI3Commands(
		fmt.Sprintf("rename workspace \"%s\" to 999999", oldI),
		fmt.Sprintf("rename workspace \"%s\" to \"%s\"", oldJ, newJ),
		fmt.Sprintf("rename workspace 999999 to \"%s\"", newI))
}

// 'direction' should be 1 to swap right or -1 to swap left.
func CycleWorkspaceOutput(direction int) error {
	if direction != 1 && direction != -1 {
		return fmt.Errorf("Bad direction")
	}

	ws, err := getWorkspaces()
	if err != nil {
		return err
	}

	w, err := getCurrentWorkspace(ws)
	if err != nil {
		return err
	}

	// Find the position of the currently focused output in the list of all
	// outputs.
	outputs := getOutputs(ws)
	var i = 0
	for ; i < len(outputs); i++ {
		if ws[w].Output == outputs[i] {
			break
		}
	}

	// Calculate the neighboring output in the given direction.
	var j = (i + direction + len(outputs)) % len(outputs)

	return issueI3Commands(fmt.Sprintf("move workspace to output %s", outputs[j]))
}

// Entry point.
func I3GatewayMain() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "No subcommand")
		os.Exit(1)
	}
	var subcommand = os.Args[1]

	var err error
	switch subcommand {

	case "rename":
		err = RenameCurrentWorkspace()

	case "switch_new":
		err = SwitchToNewWorkspace()

	case "move_new":
		err = MoveToNewWorkspace()

	case "swap_left":
		err = SwapWorkspace(-1)

	case "swap_right":
		err = SwapWorkspace(1)

	case "output_left":
		err = CycleWorkspaceOutput(-1)

	case "output_right":
		err = CycleWorkspaceOutput(1)

	default:
		fmt.Fprintln(os.Stderr, "Unrecognized subcommand:", subcommand)
		os.Exit(1)
	}

	if err != nil {
		fmt.Println(err)
		os.Exit(2)
	}
}
