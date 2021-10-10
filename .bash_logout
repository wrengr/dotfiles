# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Shutdown for login shells (always interactive, unless weird)
# wren gayle romano                                 ~ 2021.08.25
#
# This file should be sourced (or symlinked) by ~/.bash_logout,
# which is sourced: (a) whenever an interactive login shell exits,
# or (b) whenever a noninteractive `--login` shell is terminated
# via the `exit` builtin.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# When leaving the console clear the screen to increase privacy.
# (N.B., the Bash builtin `[[]]` will propery handle both `-eq` and
# `=` in the event the $SHLVL variable is unset or empty, whether
# quoted or not, and whether the first or second argument.  Conversely
# if using the `[]` program then various of those situations will
# lead to a syntax error instead.)
if [[ "$SHLVL" -eq 1 ]]; then
    # IIRC, this is a Solaris thing.  It certainly doesn't exist
    # in OSX at least.
    [[ -x /usr/bin/clear_console ]] && /usr/bin/clear_console -q
fi


# TODO: older versions of this file had some commented out code to
# `ssh-agent -k`, but I'm pretty sure that predates my ~/local/bin/legate
# script (and its precursors).

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
