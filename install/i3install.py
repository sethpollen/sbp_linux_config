#!/usr/bin/env python
# Utilities for installing an i3 config.

import StringIO

# Use Alt key as primary i3 modifier.
MOD = 'Mod1'


def emit(out, text):
  """ Emits 'text' to 'out', stripping leading whitespace from lines. """
  lines = text.splitlines()
  # TODO:


def standard(i3barTrayOutput):
  """ Returns a string containing the standard i3 config for all my machines.
    i3barTrayOutput - Xrandr name of the output where i3bar should put its
      systray.
  """
  buf = StringIO.StringIO()

  ##############################################################################
  # i3 config file (v4)
  # Please see http://i3wm.org/docs/userguide.html for a complete reference!
  
  ##############################################################################
  # NOTES
  # The following keystrokes are bound in tmux and should not be used here:
  #  Alt+,
  #  Alt+.
  #  Alt+/
  #  Alt+<
  #  Alt+>
  #  Alt+?
  #  Alt+T
  #  Alt+\
  #  Alt+|
  
  ##############################################################################
  # GLOBAL SETTINGS
  buf.write('set $mod ' + MOD + '\n')

  # Font for window titles. ISO 10646 = Unicode
  buf.write('font -misc-fixed-medium-r-normal--13-120-75-75-C-70-iso10646-1\n')

  # Use Alt+Left-Drag to move floating windows.
  # Use Alt+Right-Drag to resize floating windows.
  buf.write('floating_modifier $mod\n')
  
  buf.write('bar {\n')
  # TODO:
bar {
  status_command i3status | i3status-wrapper
  position bottom

  # Put the system tray on the laptop flat-panel.
  # TODO: This isn't working right on my laptop. It may be that the primary
  # Xrandr display changes after the i3 config runs. In any case, reloading
  # i3 fixes the problem.
  tray_output primary

  workspace_buttons yes
  binding_mode_indicator yes

  colors {
    background #000000
    statusline #ffffff
    separator  #666666

    # class            border  backgr. text
    focused_workspace  #4c78FF #2855CC #ffffff
    active_workspace   #BBBBBB #5f676a #ffffff
    inactive_workspace #333333 #222222 #888888
    urgent_workspace   #2f343a #900000 #ffffff
  }
}

  return buf.getvalue()
