#!/usr/bin/env python
# Wrapper for install.py which provides kolvillag-specific configurations.

import subprocess
import os.path as p
import imp

HOME = p.expanduser("~")
SBP_LINUX_CONFIG = p.join(HOME, 'sbp-linux-config')
LOCAL_SRC = p.join(SBP_LINUX_CONFIG, 'hosts/kolvillag/src')

install = imp.load_source('install', p.join(SBP_LINUX_CONFIG, 'install.py'))
install.standard([LOCAL_SRC])
install.standardLaptop()
