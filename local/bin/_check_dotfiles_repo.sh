#!/bin/sh
# A quick script for checking whether this repo is in sync with my
# actual homedir.
#
# wren gayle romano <wren@cpan.org>                 ~ 2022.09.11
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
# TODO: If we wanted to do the right thing, we could use either
# `git rev-parse --show-toplevel` to get the absolute path to the
# root dir, or `git rev-parse --show-cdup` for the relative path
# up to the root dir.  However, both of those will error if we're
# not already in a git repo.
cd $gitdir

# BUG: still follows links and stuff, giving "Common subdirectories" outputs
# HACK: we just explicitly filter those out for now.
find . ! -path './.git/*' ! -type d \
    | sed 's@^\./@@' \
    | while read line ; do \
        if [ -e ~/"$line" ]; then \
            diff -q {.,~}/"$line" \
            | grep -v '^Common subdirectories:' \
            | perl -ple 's@^Files ./(.*) and '"$HOME"'/\1 differ$@Differ     $1@' ; \
        else \
            echo "Homeless ./$line" ; \
        fi ; \
    done

echo
cd ~
find local/bin \
    ! -path 'local/bin/cat/*' \
    ! -path 'local/bin/gale/*' \
    ! -type d \
    ! -type l \
    | while read line ; do \
        if [ -e "$gitdir/$line" ]; then : ; else \
            echo "Gitless  ~/$line" ; \
        fi ; \
    done
find .vim \
    ! -path '.vim/bundle/*' \
    ! -type d \
    | while read line ; do \
        if [ -e "$gitdir/$line" ]; then : ; else \
            echo "Gitless  ~/$line" ; \
        fi ; \
    done

exit 0
