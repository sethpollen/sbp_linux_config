# -*- coding: utf-8 -*-
# Library of routines for manipulating the i3 window manager (http://i3wm.org).

import subprocess
import json
import dmenu


class Util:
  """ Utilities for this flie. """

  # Will store JSON workspace tree.
  workspaces = None


  def i3msg(commands):
    """ Calls i3-msg with the given i3 commands. 'commands' may be a string or
    list of strings. Throws an exception if i3-msg exits with a non-zero status.
    """
    if type(commands) is list:
      commands = ' ; '.join(commands)
    return subprocess.check_call(['i3-msg', '-q', commands])


  def getWorkspaces():
    """ Grabs the workspaces JSON tree from i3. """
    if not workspaces:
      workspaces = json.loads(
          subprocess.check_output(['i3-msg', '-t', 'get_workspaces']))
    return workspaces


  def getFreeWorkspaceNumber():
    """ Gets the smallest free workspace number. """
    usedNumbers = set(w['num'] for w in getWorkspaces())
    free = 1
    while free in usedNumbers:
      free += 1
    return free
  
  
  def makeWorkspaceName(number, name):
    """ Builds a complete workspace name from a number and a string. """
    if len(name) == 0:
      # Don't insert colons needlessly.
      return str(number)
    else:
      return "%d:%s" % (number, name)


class User:
  """ Operations for interacting with the user. """

  def enterWorkspace(prompt=None, populateMenu=False):
    """ Prompts the user to enter a workspace name using dmenu. If
    'populateMenu' is True, the dmenu is populated with existing workspaces.
    If the user cancels, returns the empty string.
    """
    options = []
    # TODO: Preserve numbering.
    if populateMenu:
      options = [w['name'] for w in getWorkspaces()]
    return dmenu.dmenu(prompt, options)


class Command:
  """ Commands that modify the i3 state. """

  def focusWorkspace(name):
    """ Focuses workspace with 'name'. """
    Util.i3msg('workspace %s' % name)
