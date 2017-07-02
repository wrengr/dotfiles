# This is wren gayle romano's bash login script     ~ 2017.05.28
#
# It's fairly generic (with weirder things at the bottom),
# but it's designed to be usable for all my accounts with no(!)
# modifications.
#
# It may also help to have a .bashrc file that sources this one.
# Remember .bash_profile == login shells, .bashrc == non-login.
# But bear in mind, you don't want a bunch of this crap when you
# login via, say, `scp`.

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Personalized MOTD so I stop forgetting shit
#       (Unless the shell is non-interactive)
if [ ! -z "${PS1}" -a -r '.motd' ]; then
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
_uname="`uname`"

# On some systems (e.g., *.haskell.org, and very new versions of
# OSX) we can use `hostname -f` to get the FQDN; but older OSX, and
# most other *NIXes don't have the `-f` flag. The `uname` utility
# is defined by POSIX/SUSv4; whereas the `hostname` has no spec,
# and so is different everywhere. (On GNU/Linux, `hostname` happens
# to coincide with `uname -n`, but that's just a coincidence, not
# guaranteed.) Notably, `uname -n` is just a very thin wrapper that
# just calls gethostname(2), which is why it doesn't resolve FQDNs.
_hostname="`uname -n`"

# Sites who use relative host names instead of FQDNs suck!
case "${_hostname}" in
    # Also assume eresh if we've been renamed by dhcp (Foo on dhcp!)
    # TheWitchsBroom == Hopscotch, when it's broken
    ereshkigal* | semiramis* | xenobia* | *.pubnet.pdx.edu | *.dhcp.pdx.edu | remote*.cecs.pdx.edu | *.comcast.net | TheWitchsBroom.att.net )
                                   _localhost='ereshkigal' ;;
    elsamelys*)                    _localhost='elsamelys' ;;

    cl.indiana.edu)                _localhost='banks' ;;
    nlp.indiana.edu)               _localhost='miller' ;;
    # TODO: *.karst.uits.iu.edu x86_64 GNU/Linux

    *.haskell.org | lun)           _localhost='haskell' ;;
    *.google.com)
        # BUG: doesn't distinguish between my workstation and
        # ciruela (both Goobuntu), vs my laptop (OSX)
        _localhost='google'
    ;;

    # If all else fails...
    *)
        if [ "${_uname}" = 'Darwin' ]; then
            # Guess that any other OSX is also Ereshkigal, or else
            # supports the same sorts of things in general.
            _localhost='ereshkigal'
            # Debugging. Should usually be left on
            [ -z "${PS1}" ] || echo "I resorted to guessing I'm on ereshkigal!"
        elif [ "`uname -m`" = 'armv5tel' ]; then
            _localhost='elsamelys'
        else
            # Debugging. Should usually be left on
            [ -z "${PS1}" ] || echo "I couldn't figure out where I am!"
            _localhost='UNKNOWN'
        fi
    ;;
esac

# Debugging. Should usually be turned off
#[ -z "${PS1}" ] && echo "I'm on ${_localhost}"


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

# Google's `screen` is annoying.
if [ "${_localhost}" = 'google' ]; then
    # N.B., Goobuntu's `screen` sets TERM='screen-bce' rather than TERM='screen'.
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
# same way. Using `su -` *should* rectify this

