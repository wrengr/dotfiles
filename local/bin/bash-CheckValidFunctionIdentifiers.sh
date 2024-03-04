#!/bin/bash
# Test every ASCII byte to see if it's allowed in function identifiers.
# Modified from: <https://stackoverflow.com/a/44041384>
#
# For POSIX-ly correct things, you need to limit yourself to alphanumeric
# and underscore, but various versions of Bash allow other things as well
# (provided you use the `function` keyword).
# This script checks everything to see which ones your current version of
# /bin/bash supports.  (To check versions installed at other paths, either
# change the shebang line or source this file instead of executing it.)

# ~~~~~ First, define the ${ASCII[@]} table.
ASCII=( nul soh stx etx eot enq ack bel bs tab nl vt np cr so si dle \
            dc1 dc2 dc3 dc4 nak syn etb can em sub esc fs gs rs us sp )

for((i=33; i < 127; ++i)); do
    printf -v Hex "%x" $i
    printf -v Chr "\x$Hex"
    ASCII[$i]="$Chr"
done
ASCII[127]=del
for((i=128; i < 256; ++i)); do
    ASCII[$i]=$(printf "0X%x" $i)
done

# ~~~~~ Now define the test function.
function RunTest() {
    local MsgPrefix="$1"
    local NamePrefix="$2"
    local Illegal=""
    for((i=1; i <= 255; ++i)); do
        local Name="${NamePrefix}$(printf \\$(printf '%03o' $i))"
        # N.B., technically we can use a few other names (like *), but
        # they have to be properly quoted and may need a space between
        # the $Name and the ().  Still, if quoting is required, then we
        # might as well say they're no good, imo.
        #
        # Warning: when this exec runs for Name='*', if we are in
        # a directory with any executable scripts, the first one will
        # be run! (since the * will expand to all files in the current
        # directory.)  We can avoid extraneous output by also redirecting
        # stdout to /dev/null, but we should make sure to run this from
        # an empty directory in order to ensure that we don't accidentally
        # run anything with side effects.
        eval "function $Name(){ return 0; }; $Name ;" 2>/dev/null 1>&2
        if [[ $? -ne 0 ]]; then
            Illegal+=" ${ASCII[$i]}"
        fi
    done
    printf "%s%s\n" "$MsgPrefix" "$Illegal"
}

# ~~~~~ Set up temp dir, to avoid the bug mentioned above.
# N.B., the default template for mktemp doesn't need any quoting/escaping.
#   Though we still quote it for hygiene's sake.
# N.B., on OSX we must explicitly pass an argument to mktemp:
#   <https://unix.stackexchange.com/a/352108>
#   <https://unix.stackexchange.com/q/555058>
# TODO: we should check that /tmp exists and is writeable; or just make
#   the tdir in the pwd (assuming it's writable).
# BUG: apparently Cygwin is also borked and doesn't use $TMPDIR (they
#   use $TMP and $TEMP instead).
# TODO: maybe try using `mkstemp` to set the template variable to use.
TDIR="$(mktemp -d "${TMPDIR:-/tmp}/tmp.XXXXXXXX")"
pushd "$TDIR" >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
    errno=$?
    1>&2 echo "${0##*/}: cannot create/move-to tempdir"
    exit $errno
fi
function Finally() { popd >/dev/null; rm -rf "$TDIR"; }
# SIGINT=<C-c> SIGTERM=<C-z>
trap 'Finally' SIGINT SIGQUIT SIGTERM EXIT

# ~~~~~ Now call the test function.
echo "Bash version: $BASH_VERSION"
RunTest 'Illegal for first character:     '
RunTest 'Illegal for non-first character: ' 'x'
