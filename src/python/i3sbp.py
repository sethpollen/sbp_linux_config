# -*- coding: utf-8 -*-
# Library of routines for manipulating the i3 window manager (http://i3wm.org).

import subprocess
import json
import dmenu
import sys


# Will store JSON workspace tree.
workspaces = None

# Will store currently focused workspace's JSON tree.
currentWorkspace = None

# Will map workspace numbers to workspace JSON tree.
workspacesByNumber = None


def getWorkspaces():
  """ Grabs the workspaces JSON tree from i3. """
  global workspaces
  if not workspaces:
    workspaces = json.loads(
        subprocess.check_output(['i3-msg', '-t', 'get_workspaces']))
  return workspaces
  
  
def getWorkspacesByNumber():
  global workspacesByNumber
  if not workspacesByNumber:
    workspacesByNumber = {}
    for w in getWorkspaces():
      workspacesByNumber[w['num']] = w
  return workspacesByNumber
  
  
def getCurrentWorkspace():
  global currentWorkspace
  if not currentWorkspace:
    for w in getWorkspaces():
      if w['focused']:
        currentWorkspace = w
        break
  return currentWorkspace
  
  
def name(w):
  """ Gets the name from a workspace JSON tree. """
  return w['name'] if w else None
  
  
def num(w):
  """ Gets the number from a workspace JSON tree. """
  return w['num'] if w else None
  
  
def output(w):
  """ Gets the output (screen) from a workspace JSON tree. """
  return w['output'] if w else None


def i3msg(commands):
  """ Calls i3-msg with the given i3 commands. 'commands' may be a string or
  list of strings. Throws an exception if i3-msg exits with a non-zero status.
  """
  if type(commands) is list:
    commands = ' ; '.join(commands)
  return subprocess.check_call(['i3-msg', '-q', commands])
  

def getFreeWorkspaceNumber():
  """ Gets the smallest free workspace number. """
  free = 1
  while free in getWorkspacesByNumber():
    free += 1
  return free


def makeWorkspaceName(number, name):
  """ Builds a complete workspace name from a number and a string. """
  if not name:
    # Don't insert colons needlessly.
    return str(number)
  else:
    return "%d:%s" % (number, name)
    
    
def makeWorkspaceSpecifier(nameOrNumber):
  """ Makes the i3 command text to specify a workspace, either using its
  full name or just its number.
  """
  if type(nameOrNumber) is int:
    return 'workspace number %d' % nameOrNumber
  else:
    return 'workspace "%s"' % nameOrNumber
    
    
def parseWorkspaceNumber(workspace):
  """ Parses and returns the numeric portion of a workspace name. If no
  number is found, returns -1.
  """
  parts = workspace.split(':', 1)
  try:
    return int(parts[0])
  except ValueError:
    return -1
    
    
def removeWorkspaceNumber(workspace):
  """ Removes the numeric portion of a workspace name. """
  parts = workspace.split(':', 1)
  if len(parts) == 1:
    try:
      dummy = int(parts[0])
      # It's just a number.
      return None
    except ValueError:
      return parts[0]
  else:
    return parts[1]

def chooseWorkspace(prompt):
  """ Prompts the user to choose a workspace from a dmenu of existing
  workspaces. If the user cancels, returns None. If the user's choice doesn't
  match any existing workspaces and doesn't begin with a number,
  the next free number is prepended to their selection.
  """
  selection = dmenu.dmenu(prompt, [name(w) for w in getWorkspaces()])
  if not selection:
    return None
  number = parseWorkspaceNumber(selection)
  if number < 0:
    # User didn't specify a number at all.
    return makeWorkspaceName(getFreeWorkspaceNumber(), selection)
  if number in getWorkspacesByNumber():
    # The user specified a number which is already in use. Even if they
    # specified a different name, clamp them to the workspace with that
    # number.
    for w in getWorkspaces():
      if number == num(w):
        return name(w)
  # If all else fails, just return the user's selection.
  return selection
    

def enterNewWorkspaceName(prompt, currentNumber):
  """ Prompts the user to enter a new name for workspace with number
  'currentNumber'. If the user choice doesn't begin with a number,
  'currentNumber' is prepended.
  """
  selection = dmenu.dmenu(prompt, [])
  if not selection:
    return None
  number = parseWorkspaceNumber(selection)
  if number < 0:
    # User didn't specify a number at all, so just keep the current one.
    return makeWorkspaceName(currentNumber, selection)
  if number in getWorkspacesByNumber() and number is not currentNumber:
    # This number is already in use elsewhere, so we can't use it here.
    return None
  return selection
  
  
def getAdjacentWorkspace(direction):
  """ Gets the JSON tree of the workspace adjacent to the current workspace.
  'direction' should be -1 (for left) or 1 (for right). Will only return a
  workspace on the same screen as the current workspace.
  """
  currentW = getCurrentWorkspace()
  i = num(currentW) + direction
  allW = getWorkspacesByNumber()
  maxNumber = max(allW.keys())
  minNumber = min(allW.keys())
  while i >= minNumber and i <= maxNumber:
    if i in allW:
      otherW = allW[i]
      if output(otherW) == output(currentW):
	return otherW
    i += direction
  # We ran out of workspaces.
  return None
    

def focusWorkspace(nameOrNumber):
  """ Focuses workspace with the given string name or integer number. """
  if nameOrNumber:
    i3msg(makeWorkspaceSpecifier(nameOrNumber))
    
    
def moveToWorkspace(nameOrNumber):
  """ Moves the current container to workspace with the given string name or
  integer number.
  """
  if nameOrNumber:
    i3msg('move container to ' + makeWorkspaceSpecifier(nameOrNumber))
    
    
def renameCurrentWorkspace(newName):
  """ Renames the current workspace to 'newName'. """
  if newName:
    i3msg('rename workspace "%s" to "%s"' %
          (name(getCurrentWorkspace()), newName))
          

def swapNumbers(workspace1, workspace2):
  """ Swaps the numbers of two workspaces, whose JSON trees must be given. """
  if workspace1 and workspace2:
    num1 = num(workspace1)
    name1 = removeWorkspaceNumber(name(workspace1))
    num2 = num(workspace2)
    name2 = removeWorkspaceNumber(name(workspace2))
    i3msg(('rename workspace "%s" to 999999; ' +
           'rename workspace "%s" to "%s"; ' +
           'rename workspace 999999 to "%s"') % (
             name(workspace1),
             name(workspace2),
             makeWorkspaceName(num1, name2),
             makeWorkspaceName(num2, name1)))
    

## ENTRY POINTS ##
# Intended to be bound to keys.

def switchChoose():
  focusWorkspace(chooseWorkspace('Switch to workspace:'))
  
def moveChoose():
  moveToWorkspace(chooseWorkspace('Move to workspace:'))
  
def switchNew():
  focusWorkspace(getFreeWorkspaceNumber())

def moveNew():
  number = getFreeWorkspaceNumber()
  moveToWorkspace(number)
  focusWorkspace(number)
  
def rename():
  renameCurrentWorkspace(enterNewWorkspaceName('New workspace name:',
                                               num(getCurrentWorkspace())))

def swapLeft():
  swapNumbers(getCurrentWorkspace(),
              getAdjacentWorkspace(-1))
              
def swapRight():
  swapNumbers(getCurrentWorkspace(),
              getAdjacentWorkspace(1))