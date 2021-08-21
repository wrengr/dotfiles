# This file is designed to be sourced not run.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Modified from SEEKRIT
# wren gayle romano <wrengr@google.com>             ~ 2021.08.10
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Cf., style notes in my ~/.bash_profile for why I've made certain changes.

fixup_ssh_auth_sock() {
  # TODO: I've had issues with -n not working corectly before, so can
  # we really trust it here or should we use !-z or one of the other things?
  if [[ -n "$SSH_AUTH_SOCK" ]] && [[ ! -e "$SSH_AUTH_SOCK" ]]; then
    ## This is the original zsh script. That stuff after the second
    ## glob is a zsh glob qualifier:
    ## <https://zsh.sourceforge.io/Doc/Release/Expansion.html#Glob-Qualifiers>
    ##   =   is a socket
    ##   U   is owned by EUID
    ##   N   sets the NULL_GLOB option for the current pattern
    ##       <https://zsh.sourceforge.io/Doc/Release/Options.html#index-NULLGLOB>
    ##   om  sort by last-modified time (youngest first)
    ##   [1] only return the first match
    #local new_sock=$(echo /tmp/ssh-*/agent.*(=UNom[1]))
    #if [[ -n ${new_sock} ]]; then
    #    export SSH_AUTH_SOCK=${new_sock}
    #fi
    ## But I'm not using zsh yet, so we have to do all that manually...

    # TODO: we should prolly unset SSH_AUTH_SOCK since it's now known to be bad...
    # HACK: using `ls -t` probably isn't the most portable way to
    #   sort by modification-time.  Using `find` might be a bit
    #   more portable...
    # Re how to safely/correctly read all the line into a local
    # variable (without starting a subshell):
    # <https://www.baeldung.com/linux/reading-output-into-array>
    readarray -t glob_matches < <(ls -1 -t /tmp/ssh-*/agent.*)
    # N.B., if we were to pipe the output directly into a `while
    # read f`, that would create a subshell; which means (a) that the
    # `return` would only break us out of the loop/subshell (setting
    # the exit code for the loop/subshell), instead of out of the
    # function itself, and (b) because it's a subshell the `export`
    # would to nothing for us / our caller.
    # Conversely, using a `for` loop does not start a subshell.
    # Cf., <https://unix.stackexchange.com/a/213112>
    for f in "${glob_matches[@]}" ; do
      [[ -e "$f" ]] || continue # guard against non-expanded globs
      [[ -S "$f" ]] || continue # assert is a socket
      local owner_id=$(stat --format='%u' "$f")
      [[ "$owner_id" -eq "$EUID" ]] || continue
      # Immediately take the first good result.
      export SSH_AUTH_SOCK="$f"
      return 0
    done
    # A~la NULL_GLOB plus [[ -n ]], if we haven't found any matches
    # then simply return without doing anything, rather than throwing
    # an error.
    #
    # BUG: this seems to properly set the error code re being used
    #   in Bash conditionals, however it's not really setting the exit
    #   code re getting shown in my prompt; what gives?
    # TODO: cf <https://stackoverflow.com/a/67339783>
    return 1
  fi
}
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
