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

# Will store set of currently used workspace numbers.
usedWorkspaceNumbers = None


def i3msg(commands):
  """ Calls i3-msg with the given i3 commands. 'commands' may be a string or
  list of strings. Throws an exception if i3-msg exits with a non-zero status.
  """
  if type(commands) is list:
    commands = ' ; '.join(commands)
  return subprocess.check_call(['i3-msg', '-q', commands])


def getWorkspaces():
  """ Grabs the workspaces JSON tree from i3. """
  global workspaces
  if not workspaces:
    workspaces = json.loads(
        subprocess.check_output(['i3-msg', '-t', 'get_workspaces']))
  return workspaces
  
  
def getUsedWorkspaceNumbers():
  global usedWorkspaceNumbers
  if not usedWorkspaceNumbers:
    usedWorkspaceNumbers = set(w['num'] for w in getWorkspaces())
  return usedWorkspaceNumbers
  
  
def getCurrentWorkspace():
  global currentWorkspace
  if not currentWorkspace:
    for w in getWorkspaces():
      if w['focused']:
        currentWorkspace = w
        break
  return currentWorkspace
  

def getFreeWorkspaceNumber():
  """ Gets the smallest free workspace number. """
  free = 1
  while free in getUsedWorkspaceNumbers():
    free += 1
  return free


def makeWorkspaceName(number, name):
  """ Builds a complete workspace name from a number and a string. """
  if len(name) == 0:
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


def chooseWorkspace(prompt):
  """ Prompts the user to choose a workspace from a dmenu of existing
  workspaces. If the user cancels, returns None. If the user's choice doesn't
  match any existing workspaces and doesn't begin with a number,
  the next free number is prepended to their selection.
  """
  selection = dmenu.dmenu(prompt, [w['name'] for w in getWorkspaces()])
  if not selection:
    return None
  number = parseWorkspaceNumber(selection)
  if number < 0:
    # User didn't specify a number at all.
    return makeWorkspaceName(getFreeWorkspaceNumber(), selection)
  if number in getUsedWorkspaceNumbers():
    # The user specified a number which is already in use. Even if they
    # specified a different name, clamp them to the workspace with that
    # number.
    for w in getWorkspaces():
      if number == w['num']:
        return w['name']
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
  if number in getUsedWorkspaceNumbers() and number is not currentNumber:
    # This number is already in use elsewhere, so we can't use it here.
    return None
  return selection
    

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
          (getCurrentWorkspace()['name'], newName))
    

## ENTRY POINTS ##

def grave():
  focusWorkspace(chooseWorkspace('Switch to workspace:'))
  
def tilde():
  moveToWorkspace(chooseWorkspace('Move to workspace:'))
  
def escape():
  focusWorkspace(getFreeWorkspaceNumber())

def shiftEscape():
  number = getFreeWorkspaceNumber()
  moveToWorkspace(number)
  focusWorkspace(number)
  
def rename():
  renameCurrentWorkspace(enterNewWorkspaceName('New workspace name:',
                                               getCurrentWorkspace()['num']))
  