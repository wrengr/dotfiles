# wren gayle romano's bash login script             ~ 2021.09.01
#
# It's fairly generic (with weirder things at the bottom),
# but it's designed to be usable for all my accounts with no(!)
# modifications.
#
# It may also help to have a .bashrc file that sources this one.
# Remember .bash_profile == login shells, .bashrc == non-login.
# But bear in mind, you don't want a bunch of this crap when you
# login via, say, `scp`.


# == Style and Portability Notes ==
# * OSX 10.14.4 (Mojave, 2019) uses Bash-3.2 (>2005, <2009); however,
#   they have been patched to address the Shellshock vulnerability
#   (for more standard GNU/BSD *nices, these are fixed in version
#   Bash-4.2/4.3 (2014)):  <https://mywiki.wooledge.org/BashFAQ/111>
# * Always prefer $() over ``; it's not just nicer, it's also POSIX:
#   <https://mywiki.wooledge.org/BashFAQ/082>
# * All three of [ ! -z ] and [ ! -z "" ] and [ -s "" ] return
#   false; and [ -s ] returns true!
# * Using the -a and -o flags with [ has been deprecated since POSIX-2008:
#   <https://mywiki.wooledge.org/BashPitfalls#pf6>
# * Using == with [ is a Bashism. Either use = with [ or == with [[
#   <https://mywiki.wooledge.org/BashPitfalls#pf20>
# * Using both the function keyword and () is a Bashism:
#   <https://mywiki.wooledge.org/BashPitfalls#pf25>
# * It's buggy/nonportable to use echo to print variables, should
#   use printf instead: <http://www.etalabs.net/sh_tricks.html>
# * The ${var//pattern/replacement} construct (yes, with double-slash
#   for the leading separator!) was added back in Bash-2.0 (1996),
#   so it should be pretty portable these days.
#   <https://wiki.bash-hackers.org/scripting/bashchanges>
#   N.B., the behavior of the # and % characters inside that double-slash
#   construct changed in Bash-3.1 (2005):
#   <http://tiswww.case.edu/php/chet/bash/COMPAT> item #29
#   (Whereas # and % do still have their special meaning for the
#   single-slash search and replace.)


# == TODOs ==
# * Check that all the places we switched `` to $() are still working
#   correctly re escapes.
# * Do a full audit/overhaul of this file, since most of these hosts
#   no longer exist anymore...


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ BEGIN                                        BEGIN ~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# ~~~~~ Personalized MOTD so I stop forgetting shit
#       (Unless the shell is non-interactive)
if [ ! -z "${PS1}" ] && [ -r '.motd' ]; then
    echo
    cat '.motd'
    echo
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ By default let new files be readable by everyone.
umask 0022


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Try to guess who/where we are
# TODO: have separate variables for the general "domain" vs the specific
# host in that domain. Also, remove all the old now-unused hosts.

# We cache the results of various calls to `uname` so we don't keep
# spawning off processes.
_uname="$(uname)"

# Get rid of that obnoxious message from Apple telling us to switch to zsh
if [ "${_uname}" = 'Darwin' ]; then
    export BASH_SILENCE_DEPRECATION_WARNING=1
fi


# On some systems (e.g., *.haskell.org, and very new versions of
# OSX) we can use `hostname -f` to get the FQDN; but older OSX, and
# most other *NIXes don't have the `-f` flag. The `uname` utility
# is defined by POSIX/SUSv4; whereas the `hostname` has no spec,
# and so is different everywhere. (On GNU/Linux, `hostname` happens
# to coincide with `uname -n`, but that's just a coincidence, not
# guaranteed.) Notably, `uname -n` is just a very thin wrapper that
# just calls gethostname(2), which is why it doesn't resolve FQDNs.
_hostname="$(uname -n)"

case "${_hostname}" in
    # Assume mayari if we've been renamed by dhcp (Foo on dhcp!)
    # TheWitchsBroom == Hopscotch, when it's broken
    mayari* | ereshkigal* | semiramis* | xenobia* | *.pubnet.pdx.edu | *.dhcp.pdx.edu | remote*.cecs.pdx.edu | *.comcast.net | TheWitchsBroom.att.net )
                                          _hostname='mayari'    ;;
    elsamelys*)                           _hostname='elsamelys' ;;
    galena*)                              _hostname='dreamhost' ;;
    cl.indiana.edu)                       _hostname='banks'     ;;
    nlp.indiana.edu)                      _hostname='miller'    ;;
    # TODO: *.karst.uits.iu.edu x86_64 GNU/Linux
    *.haskell.org | lun)                  _hostname='haskell'   ;;
    *.corp.google.com | *.c.googlers.com)
        # BUG: doesn't distinguish between maracuya & ciruela
        # (both Goobuntu), vs my laptop (OSX).
        _hostname='google'
    ;;

    # If all else fails...
    *)
        if [ "${_uname}" = 'Darwin' ]; then
            # Guess that any other OSX is also Mayari, or else
            # supports the same sorts of things in general.
            _hostname='mayari'
            # Debugging. Should usually be left on
            [ -z "${PS1}" ] || echo "I resorted to guessing I'm on ${_hostname}!"
        elif [ "$(uname -m)" = 'armv5tel' ]; then
            _hostname='elsamelys'
        else
            # Debugging. Should usually be left on
            [ -z "${PS1}" ] || echo "I couldn't figure out where I am!"
            _hostname='UNKNOWN'
        fi
    ;;
esac

