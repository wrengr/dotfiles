#!/bin/sh
# A quick script for checking whether this repo is in sync with my
# actual homedir.
#
# wren gayle romano <wren@cpan.org>                 ~ 2016.06.15
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
# HACK: we just explicitly filter those out for now.
find . ! -path './.git*' ! -type d \
	| sed 's@^\./@@' \
	| while read line ; do \
		if [ -e ~/"$line" ]; then \
			diff -q {.,~}/"$line" \
			| grep -v '^Common subdirectories:' ; \
		else \
			echo "# No such file: ~/$line" ; \
		fi ; \
	done \
	| hilight differ

exit 0
