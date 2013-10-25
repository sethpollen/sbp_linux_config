# -*- coding: utf-8 -*-
# Library of routines for invoking dmenu.

import subprocess


def dmenu(prompt=None, options=[]):
  """ Invokes dmenu with the specified list of menu 'options'. Returns the
  user's selection as a string.
  """
  command = ['dmenu']
  if prompt:
    command += ['-p', prompt]
  selection, _ = (subprocess.Popen(command,
                                   stdin=subprocess.PIPE,
                                   stdout=subprocess.PIPE)
                  .communicate('\n'.join(options)))
  return selection.strip()