# Debugging. Should usually be turned off
#[ -z "${PS1}" ] && echo "I'm on ${_hostname}"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Configure TERM to be (more) correct

# N.B., using 'xterm-color' results in vim setting t_Co=8. Thus,
# to get termcap to say the right thing so that vim does the right
# thing, we need to use 'xterm-256color' instead. (Where "right thing"
# is assuming the terminal emulator actually supports 256 colors. Try
# running `256colors.pl` to make sure.) Some common cases are handled
# below, but we don't address everything.

# TODO: other than Goobuntu/GoogleOSX (and the old JHU machines),
# does anyone else's screen suck and set TERM='screen*' when it really
# supports 256-color?

# TODO: have some (host-specific) helper file which stores the true
# number of colors the given terminal supports, and set a variable by
# reading from that file. This way we don't have to mess around with
# TERM quite so much. Of course, we'd need to make sure our ~/.vimrc
# also reads that file in order to set &t_Co appropriately.

# TODO: When run inside of screen, irssi complains about using
# xterm-256color and suggests using screen-256color instead.  I'm not
# sure what glitches they're referring to re using the former...

# Google's `screen` is annoying.
if [ "${_hostname}" = 'google' ]; then
    # N.B., Goobuntu's `screen` sets TERM='screen-bce' rather than TERM='screen'.
    # BUG: apparently this no longer catches things on gLinux...
    if [ "${TERM}" = 'screen-bce' ]; then
        # TODO: it used to be the version of `screen` on Goobuntu
        # only supported 8-colors, but that seems to have been
        # miraculously fixed somehow.
        export TERM='screen-256color'
    else
        # When using the local terminal on Goobuntu, we have
        # TERM='xterm' by default. (Whereas, when sshing in we
        # already have TERM='xterm-256color'.)
        export TERM='xterm-256color'
    fi
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Fancy Prompt

# N.B. some `su`s don't reset $USER properly without `-` or `-l`,
# and `who` vs `whoami` vs `id` can return different things in the
# same way. Using `su -` *should* rectify this, but some places
# (e.g., drkatz, sting,...) *unset* $USER when using `su -` ::sigh::
if [ "X${USER}" = 'X' ]; then
    # Even if I'm not root, I should still be alarmed
    export USER='UNKNOWN'
fi

# TODO: set our own _usecolor variable, rather than relying on TERM itself.

# To compare bold vs highlight, use:
# printf '\e[0;31mplain\n\e[1;31mbold\n\e[0;91mhighlight\n\e[1;91mbold+highlight\n\e[0m'

if [ ! -z "${PS1}" ]; then
    # TODO: we should probably use `tput` to get the escape codes for
    # the desired colors, rather than hard-coding them directly.
    #
    # N.B., `tput` returns answers based on the value of TERM,
    # not based on what the terminal actually supports!!
    if [ "$(tput colors)" -gt 2 ]; then
        # A better way to check for root is to use [ "$(id -u)" -eq 0 ]
        # ...however, alas, that doesn't find non-root users
        case "${USER}" in
            motoko | ass | root | UNKNOWN )
                _color1='\[\e[01;31m\]' ;; # bold red
            *)  _color1='\[\e[01;34m\]' ;; # bold blue
        esac

        _color2='\[\e[01;36m\]' # bold teal
    fi

    _bold='\[\e[01;00m\]'
    _off='\[\e[00m\]'

    # If we ever find non-color terminals may want to adjust this
    _j="${_color1}\j${_off}"  # \j was added in Bash version 2+
    _u="${_color1}\u${_off}"
    _h="${_color2}\h${_off}" # consider \H
    _w="${_color2}\${_PWD}${_off}" # \w is nice (but see below), \W is evil
    # TODO: use _getrepo_icon to know if the current directory
    # is under version control. However, see the bug notes in
    # that file... Maybe what I should do is use *both* the
    # _getrepo_icon icon and "\\\$"? Or maybe some magic
    # postprocessing a la the _pwd_shorten function?
    #_s="${_color1}\$(_getrepo_icon)${_off}"
    _s="${_color1}\\\$${_off}"

    # Get the exit code of last program, iff it failed
    # BUG: doesn't account for non-color terminals.
    # BUG: should use printf instead
    _exit="\$(x=\$?; [ \$x -ne 0 ] && echo -n \"\[\e[01;31m\]\$x${_off} \")"

    # Empty if we're not on a google machine.  Maybe in the future we'll
    # extend this to handle other version control systems (like we used
    # to have way back in the day).
    _figprompt=""
    if [ "${_hostname}" = 'google' ] && [ "${_uname}" = 'Linux' ]; then
        figprompt_file="${HOME}/local/lib/prompts/fig_status/bash/fig_prompt.sh"
        # While the _uname guard will keep this from running on my mac
        # laptop, we still want to check that the file exists before doing
        # stuff with it.
        if [ -r "$figprompt_file" ]; then
            # BUG: see the warning note in ~/.hgrc
            source "$figprompt_file"
            # BUG: I want to add extra space (to separate get_fig_prompt from the preceding $_w and the following $_s below), but iff get_fig_prompt actually returns something (so that we don't get double spaces when in homedir etc)
            _figprompt="\[\033[1;35m\]\$(get_fig_prompt)\[\033[00m\]"
        fi
    fi

    # The actual prompt itself
    # TODO: factor out the [ ] @ :
    PS1="${_bold}[${_off}${_j}${_bold}]${_off} ${_u}${_bold}@${_off}${_h}${_bold}:${_off}${_w}${_figprompt} ${_s} ${_exit}"

    # Short prompt for elys, but only when logged in directly
    if [ "${_hostname}" = 'elsamelys' ]; then
        if tty | grep ttya >/dev/null ; then
            PS1="[${_j}] ${_w} ${_s} ${_exit}"
        fi
    fi

    export PS1
    unset  _color1 _color2 _bold _off _j _u _h _w _s _exit _figprompt
