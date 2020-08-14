// Library for manipulating a running i3 desktop via i3-msg.

package sbpgo

import (
  "encoding/json"
  "fmt"
  "os/exec"
  "strings"
)

type Workspace struct {
  Num int
  Name string
  Focused bool
}

// Gets the current list of workspaces.
func GetI3Workspaces() ([]Workspace, error) {
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
  for _, w := range jsonList {
    jsonMap, ok := w.(map[string]interface{})
    if !ok {
      return nil, fmt.Errorf("get_workspaces result is not a list of maps")
    }

    rawNum, ok := jsonMap["num"]
    if !ok {
      return nil, fmt.Errorf("get_workspaces did not return num")
    }
    num, ok := rawNum.(float64)
    if !ok {
      return nil, fmt.Errorf("get_workspaces num is not a number")
    }

    rawName, ok := jsonMap["name"]
    if !ok {
      return nil, fmt.Errorf("get_workspaces did not return name")
    }
    name, ok := rawName.(string)
    if !ok {
      return nil, fmt.Errorf("get_workspaces name is not a string")
    }

    rawFocused, ok := jsonMap["focused"]
    if !ok {
      return nil, fmt.Errorf("get_workspace did not return focused")
    }
    focused, ok := rawFocused.(bool)
    if !ok {
      return nil, fmt.Errorf("get_workspace focused is not a bool")
    }

    workspaces = append(workspaces, Workspace{int(num), name, focused})
  }

  return workspaces, nil
}

// Issues a command via i3-msg.
func IssueI3Commands(cmds ...string) error {
  return exec.Command("i3-msg", "--quiet", strings.Join(cmds, " ; ")).Run()
}