# And some places (drkatz, sting,...) unset $USER with `su -` ::sigh::
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
    if [ "`tput colors`" -gt 2 ]; then
        # A better way even is to use [ `id -u` = 0 ]
        # ...though that doesn't find non-root users
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
    _exit="\$(x=\$?; [ \$x -ne 0 ] && echo -n \"\[\e[01;31m\]\$x${_off} \")"

    # The actual prompt itself
    # TODO: factor out the [ ] @ :
    PS1="${_bold}[${_off}${_j}${_bold}]${_off} ${_u}${_bold}@${_off}${_h}${_bold}:${_off}${_w} ${_s} ${_exit}"

    # Short prompt for elys, but only when logged in directly
    if [ "${_localhost}" = 'elsamelys' ]; then
        if tty | grep ttya >/dev/null ; then
            PS1="[${_j}] ${_w} ${_s} ${_exit}"
        fi
    fi

    export PS1
    unset  _color1 _color2 _bold _off _j _u _h _w _s _exit
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
function _pwd_shorten() {
    local _length=30
    [ "$1" != '' ] && _length="$1"

    # This is to fix munging on marquise since it doesn't auto $HOME -> "~"
    # Only performs the substitution when there's a following slash,
    #     in case your username is a prefix of someone else's. Could be fixed with better regex
    local _home="$(echo "${HOME}" | sed 's/\\/\\\\/g; s/\//\\\//g')"
    _PWD="$(pwd | sed "s/^${_home}\//~\//; s/^${_home}$/~/")"

    # ${#_PWD} == $(echo -n "${_PWD}" | wc -c | tr -d ' ')
    if [ ${#_PWD} -gt ${_length} ]; then
        echo "${_PWD}" | sed "s/.*\(.\{`expr ${_length} - 3`\}\)$/...\1/"
    else
        echo "${_PWD}"
    fi
}
# Using the `declare` to check for existence, preventing
# issues about `su` not inheriting functions.
export PROMPT_COMMAND='declare -F _pwd_shorten >/dev/null && _PWD="`_pwd_shorten`"'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Load the ssh-agent, if present
#       (To set the .ssh/agent cache, use the `agent` alias)
# TODO: update this stuff to work with `gcert` on google machines

if [ -r '.ssh/agent' ]; then
    # We don't need the -e if we're passing the PID directly.
    # N.B., passing -e or -U (or -u?) overrides the -p flag.
    if ps -co pid,user,command -p `
            cat .ssh/agent |
            perl -nle '
                BEGIN {$pid = 0;}
                $pid = $1 if m/^SSH_AGENT_PID=(\d+)/;
                END {print $pid;}'` |
        grep "${USER}" |
        grep 'ssh-agent' >/dev/null 2>&1
        # N.B., don't use -s or -q, for portability
    then
        source '.ssh/agent'
    else
        rm '.ssh/agent'
    fi
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Add a new colon-delimited value to the front of a variable
#       Usage: `_push varname value`
function _push() {
    # Get the old value by double evaluation.
    # N.B. using `` instead of $() breaks the quoting/escaping
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
function _copush() {
    # Get the old value by double evaluation.
    # N.B. using `` instead of $() breaks the quoting/escaping
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
if [ "${_localhost}" = 'ereshkigal' ]; then
    [ -r '/sw/bin/init.sh' ] && source '/sw/bin/init.sh'

    # This is needed for some linkers, like Cabal which can't
    # correctly pass -optl-L* to GHC (which would pass -L* to ld)
    _push  LD_LIBRARY_PATH '/sw/lib'
    export LD_LIBRARY_PATH
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set up paths

# Debugging, should usually be turned off
#echo "Beginning path: $PATH"
#echo "Beginning manpath: $MANPATH"


case "${_localhost}" in
    ereshkigal)
        # We use Java6 (needed for ADE) instead of the default
        # Java5. But we don't actually alter OSX's default Java
        # (i.e., '/Library/Java/Home') since doing that can cause
        # problems with built-in OS stuff.
        JAVA_HOME='/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home'
        _push PATH    "$JAVA_HOME/bin"
        _push MANPATH "$JAVA_HOME/man"

        MAPLE_HOME='/Library/Frameworks/Maple.framework/Versions/2015'
        _push PATH    "$MAPLE_HOME/bin"
        _push MANPATH "$MAPLE_HOME/man"
        # LOCAL_MAPLE is for Hakaru. Dunno what the usual env-variables for Maple are
        export LOCAL_MAPLE="$MAPLE_HOME/bin/maple"
        unset MAPLE_HOME

        # Various things we've installed (and stowed) without Fink.
        _push  PATH       '/usr/local/bin'
        _push  MANPATH    '/usr/local/share/man'
        _push  MANPATH    '/usr/local/man'
        _push  PYTHONPATH '/usr/local/lib/python2.7/site-packages/'
        export PYTHONPATH

        # Links to Haskell utils in order to keep things up to date
        _push PATH '~/local/haskell/bin'
        # Cabal-installed programs
        _push PATH '~/.cabal/bin/'
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
                export MANPATH=`manpath`

                _push PATH '~/chromium-srcs/depot_tools'
                # WARNING: this will steal "gcc" and "g++" from /usr/bin
                # And you need to do special things to get goma started.
                _push PATH '~/chromium-srcs/goma'
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
if [ ! -z "`which sed`" -a -x "`which sed`" ]; then
    # BUG: we don't ~-expand MANPATH (not that anything is there...)

    # Debugging, should usually be turned off
    #echo "Before cleaning: $PATH"

    # Do our best to remove '.' from our path in case it managed to sneak in
    # N.B. don't add -n to echo!! don't add ""s around the ``s!!
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
    PATH=$(
        _home=$(echo "${HOME}" | sed 's/\\/\\\\/g; s/\//\\\//g')
        echo "${PATH}" | sed "s/~\//${_home}\//g; s/~:/${_home}:/g"
    )

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

export PAGER='less -is'
export MANPAGER="${PAGER}"
export EDITOR='vim'


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
# ~~~~~ Set up CVS
# TODO: does anyone still use this?

export CVS_RSH='ssh'
export CVSIGNORE='.DS_Store'

case "${_localhost}" in
    ereshkigal )
        # TODO: is this even still valid?
        export CVSROOT='wren@cvs.freegeek.org:/var/lib/cvs/'
    ;;
esac


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set up Git

# N.B., setting these overrides the `git config --global user.*` settings
case "${_localhost}" in
    google)
        export GIT_AUTHOR_EMAIL='wrengr@google.com'
        # TODO: How to dynamically set the following on a repo-by-repo basis?
        #export GIT_AUTHOR_EMAIL='wrengr@chromium.org'
    ;;
    *)
        export GIT_AUTHOR_EMAIL='wren@community.haskell.org'
    ;;
