#!/bin/sh
# A quick script for checking whether this repo is in sync with my
# actual homedir.
#
# wren gayle romano <wren@cpan.org>                 ~ 2021.10.09
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# (I don't use the git repo directly on my main machine, to avoid
# issues about things like irssi's cleartext passwords ending up
# in the repo. Ideally, I'd have an "install" script to manage this
# pattern everywhere. Perhaps we could use something like this to
# help: <https://github.com/oohlaf/dotsecrets>)

# HACK: since we must run this from the git rootdir, and since I
# only ever run this on mayari, we'll just hard-code switching to
# the known git-rootdir there.
gitdir="$HOME/code/dotfiles"
cd $gitdir

# BUG: still follows links and stuff, giving "Common subdirectories" outputs
# HACK: we just explicitly filter those out for now.
find . ! -path './.git/*' ! -type d \
	| sed 's@^\./@@' \
	| while read line ; do \
		if [ -e ~/"$line" ]; then \
			diff -q {.,~}/"$line" \
			| grep -v '^Common subdirectories:' \
	        | perl -ple 's@^Files ./(.*) and '"$HOME"'/\1 differ$@Differ    $1@' ; \
		else \
			echo "Unknown ~/$line" ; \
		fi ; \
	done

echo
cd ~
find .vim ! -path '.vim/bundle/*' ! -type d \
	| while read line ; do \
		if [ -e "$gitdir/$line" ]; then : ; else \
			echo "Missing ~/$line" ; \
		fi ; \
	done

exit 0
