# -*- coding: utf-8 -*-
# Library of routines for manipulating the i3 window manager (http://i3wm.org).

import subprocess
import json


def i3msg(commands):
  """ Calls i3-msg with the given i3 commands. 'commands' may be a string or
  list of strings. Throws an exception if i3-msg exits with a non-zero status.
  """
  if type(commands) is list:
    commands = ' ; '.join(commands)
  return subprocess.check_call(['i3-msg', '-q', commands])


def getWorkspaces():
  """ Grabs the workspaces JSON tree from i3. """
  return json.loads(subprocess.check_output(['i3-msg', '-t', 'get_workspaces']))
  
  
def makeWorkspaceName(number, name):
  """ Builds a complete workspace name from a number and a string. """
  if len(name) == 0:
    # Don't insert colons needlessly.
    return str(number)
  else:
    return "%d:%s" % (number, name)
