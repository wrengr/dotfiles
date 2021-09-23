#!/bin/bash
# A quick script for merging my actual homedir file into the repo.
#
# wren gayle romano <wren@cpan.org>                 ~ 2021.09.22
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# (I don't use the git repo directly on my main machine, to avoid
# issues about things like irssi's cleartext passwords ending up
# in the repo. Ideally, I'd have an "install" script to manage this
# pattern everywhere. Perhaps we could use something like this to
# help: <https://github.com/oohlaf/dotsecrets>)

# BUG: must run from the git root directory!
# TODO: fix that.
# TODO: at the very least, warn if run from ~ and ~/.git doesn't exist
if [ "$#" -ne 1 ]; then
    echo "Usage: ${0::*/} <relative-path>"
    exit 1
fi
relfile="$1"

## BUG: this git-cat-file stuff isn't giving us the right diffs.
## Maybe try to fix this approach later; for now, disabled.
#while [ -z "$gitsha" ]; do
#    git lola -- "$relfile"
#    read -p "Pick the best diffbase: " gitsha
#    # TODO: also allow chosing /dev/null, for when there's no
#    # obvious/decent diffbase.
#    if git rev-parse --quiet --verify "$gitsha" ; then
#        echo "Got $gitsha"
#        break
#    else
#        echo "Invalid SHA"
#        # TODO: should prolly abort rather than looping
#    fi
#done
#
## Since I don't think we can pass "$branchpoint:./$relfile" directly
## as the second argument to git-merge-file
#tmp_file="./$relfile.tmp.$gitsha"
#echo "Recovering $gitsha into $tmp_file"
#git cat-file -p "$gitsha:./$relfile" > "$tmp_file"
#
#echo "Merging files"

# WARNING: (by default) this will save the output into the first
# argument!  To print to stdout instead, pass the -p flag.
git merge-file \
    -L master -L null -L mayari \
    ./"$relfile" /dev/null ~/"$relfile"