fi


# Funky trick to limit $PWD to a given length
# N.B. complicates the helpful window titles funky trick at the
# bottom. Some older systems may not like this (Balthazar didn't);
# if we find more of those, then we should re-introduce the guard.
#
# N.B. we're setting and using $_PWD now, because changing $PWD
# breaks `cd -`. It doesn't break pushd/popd because those use `pwd`
# instead of $PWD, as they should.
#
# BUG: this spins forever churning cpu if there's unicode in the path!!!
# TODO: maybe use `tput cols` or Bash's $COLUMNS to choose the
# length limit more dynamically? Cf., <https://mywiki.wooledge.org/BashFAQ/091>
_pwd_shorten() {
    local _length=30
    [ "$1" != '' ] && _length="$1"

    # This is to fix munging on marquise since it doesn't auto $HOME -> "~"
    # Only performs the substitution when there's a following slash,
    #     in case your username is a prefix of someone else's. Could be fixed with better regex
    # BUG: should use printf instead
    # BUG: should use ${///} instead of echo/printf + sed
    local _home="$(echo "${HOME}" | sed 's/\\/\\\\/g; s/\//\\\//g')"
    _PWD="$(pwd | sed "s/^${_home}\//~\//; s/^${_home}$/~/")"

    # ${#_PWD} == $(echo -n "${_PWD}" | wc -c | tr -d ' ')
    if [ ${#_PWD} -gt ${_length} ]; then
        # BUG: should use printf instead of echo
        # BUG: should use ${///} instead of echo/printf + sed
        # BUG: should use $() instead of ``
        # BUG: should avoid using expr if we can.
        echo "${_PWD}" | sed "s/.*\(.\{`expr ${_length} - 3`\}\)$/...\1/"
    else
        # BUG: should use printf instead
        echo "${_PWD}"
    fi
}
# Using the `declare` to check for existence, preventing
# issues about `su` not inheriting functions.
export PROMPT_COMMAND='declare -F _pwd_shorten >/dev/null && _PWD="`_pwd_shorten`"'

# N.B., if you're using <https://github.com/rcaloras/bash-preexec> then
# that will steal the PROMPT_COMMAND.  While google has this installed
# automatically, but it doesn't seem to be enabled by default so we're safe.


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set up GPG
# From `man 1 gpg-agent`, and <https://github.com/jamessan/vim-gnupg>
export GPG_TTY=`tty`


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Smarter ssh-agent
alias legate='eval $(command legate)'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Add a new colon-delimited value to the front of a variable
#       Usage: `_push varname value`
_push() {
    # Get the old value by double evaluation.
    # BUG: should use printf instead
    local var="$(eval echo $(echo "\$$1"))"

    # BUG: the eval is necessary for the $1= to be interpreted
    #      but it means the rhs will be evaluated too. The
    #      single ticks will work to escape this so long as
    #      there're no single ticks in the expansions.
    if [ "X$var" = 'X' ]; then
        eval $1=\'"$2"\'
    else
        eval $1=\'"$2:$var"\'
    fi
}

# ~~~~~ Add a new colon-delimited value to the back of a variable
#       Usage: `_copush varname value`
_copush() {
    # Get the old value by double evaluation.
    # BUG: should use printf instead
    local var="$(eval echo $(echo "\$$1"))"

    # BUG: the eval is necessary for the $1= to be interpreted
    #      but it means the rhs will be evaluated too. The
    #      single ticks will work to escape this so long as
    #      there're no single ticks in the expansions.
    if [ "X$var" = 'X' ]; then
        eval $1=\'"$2"\'
    else
        eval $1=\'"$var:$2"\'
    fi
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set up Fink

# We do this before setting up our carefully designed paths
#    since it munges them and we want the final dictate on prefixing
if [ "${_hostname}" = 'mayari' ]; then
    # New Fink has pivoted to basically require /opt/sw, in lieu
    # of the old /sw
    finkpath='/opt/sw'

    # Let Fink munge our paths etc.
    [ -r "$finkpath/bin/init.sh" ] && source "$finkpath/bin/init.sh"

    # This is needed for some linkers, like Cabal which can't
    # correctly pass -optl-L* to GHC (which would pass -L* to ld)
    _push  LD_LIBRARY_PATH "$finkpath/lib"
    export LD_LIBRARY_PATH

    unset finkpath
fi

# N.B., Fink has GNU tar, which doesn't play nicely with the BSD
# tar that ships with OSX. As written /opt/sw/bin trumps /usr/bin.
# If we actually care about having access to both of them, we should
# do some sort of symlink or alias thing to select the one we mean/want.


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set up paths

# Debugging, should usually be turned off
#echo "Beginning path: $PATH"
#echo "Beginning manpath: $MANPATH"


case "${_hostname}" in
    mayari)
        # Technically we should no longer need to add this to PATH,
        # since we've added it to /etc/paths.d . However, it looks
        # like there's no analogue for MANPATH
        MAPLE_HOME='/Library/Frameworks/Maple.framework/Versions/2015'
        if [ -x "$MAPLE_HOME" ]; then
            _push PATH    "$MAPLE_HOME/bin"
            _push MANPATH "$MAPLE_HOME/man"
            # LOCAL_MAPLE is for Hakaru. Dunno what the usual env-variables for Maple are
            export LOCAL_MAPLE="$MAPLE_HOME/bin/maple"
        fi
        unset MAPLE_HOME

        # Various things we've installed (and stowed) without Fink.

        # Technically, texbin is already on the path; but we want
        # to move up up so it shadows /sw; otherwise we won't get the
        # new programs.
        _push  PATH       '/Library/TeX/texbin'
        _push  MANPATH    '/Library/Tex/texman'

        _push  PATH       '/usr/local/bin'
        _push  MANPATH    '/usr/local/share/man'
        _push  MANPATH    '/usr/local/man'
        _push  PYTHONPATH '/usr/local/lib/python2.7/site-packages/'
        export PYTHONPATH

        # Links to Haskell utils in order to keep things up to date
        _push PATH '~/local/haskell/bin'
        # Cabal-installed programs
        _push PATH '~/.cabal/bin/'
        _push MANPATH '~/.cabal/share/man/'
    ;;
    elsamelys)
        # add path to gcc tools, assuming the cramfs is mounted
        _copush PATH '/mnt/gcc/bin'
    ;;
    banks)
        JAVA_HOME='/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home'
        _push PATH    "$JAVA_HOME/bin"
        _push MANPATH "$JAVA_HOME/man"

        # ~~~~~ In the default config, these come last!!
        # For irssi etc.
        _push PATH    '/usr/local/bin'
        _push MANPATH '/usr/local/share/man'

        _push PATH    '/usr/texbin'
        _push MANPATH '/Library/TeX/Distributions/.DefaultTeX/Contents/Man'

        _push PATH    '/usr/X11/bin'
        _push MANPATH '/usr/X11/man'

        _push PATH    '/usr/local/git/bin'
        _push MANPATH '/usr/local/git/share/man'
    ;;
    miller)
        # Miller has Java-1.6 by default

        # Include Anaconda for SciPy
        _push PATH '/Library/anaconda/bin'
    ;;
    google)
        case "${_uname}" in
            Linux)
                # BUG: for some reason my Goobuntu station starts off
                # with MANPATH='~/local/man', causing it to fail to load
                # the default manpath.
                unset  MANPATH
                export MANPATH="$(manpath)"

                # This is where cabal-install puts things these days,
                # so we need to make sure its on our path and supercedes
                # the (ancient) version that ships with goobuntu/glinux.
                _push PATH '~/.cabal/bin'
                _push MANPATH '~/.cabal/share/man/'

                # (2021.07.26): LLVM/MLIR uses GOMA too, so (preparing to) re-enabling this.
                # WARNING: goma doesn't play nice with GHC, at all.
                # WARNING: previously we got into a state where: even if
                #   this line is commented out it was being magically
                #   pulled in from the beginning of time (i.e.,
                #   before we even enter /etc/profile, let alone enter
                #   this .bash_profile); and that despite not being set
                #   in /etc/environment either.  My previous suspicion
                #   was that it's being set by Xsession or pam or
                #   something similar...
                #   (Re how to debug these sorts of things, see:
                #   <https://unix.stackexchange.com/a/154971>)
                #_push PATH '~/src/depot_tools'
                # WARNING: this will steal "gcc" and "g++" from /usr/bin
                # And you need to do special things to get goma started.
                #_push PATH '~/src/goma'
                # TODO: These two should probably be bundled into a
                #   separate script for general google login cruft,
                #   rather than being done here.
                #goma_auth login
                #goma_ctl ensure_start
                # TODO: also be sure to add this to .bash_logout or similar
                #goma_auth logout
            ;;
        esac
    ;;
