#!/bin/sh
# A quick script for checking whether this repo is in sync with my
# actual homedir.
#
# wren gayle romano <wren@cpan.org>                 ~ 2016.09.06
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# (I don't use the git repo directly on my main machine, to avoid
# issues about things like irssi's cleartext passwords ending up
# in the repo. Ideally, I'd have an "install" script to manage this
# pattern everywhere. Perhaps we could use something like this to
# help: <https://github.com/oohlaf/dotsecrets>)


# N.B., must run from the git root directory!
# TODO: fix that.
# TODO: at the very least, warn if run from ~ and ~/.git doesn't exist
# BUG: still follows links and stuff, giving "Common subdirectories" outputs
find . ! -path './.git*' ! -type d \
    | while read line ; do diff -q {.,~}/"$line" ; done \
    | hilight differ

exit 0
