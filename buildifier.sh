#!/bin/sh

bazel run @com_github_bazelbuild_buildtools//buildifier -- \
    $(find $HOME/sbp/sbp_linux_config -iname BUILD -type f)
