#!/bin/bash
# A quick script for merging my actual homedir file into the repo.
# wren gayle romano <wren@cpan.org>                 ~ 2024-04-14
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# (I don't use the git repo directly on my main machine, to avoid
# issues about things like irssi's cleartext passwords ending up
# in the repo. Ideally, I'd have an "install" script to manage this
# pattern everywhere. Perhaps we could use something like this to
# help: <https://github.com/oohlaf/dotsecrets>)

_error() { >&2 printf "\e[1;31m${0##*/}:\e[0m \e[1m$*\e[0m\n"; }

if [[ "$#" -ne 1 ]]; then
    echo "Usage: ${0##*/} <relative-path-from-root>"
    exit 1
fi
readonly relfile="$1"

# This script must be run from the git root directory; so we try
# to ensure that here.  First we check that we're in a repo, and
# then we `cd` to the root of that repo.
readonly gitroot="$(git-root)"
if [[ "$?" -ne 0 ]]; then
  _error 'Must run from within a git repo'
  exit 1
fi
# <https://bosker.wordpress.com/2012/02/12/bash-scripters-beware-of-the-cdpath/>
unset CDPATH; export CDPATH
cd -- "$gitroot" &>/dev/null
if [[ "$?" -ne 0 ]]; then
  _error "Could not \`cd $gitroot\`"
  exit 1
fi

# Some basic error checking beforehand.
if [[ ! -f ./"$relfile" ]]; then
  _error "File doesn't exist in repo: ./$relfile"
  exit 1
fi
if [[ ! -f ~/"$relfile" ]]; then
  _error "File doesn't exist in homedir: ~/$relfile"
  exit 1
fi

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
#
# NOTE: we must *not* use --diff3 here because that causes the
# merge/diff algorithm to avoid any attempt s to refine the conflicts,
# thus making this script useless!  The --diff3 option is only for
# the case where we have a non-trivial base file (and ideally one
# that is as close as possible to the two variants).
# <https://github.com/git/git/blob/1a4874565fa3b6668042216189551b98b4dc0b1b/xdiff/xmerge.c#L520-L524>
#
# TODO: is there any way to specify the algorithm?  Cuz this generates
# different output than `git diff --no-index` does.  (The main
# `git merge` can take the strategy flag `-s diff-algorithm=patience`,
# but `git merge-file` doesn't have that flag; so it seems like
# there's no way to specify the algorithm here.  Though maybe see
# <https://stackoverflow.com/a/12977444>)
git merge-file \
    --no-diff3 \
    -L master -L null -L mayari \
    ./"$relfile" /dev/null ~/"$relfile"

# TODO: dig into these sources to see if they can't help us figure
# out how to better do what it is we really want:
# <https://github.com/git/git/blob/master/diff-no-index.c>      `git diff --no-index`
# <https://github.com/git/git/blob/master/builtin/merge-file.c> `git merge-file`
# <https://github.com/git/git/blob/master/merge-blobs.c>
# <https://github.com/git/git/blob/master/git-sh-setup.sh>      See `create_virtual_base`
# <https://github.com/git/git/blob/master/git-merge-one-file.sh>