esac
export GIT_AUTHOR_NAME='wren romano'
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set up Darcs

# Like `grep -R $1 .`; cf.,
# <http://darcs.net/HintsAndTips#excluding-the-_darcs-directory-when-searching>
# TODO: We may want to switch to using a real script, like xwrn's version there.
#
# In general, beware of `find` corrupting your repos
# BUG: doesn't color like the grep alias
# BUG: egrep is giving a lot of "Is a directory" errors
alias dgrep="find . -path '*/_darcs' -prune -o -print0 | xargs -0 egrep"
alias svngrep="find . -path '*/.svn' -prune -o -print0 | xargs -0 egrep"

# So `darcs init` doesn't keep prompting me for it
# HACK: we reuse the git variables for DRY; but that's weird on google machines
export DARCS_EMAIL="$GIT_AUTHOR_NAME <$GIT_AUTHOR_EMAIL>"

# To fix postfix on OSX:
# $> echo 'canonical_maps = hash:/etc/postfix/canonical' >> /etc/postfix/main.cf
# $> echo 'username bla@example.com' >> /etc/postfix/canonical
# $> postmap /etc/postfix/canonical

# TODO: Set up Mercurial


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Set up completion
# (you don't need to enable this, if it's already enabled in
# /etc/bash.bashrc and /etc/profile sources /etc/bash.bashrc).
if [ -r '/etc/bash_completion' ]; then
    source '/etc/bash_completion'

    # Import bash completions for darcs
    # Seems to have a few issues though re normal tab file-completion...
    ### bash-completion is severely broken!!
    #[ -r '.darcs_completion' ] && source '.darcs_completion'
fi


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Server variables