esac


# ~~~~~ Last step: Everyone gets my personal scripts and programs
_push PATH    '~/local/bin'
_push MANPATH '~/local/man'


# ~~~~~ Finally: Sanitize paths
# This guard is to be safe so we don't obliterate our $PATH. Of
# course, if this fails then we prolly want to bail out entirely
# (since something is seriously wrong).
# N.B. [ ! -z ] and [ ! -z "" ] and [ -s "" ] all return false
#      But [ -s ] returns true!!!
# TODO: use the "type" or "command -v" built-in, rather than using `which`:
# <https://stackoverflow.com/a/677212>
if [ ! -z "$(which sed)" ] && [ -x "$(which sed)" ]; then
    # BUG: we don't ~-expand MANPATH (not that anything is there...)

    # Debugging, should usually be turned off
    #echo "Before cleaning: $PATH"

    # Do our best to remove '.' from our path in case it managed to sneak in
    # N.B. don't add -n to echo!! don't add ""s around the ``s!!
    # BUG: should use $() instead of ``
    # BUG: should use printf instead
    PATH=`echo "${PATH}" | sed '
        s/:\.:/:/g; s/::/:/g;
        s/^\.://;   s/^://;
        s/:\.$//;   s/:$//; '`

    # Convert ~/ so that `which` works properly. Otherwise ~/ is fine.
    # Doesn't deal with the ~user/ construct though.
    #    The $_home is in the subshell and so not exported
    #    The complicated sed for $_home is to safely escape \ and / in $HOME
    #    The different regexes for ~/ and ~: are because there's no | in basic sed
    # N.B. don't add -n to echo!! and don't need ""s around $()s
    # BUG: should use printf instead
    # BUG: should use ${///} instead of echo/printf + sed
    PATH=$(
        _home=$(echo "${HOME}" | sed 's/\\/\\\\/g; s/\//\\\//g')
        echo "${PATH}" | sed "s/~\//${_home}\//g; s/~:/${_home}:/g"
    )
    # Bash does tilde expansion for PATH, MAILPATH, and CDPATH; but
    # it doesn't for MANPATH.
    MANPATH=$(
        _home=$(echo "${HOME}" | sed 's/\\/\\\\/g; s/\//\\\//g')
        echo "${MANPATH}" | sed "s/~\//${_home}\//g; s/~:/${_home}:/g"
    )

    # TODO: maybe also add a filter to remove (and warn about)
    # directories that don't exist.

    # Debugging, should usually be turned off
    #echo "Final path: $PATH"
