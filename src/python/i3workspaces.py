# -*- coding: utf-8 -*-
# Library of routines for manipulating i3 workspaces.

import string
import subprocess
import json


def parse(workspace):
  """ Tries to parse the workspace number out of a full workspace name. Returns
  the tuple (number, rest-of-name). 'number' is -1 if no number could be
  parsed.
  """
  split = string.split(workspace, ':', 1)
  number = -1
  try:
    # Use split[0] regardless of whether there is a split[1].
    number = int(split[0])
  except ValueError:
    pass
  if number < 0:
    return (-1, workspace)
  elif len(split) == 1:
    return (number, '')
  else:
    return (number, split[1])
    
    
def load():
  """ Grabs the workspaces JSON tree from i3. """
  return json.loads(subprocess.check_output(['i3-msg', '-t', 'get_workspaces']))
  
  
def rename(old, new):
  """ Issues the i3 command to rename workspace 'old' to 'new'. """
  command = 'rename workspace "%s" to "%s"' % (old, new)
  if subprocess.call(['i3-msg', command], stdout=subprocess.PIPE) != 0:
    raise Error('i3-msg failed')
  
  
def makeName(number, name):
  """ Builds a complete workspace name from a number and a string. """
  if len(name) == 0:
    # Don't insert colons needlessly.
    return str(number)
  else:
    return "%d:%s" % (number, name)