case "${_localhost}" in
    ereshkigal)
        elsamelys='zaurus@192.168.129.201'
        banks='wren@cl.indiana.edu'
        # TODO: We should switch this one to wrengr, like everything else.
        miller='wrnthorn@nlp.indiana.edu'
        # TODO: does sourceforge stuff even still work?
        #sourceforge='winterkoninkje@shell.sourceforge.net'
        #pbwdm_sfsite="${sourceforge}:/home/users/w/wi/winterkoninkje/pbwdm/htdocs"
        haskell_community='wren@community.haskell.org'
    ;;
    google)
        google_workstation='wrengr@wrengr0.mtv.corp.google.com'
        ciruela='wrengr@ciruela.mtv.corp.google.com'
    ;;
esac


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ `ls` aliases

# Apparently Bash>=4.0 adds a new ";&" thing for allowing fallthrough.
# That'd help us DRY for Darwin vs FreeBSD, but it isn't portable
# to systems with older versions of Bash.
case "${_uname}" in
    Darwin)
        alias ls='ls -G' # turn on color
        alias lv='ls -v' # unicode. opposite is -q (=default)
    ;;
    FreeBSD)
        alias ls='ls -G'
        # TODO: does 'ls -v' work here too?
    ;;
    Linux)
        # This should work for all GNU-using systems (e.g., Debian
        # variants), but may not work for other Linuxes.
        #
        # TODO: guard against it not working; e.g., dircolors not
        # existing. Can use the _exists function defined below.
        eval `dircolors -b`
        alias ls='ls --color=auto'
    ;;
    SunOS)
        # Color ls doesn't exist on Solaris, unless we install/use GNU
        case "${_localhost}" in
        psu)
            # drkatz and walt are "special" and lack `dircolors`
            [ -x /pkgs/gnu/bin/dircolors ] &&
                eval `/pkgs/gnu/bin/dircolors -b`

            # `ls` is a symlink to `gls` on drkatz, real elsewhere
            # `gls` is used on drkatz, walt, chandra($cat_solaris)...
            if [ -x /pkgs/gnu/bin/ls ]; then
                alias ls='/pkgs/gnu/bin/ls  --color=auto'
            elif [ -x /pkgs/gnu/bin/gls ]; then
                alias ls='/pkgs/gnu/bin/gls --color=auto'
            # This is for Chandra ($cat_solaris)
            elif [ -x /opt/csw/bin/gls ]; then
                alias ls='/opt/csw/bin/gls  --color=auto'
            fi
        esac
    ;;
esac

alias l='ls -CF'          # no `ls-F` in bash
alias ll='ls -l'
alias lh='ls -lh'         # human-readable file sizes
alias la='ls -A'
alias lla='ls -Al'
alias lha='ls -Alh'

# List *only* the dot files
#     excluding . and .. like -A
#     and dropping the directory name from the listing like usual `ls`.
# BUG: can't pass extra flags like you can for the aliases
# BUG: if the directory doesn't exist then `cd` complains instead of `ls`
function l.() {
    if [ "$1" == '' ] ; then d='.' ; else d="$1" ; fi
    ( cd $d && ls -d .[^.]* )
}
function ll.() {
    if [ "$1" == '' ] ; then d='.' ; else d="$1" ; fi
    ( cd $d && ls -dl .[^.]* )
}
function lh.() {
    if [ "$1" == '' ] ; then d='.' ; else d="$1" ; fi
    ( cd $d && ls -dlh .[^.]* )
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ Other basic aliases

alias grep='grep --color'

case "${_localhost}" in
    ereshkigal | miller | banks )
        # OSX lacks the tool, but it has the functionality
        alias ldd='otool -L'
    ;;
    elsamelys | UNKNOWN )
        unalias grep # stupid grep, no color
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
            ;;
        esac
    ;;
    psu)
        case "${_uname}" in
            SunOS)
                [ "${USER}" = 'wren' ] &&
                    alias prolog='sicstus' # for cs.pdx.edu only

                unalias grep # stupid grep, no color
                [ -e /pkgs/gnu/bin/grep ] && # try gnu for color
                    alias grep='/pkgs/gnu/bin/grep --color'
            ;;
        esac
    ;;
esac