fi

# This version is a lot cleaner and more complete, but it requires
# perl which is expensive and isn't always available.
#export PATH=`echo "$PATH" | perl -pe '
#    1 while s/:\.?:/:/g;
#    s/^\.?://;
#    s/:\.?$//;
#    s/^\.$//;
#    s/(^|:)~(\/|:|$)/$1$ENV{HOME}$2/g; '`

export PATH MANPATH LD_LIBRARY_PATH JAVA_HOME


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set up other common env variables

# BUG: for some reason, setting LESS breaks git-log (unless we include -r).
export PAGER="less -isq"
export MANPAGER="${PAGER}"
# TODO: set/export MANWIDTH. Or even hook $PROMPT_COMMAND (or
# SIGWINCH) to re-set it via `tput cols`/$COLUMNS. (BUG: though
# MANWIDTH doesn't seem to do anything if set to 66 or greater...)


# What's the difference between EDITOR and VISUAL?
#   <https://unix.stackexchange.com/a/4861>
#   <https://unix.stackexchange.com/a/334022>
#   So supposedly these days we should either leave EDITOR unset,
#   or set it to 'vim -E' (or 'vim -e' if you're brave).  Though
#   afaict most every program looks at EDITOR regardless of the
#   originally intended distinction.  So I think I'll keep ignoring
#   the distinction until I run into trouble.
#   ...Also, one of the commentors noted that while most programs
#   treat VISUAL like a shell snippet, but others will treat it as
#   the name of an executable to look up in the PATH.
#
# Okay, so what's the difference between '-E' vs '-e'?
#   <https://vi.stackexchange.com/a/2695>
#
# TODO: does giving the full path like this fix the bug where git
#   was picking up /usr/bin/vim rather than the one that comes first
#   in the PATH?  (2021-08-21: I'm no longer experiencing this
#   problem on git 2.27.0 on my personal machine.  So after checking
#   the work machines to verify, consider this resolved either way.)
# TODO: for more robust scripting of this, see:
#   <https://unix.stackexchange.com/a/302391>
_vim="$(which vim)"
export EDITOR="$_vim"
export VISUAL="$_vim"
export SUDO_EDITOR="$_vim"
# For OSes that use systemctl (e.g., archlinux) we may also want
#   to set SYSTEMD_EDITOR; though again, only if it needs to be
#   different from EDITOR/VISUAL.
# For Debian-alikes (including Fink) you may prefer to use:
#   `sudo update-alternatives --config editor`
#
# TIL about the shell builtin `fc`, which is awesome:
#   <https://unix.stackexchange.com/a/286514>
#   So we should export FCEDIT if for some reason we need to pass
#   extra flags or otherwise choose something different from EDITOR.
# TIL about the Bash magic <C-x><C-e> which opens VISUAL (fails
#   back to EDITOR) and then executes whatever you write there!
#   <https://www.gnu.org/software/bash/manual/html_node/Miscellaneous-Commands.html>
#   (To see what all keybindings Bash has set up, run `bind -p` or `bind -P`)
#   ...For Zsh you can enable/add <C-x><C-e> via:
#   `autoload -z edit-command-line`
#   `zle -N edit-command-line`
#   `bindkey "^X^E" edit-command-line`
#   <https://unix.stackexchange.com/a/34251>
#   or:
#   `autoload edit-command-line`
#   `zle -N edit-command-line`
#   `bindkey -M vicmd v edit-command-line`
#   <https://unix.stackexchange.com/a/90529>
unset _vim

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set up Perl

_push  PERL5LIB "${HOME}/local/perl"
export PERL5LIB


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set up LaTeX

# Paths beginning with !! use an index file (use `texhash` to renew it)
# Paths ending in // will search recursively down (requires index)
# The trailing : means to look in all the usual places next
export TEXINPUTS=".:${HOME}/local/texmf/tex/latex//:"

# These two are for BibTeX to find *.bst/*.bib files.
# Dunno about any of that funny !! // stuff here (but trailing : is the same)
# Tilde-expansion does work in these, but we'll use ${HOME} anyways
export BSTINPUTS=".:${HOME}/local/texmf/bibtex/bst:"
export BIBINPUTS=".:${HOME}/local/texmf/bibtex/bib:"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set up Git

# N.B., setting these overrides the `git config --global user.*`
# settings; not sure about the repo specific `git config user.*`
# though.
#
# Thus we are henceforth removing all this, so that the git config
# files work as intended (and to avoid issues about having made github
# email private).
# TODO: At some future date, after fixing any breakage, actually remove this.
#case "${_hostname}" in
#    google)
#        export GIT_AUTHOR_EMAIL='wrengr@google.com'
#        # TODO: How to dynamically set the following on a repo-by-repo basis?
#        #export GIT_AUTHOR_EMAIL='wrengr@chromium.org'
#    ;;
#    *)
#        # Actually, this is already the global user.email now...
#        export GIT_AUTHOR_EMAIL='2998727+wrengr@users.noreply.github.com'
#    ;;
#esac
#export GIT_AUTHOR_NAME='wren romano'
#export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
#export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set up Darcs

