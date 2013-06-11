#!/usr/bin/env python
# Wrapper for install.py which provides kolvillag-specific configurations.

import subprocess
import os.path as p
import imp

HOME = p.expanduser("~")
SBP_LINUX_CONFIG = p.join(HOME, 'sbp-linux-config')
LOCAL_SRC = p.join(SBP_LINUX_CONFIG, 'hosts/kolvillag/src')

install = imp.load_source('install', p.join(SBP_LINUX_CONFIG, 'install.py'))
install.standard(LOCAL_SRC)

# Read in the i3status.conf constructed so far.
I3STATUS_CONF = p.join(install.BIN, 'dotfiles/i3status.conf')
with open(I3STATUS_CONF) as f:
  conf = f.read()

print 'Inserting Battery entry into i3status.conf ...'
conf = install.insertBefore(conf,
    'order += "cpu_usage"', 'order += "battery 0"')

# Write out the new i3status.conf lines.
with open(I3STATUS_CONF, 'w') as f:
  f.write(conf)