# Parse `which` to return whether it found something or not
# (Since normally it returns success either way)
function _exists() { which "$1" 2>&1 | grep ^/ >/dev/null ; }

function whoall() { who -u | awk '{if ($6 != "old") print $0}' | sort ; }

_exists whoami   || alias whoami='who am i' # These are subtly different
_exists whereami || alias whereami='echo $HOSTNAME'
_exists whatis   || alias whatis='man -f'
_exists apropos  || alias apropos='man -k'

alias vi='vim'        # since some places have actual `vi`
alias view='vim -R'   # --"--
alias ex='vim -e'     # --"--
alias nano='nano -iw' # keep indentation on \n, no-wrap lines

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
if [ "${_localhost}" = 'google' ]; then
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

# Safely copy directories
# BUG: dirname doesn't seem to deal with .. right
function tarcp() {
    ( cd `dirname "$1"` && tar cf - `basename "$1"` ) |
        ( cd "$2" && tar xpf - )
 }

# Actually, we can use the seq program for this; which also allows
# setting the lower bound. Dunno if that's available on Debian, but
# it is on Darwin/BSD.
#function enum() { perl -e 'print "$_\n" foreach 1..'"$1" ; }

# Do `time` some number of times and average the results
# TODO: it's better to use Criterion for this
# BUG: Bash has a built-in with this name...
function times() {
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
if [ "${_localhost}" = 'ereshkigal' ]; then
    # Actually this opens in reverse order, but that makes it
    # in order front to back for certain programs
    function open-in-order() {
        local f
        local line
        for f in "$@" ; do echo "$f" ; done | sort -r | xargs open
    }

    # TODO: combine shutdown with some osascript for softer shutdown when possible...
    alias goodnight='sudo shutdown -h +90'

    alias motoko='su motoko'
    alias root="su motoko -c 'sudo su'"

    # This is fairly dumb (e.g., doesn't check for previous agent),
    # but it's smart enough to get by for now
    # TODO: make it smarter
    # TODO: update this stuff to work with `gcert` on google machines
    alias agent="ssh-agent > ~/.ssh/agent ; source ~/.ssh/agent ; ssh-add ~/.ssh/{id_dsa,id_rsa}"

    # Move something to the trash (rather than unlinking)
    function del() { mv "$@" ~/.Trash ; }

    alias cpan="echo 'Make sure FTP is not blocked by firewall'; su motoko -c '/sw/bin/perl -MCPAN -e shell'"

    # Use screen saver for desktop "image"
    alias ssbg='echo "Hit ^C to quit"; /System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine -background'

    # (iTerm only) Send a Growl notification
    # <http://aming-blog.blogspot.com/2011/01/growl-notification-from-iterm-2.html>
    function growl() { echo -e $'\e]9;'"$@"'\007' ; }
fi

# Remove .DS_Store items in this folder and subfolders
# TODO: should we use the -delete flag insted of -exec?
alias rm-ds-store='find . -name .DS_Store -exec rm {} \;'

# Get seconds since epoch (:= sse)
alias perltime='perl -e'\''print time, "\n"'\'

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
# ~~~~~ Assorted Bash prefs. See bash(1) for more options.

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Don't put duplicate lines in the history
export HISTCONTROL=ignoredups

# Colon-seperated patterns to not store in histfile
export HISTIGNORE='ls:ll:lh:la:lla:lha:l.:ll.:lh.:l:cl:cll:q:x:cd:ghci'

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

# from Marc Liyanage, http://www.entropy.ch:16080/software/macosx/docs/customization/
# tcsh method for the curious
#setenv SHORTHOST `echo -n $HOST | sed -e 's%\..*%%'`
#alias precmd 'printf "\033]0;%s @ $SHORTHOST\007" "${cwd}" | sed -e "s%$HOME%~%"'
#sched +0:00 alias postcmd='printf "\033]0;%s @ $SHORTHOST\007" "\!#"'


# limit namespace polution
unset _localhost _uname _hostname

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~ END                                            END ~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