# Like `grep -R $1 .`; cf.,
# <http://darcs.net/HintsAndTips#excluding-the-_darcs-directory-when-searching>
# TODO: We may want to switch to using a real script, like xwrn's version there.
# TODO: just start using <http://blog.burntsushi.net/ripgrep/>
#
# In general, beware of `find` corrupting your repos
# BUG: doesn't color like the grep alias
# BUG: egrep is giving a lot of "Is a directory" errors
# TODO: should prolly use `sed 's/./\\&/g'` between the find and
# xargs, to avoid bugginess: <http://www.etalabs.net/sh_tricks.html>
alias dgrep="find . -path '*/_darcs' -prune -o -print0 | xargs -0 egrep"
alias svngrep="find . -path '*/.svn' -prune -o -print0 | xargs -0 egrep"

# So `darcs init` doesn't keep prompting me for it
export DARCS_EMAIL="wren romano <wren@cpan.org>"
# TODO: ever since community.haskell.org got retired I've defaulted
# back to using my cpan email as the public-facing one. But really
# need to establish a new public-facing email for all my Haskell (etc)
# coding.

# To fix postfix on OSX:
# $> echo 'canonical_maps = hash:/etc/postfix/canonical' >> /etc/postfix/main.cf
# $> echo 'username bla@example.com' >> /etc/postfix/canonical
# $> postmap /etc/postfix/canonical

# TODO: Set up Mercurial (if anyone still uses it)


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set up completion
# (you don't need to enable this, if it's already enabled in
# /etc/bash.bashrc and /etc/profile sources /etc/bash.bashrc).
#
# N.B., on maracuya completion is automatically enabled via /etc/profile.
if [ -r '/etc/bash_completion' ]; then
    source '/etc/bash_completion'

    # Import bash completions for darcs
    # Seems to have a few issues though re normal tab file-completion...
    ### bash-completion is severely broken!!
    #[ -r '.darcs_completion' ] && source '.completion/darcs'
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# No longer setting variables for various servers; instead see ~/.ssh/config


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ `ls` aliases

case "${_uname}" in
    Darwin | FreeBSD)
        alias ls='ls -G' # turn on color
        alias lv='ls -v' # unicode. opposite is -q (=default)
        # TODO: does -v actually work on FreeBSD? or just on OSX?
    ;;
    Linux)
        # This should work for all GNU-using systems (e.g., Debian
        # variants), but may not work for other Linuxes.
        #
        # TODO: guard against it not working; e.g., dircolors not
        # existing. Can use the _exists function defined below.
        eval $(dircolors -b)
        alias ls='ls --color=auto'
    ;;
esac

alias l='ls -CF'          # no `ls-F` in bash
alias ll='ls -lh'         # default to human-readable file sizes
alias la='ls -A'
alias lla='ls -Alh'

# List *only* the dot files
#     excluding . and .. like -A
#     and dropping the directory name from the listing like usual `ls`.
# BUG: can't pass extra flags like you can for the aliases
# BUG: if the directory doesn't exist then `cd` complains instead of `ls`
# N.B., proper `sh` doesn't like these function names. Only Bash allows them.
# BUG: the function() combo is a Bashism... But we should rename
#      these before fixing that...
function l.() {
    if [ "$1" = '' ] ; then d='.' ; else d="$1" ; fi
    ( cd $d && ls -d .[^.]* ..?* )
}
function ll.() {
    if [ "$1" = '' ] ; then d='.' ; else d="$1" ; fi
    ( cd $d && ls -dlh .[^.]* ..?* )
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Other basic aliases

# TODO: verify that this has the same effect as the following aliases, and that it works on both OSX and Linux/GNU
# N.B., git-secrets clears this variable before calling grep!
export GREP_OPTIONS='--color=auto'
#alias grep='grep --color'
#alias egrep='egrep --color=auto'
#alias fgrep='fgrep --color=auto'

case "${_hostname}" in
    mayari | miller | banks )
        # OSX lacks the tool, but it has the functionality
        # TODO: should actually switch on _uname='Darwin' instead!
        alias ldd='otool -L'
    ;;
    elsamelys | UNKNOWN )
        # stupid grep, no color
        export GREP_OPTIONS=''
        #unalias grep
        #unalias egrep
        #unalias fgrep
    ;;
    google )
        case "${_uname}" in
            Linux)
                alias open='xdg-open &>/dev/null'
                alias pbcopy='xsel --clipboard --input'
                alias pbpaste='xsel --clipboard --output'

                # A much better version of `blaze run`
                alias br='/google/src/head/depot/google3/devtools/blaze/scripts/blaze-run.sh'
                # Tab completion to do things like `br :hello_world`
                complete -o nospace -F _blaze::complete_build_target_wrapper br
                # for `blaze build` and `blaze test` would to similar
                # if we have aliases. N.B., that explodes if we haven't
                # run `prodaccess` recently enough.

                # Ditto, but for gghci
                complete -o nospace -F _blaze::complete_build_target_wrapper gghci
            ;;
        esac
    ;;
esac

