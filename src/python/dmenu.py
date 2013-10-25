# -*- coding: utf-8 -*-
# Library of routines for invoking dmenu.

import subprocess


def dmenu(prompt, options):
  """ Invokes dmenu with the specified list of menu 'options'. Returns the
  user's selection as a string. If the user quits the dmenu, returns the
  empty string.
  """
  command = ['dmenu']
  if prompt:
    command += ['-p', prompt]
  selection, _ = (subprocess.Popen(command,
                                   stdin=subprocess.PIPE,
                                   stdout=subprocess.PIPE)
                  .communicate('\n'.join(options)))
  return selection.strip()