# Parse `which` to return whether it found something or not
# (Since normally it returns success either way)
# TODO: use the "type" or "command -v" built-in, rather than using `which`:
# <https://stackoverflow.com/a/677212>
_exists() { which "$1" 2>&1 | grep ^/ >/dev/null ; }

whoall() { who -u | awk '{if ($6 != "old") print $0}' | sort ; }

_exists whoami   || alias whoami='who am i' # These are subtly different
_exists whereami || alias whereami='printf %s\\n "$HOSTNAME"'
_exists whatis   || alias whatis='man -f'
_exists apropos  || alias apropos='man -k'

# BUG: the -l flag seems to be an OSXism, and isn't supported on
# Goobuntu. Actually, *all* the args are different between Ubuntu-likes
# and OSX! Looks like we really must write our own version afterall.
alias fmt='fmt -l 0 -t 4' # Turn off space2tab conversion and set tabstop=4
                      # 8-char tabs be damned! N.B. vim won't respect this because it's just a shell alias.

# This is buggy when doing GALE/Joshua stuff
# I think it was only needed because of some broken Solaris machines
#alias cat="cat -v"    # Make non-printing chars visible

alias rd='rmdir'
alias md='mkdir'

# HACK: trying to work around `clear` not behaving properly on
# Ubuntu/gnome-terminal. This is a gross hack because whenever we
# ssh into somewhere, the version of `cl` there is going to be based
# on *that* machine's ${_uname} rather than being based on the
# terminal of the machine we're sshing *from*. Really need to figure
# out if there's a way to fix that and actually work based on terminals.
#
# N.B., how to actually clear things is highly terminal-specific.
# So if this stops working, you may want to try some other approaches
# like `reset`, `clear && printf '\e[3J'`, etc. <http://askubuntu.com/q/25077>
if [ "${_hostname}" = 'google' ]; then
    case "${_uname}" in
        Darwin)
            # `clear` works just fine on OSX/iTerm2. Or rather, it
            # looks like the same problem occurs here too, but I
            # always use <Apple-k> to clear the scrollback so I never
            # actually notice it.
            alias cl='clear'
        ;;
        Linux)
            # But `clear` is busted on my Goobuntu/gnome-terminal
            # machine.
            alias cl='echo -e "\033c"'
        ;;
        *)
            # Debugging. Should usually be left on
            echo "Can't set \`cl\` alias for unknown google OS: ${_uname}"
        ;;
    esac
else
    # Assuming everywhere else works fine. (But prolly not)
    alias cl='clear'
fi
# uses `cl` and `ll` aliases
alias cll='cl;ll'
alias q='exit'
alias :q='exit'
alias :q!='exit'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Other helpful functions, aliases, and Perl microprograms

# A variant of `cd` which canonicalizes the path.
ccd() {
    local _dir='.'
    if [ $# -gt 1 ]; then
        echo "Usage: ccd [dir]"
        return 1
    elif [ $# -eq 1 ]; then
        _dir="$1"
    fi

    # Assumes we have my ~/local/bin/_abspath
    cd "$(_abspath -k ${_dir})"
}

# Safely copy directories
# BUG: dirname doesn't seem to deal with .. right
tarcp() {
    ( cd "$(dirname "$1")" && tar cf - "$(basename "$1")" ) |
        ( cd "$2" && tar xpf - )
}

# Pretend we have manpages for shell builtins
# HT: <https://askubuntu.com/a/439411>
# BUG: OSX's version of `help` doesn't have the -m flag.  Also the
#   results of `help` seem a bit terse; may have to kludge something
#   together from `info builtin` too.
#man() {
#    case "$(type -t -- "$1")" in
#    builtin|keyword)
#        help -m "$1" | $MANPAGER
#        ;;
#    *)
#        command man "$@"
#        ;;
#    esac
#}

# Actually, we can use the `seq` program for this; which also allows
# setting the lower bound. Dunno if that's available on stock Debian,
# but it is on Darwin/BSD and Goobuntu/gLinux.
#enum() { perl -e 'print "$_\n" foreach 1..'"$1" ; }

# Do `time` some number of times and average the results
# TODO: it's better to use Criterion for this
# BUG: Bash has a built-in with this name...
times() {
    local n=$1 ; shift
    ( for _n in `seq $n` ; do
        time "$@" >>/dev/null
    done ) 2>&1 | perl -ne'
        $h{$1} += $2*60+$3
            if m/^(\S*\s+)(\d+)m((?:\d|\.)+)s$/;
        END { printf "$_ %.3fs\n",$h{$_}/'"$n"'
            foreach sort keys %h }'
}

# Things that only work on OS X, or on my setup
if [ "${_hostname}" = 'mayari' ]; then
    # Actually this opens in reverse order, but that makes it
    # in order front to back for certain programs
    open-in-order() {
        local f
        local line
        # BUG: should use printf instead
        # TODO: should prolly use `sed 's/./\\&/g'` between the find and
        # xargs, to avoid bugginess: <http://www.etalabs.net/sh_tricks.html>
        for f in "$@" ; do echo "$f" ; done | sort -r | xargs open
    }

    # TODO: combine shutdown with some osascript for softer shutdown when possible...
    alias goodnight='sudo shutdown -h +90'

    alias motoko='su motoko'
    alias root="su motoko -c 'sudo su'"

    # Move something to the trash (rather than unlinking)
    del() { mv "$@" ~/.Trash ; }

    alias cpan="echo 'Make sure FTP is not blocked by firewall'; su motoko -c '/sw/bin/perl -MCPAN -e shell'"

    # Use screen saver for desktop "image"
    alias ssbg='echo "Hit ^C to quit"; /System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -background'

    # (iTerm only) Send a Growl notification
    # <http://aming-blog.blogspot.com/2011/01/growl-notification-from-iterm-2.html>
    growl() { echo -e $'\e]9;'"$@"'\007' ; }
fi

# Remove .DS_Store items in this folder and subfolders
# Re using -delete vs -exec: <https://unix.stackexchange.com/a/167824>,
# <https://unix.stackexchange.com/a/194348>
alias rm-ds-store='find . -name .DS_Store -exec rm {} \;'

alias _find_writable='find . -perm +022'
alias _ls_writable_dirs='find . -type d -perm +022 ! -name '\''*.app'\'' -exec ls -1d {} \;'

# TODO: just learn to use dc & bc already
# A simple but powerful commandline calculator (the POSIX is for floor, ceil, log10)
alias pcalc='perl -W -Mstrict -MPOSIX -e'\''use vars qw($val);
sub log2 { my($x)=@_; return (log $x)/(log 2) };
sub fac  { my($x)=@_; my $r = 1; $r *= $x-- while $x > 1; return $r };
sub C    { my($n,$r)=@_; return fac($n) / ( fac($r) * fac($n-$r) ) };
sub P    { my($n,$r)=@_; return fac($n) / fac($n-$r) };

eval join q( ), q($val = ), @ARGV, q(;);
die $@ if $@;
print "$val\n";'\'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Google-specific functions

if [ "${_hostname}" = 'google' ] && [ "${_uname}" = 'Linux' ]; then

    # Bash Function to call whenever we use `hgd`
    hgd_postexec() {
        # Canonicalize the path in `pwd`.
        # This solves a bug where hg can't find its config files, since
        # there's a symlink somewhere in the standard path that hgd sends
        # us to.
        ccd
        # Set the G3 Workspace root directory.
        export G3DIR=$(pwd)
    }
    # Actually add the function to the list of hooks:
    hgd_postexec_functions+=(hgd_postexec)

    # TODO: Are the following commands still actually necessary since switching teams?

    # This bunch of functions is to work around issues of objfs/srcfs
    # updates breaking long-running processes in the middle of the night
    # (2am to 4am). Intended use is to run `hold_disruptive_updates`
    # just before the nightlong job, and then run `release_held_updates`
    # once you're finished. To avoid holding them for too long it's
    # suggested to call `nag_about_held_updates` in this startup profile,
    # so that we see it often enough.
    #
    # TODO: is there any good way to convert this into a higher-order
    # bracketing construct we can wrap around the long-running command?
    # In particular, it'd be nice to do that in order to work around
    # the issue that release_held_updates requires sudo (and the
    # credentials from the sudo in hold_disruptive_updates will have
    # expired by the time we call it).

    hold_disruptive_updates() {
        sudo dpkg --set-selections << EOF
google-objfsd   hold
srcfs           hold
EOF
    }

    # TODO: make this prettier...
    list_held_updates() {
        dpkg --get-selections \
            | grep "hold$"
    }

    release_held_updates() {
        list_held_updates\
            | sed 's/hold$/install/' \
            | tee /dev/tty \
            | sudo dpkg --set-selections
    }

    # TODO: make this prettier...
    # Call this at the end of ~/.bash_profile. Or if we want to be
    # really obnoxious, then we could add it to PROMPT_COMMAND or use
    # `watch` or similar.
    nag_about_held_updates() {
        list_held_updates || return 0
        echo
        echo "Consider running:"
        echo "  release_held_updates"
        echo
    }

    # In the event we want it for some reason
    force_held_updates() { sudo install-delayed-packages -u ; }

    nag_about_held_updates
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Assorted Bash prefs. See bash(1) for more options.

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Don't put duplicate lines in the history
export HISTCONTROL=ignoredups

# Colon-seperated patterns to not store in histfile
export HISTIGNORE='ls:l:ll:la:lla:l.:ll.:cl:cll:q:x:cd:ghci'

# Colon-seperated dirs where `cd` manoeuvres from
#export CDPATH='.:~'

# Colon-seperated file suffixes ignored for tab completion
#export FIGNORE='.o:.hi:.swp:~'

# "/etc/hosts"-like file to be read for completing hostnames
#export HOSTFILE=''

# Enable if you want inline tab-completion rather than the list
#bind '"\t":menu-complete'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set window names to something helpful

# If this is an xterm set the title to user@host:dir
case "${TERM}" in
    xterm* | rxvt* )
        #export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'

        # This is so we can combine this with the short $PWD
        # for some reason [ -n $PROMPT_COMMAND ] comes up true even if it's empty
        export PROMPT_COMMAND=$(
            if [ "${PROMPT_COMMAND}" != '' ]; then
                echo -n "${PROMPT_COMMAND}; "
            fi
            )'echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
        ;;
esac

# from Marc Liyanage <http://www.entropy.ch:16080/software/macosx/docs/customization/>
# tcsh method for the curious
#setenv SHORTHOST `echo -n $HOST | sed -e 's%\..*%%'`
#alias precmd 'printf "\033]0;%s @ $SHORTHOST\007" "${cwd}" | sed -e "s%$HOME%~%"'
#sched +0:00 alias postcmd='printf "\033]0;%s @ $SHORTHOST\007" "\!#"'


# limit namespace polution
unset _uname _hostname

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ END                                            END ~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
