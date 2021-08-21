# This file is designed to be sourced not run.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Modified from SEEKRIT
# wren gayle romano <wrengr@google.com>             ~ 2021.08.10
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Cf., style notes in my ~/.bash_profile for why I've made certain changes.
# Also, I've fixed the bug in export_screen_client_env re using eval.

screen_server_pid() {
  local pid=$PPID
  while [[ "$pid" -ne 0 ]]; do
    if $(ps u "$pid" | grep -q SCREEN); then
      echo "$pid"
      return
    fi
    pid=$(ps -o ppid= "$pid")
  done
}

screen_client_pts() {
  for pid in /proc/$(screen_server_pid)/fd/* ; do
    local l=$(readlink "$pid")
    if [[ "$l" =~ pts ]]; then
      echo "$l" | cut -d / -f 3-
      return
    fi
  done
}

screen_client_pid() {
  ps a | grep screen | grep "$(screen_client_pts) " | awk '{print $1}'
}

export_screen_client_env() {
  local screen_client_env="/proc/$(screen_client_pid)/environ"
  local value=$(tr '\0' '\n' < "$screen_client_env" | awk -F= "/^$1=/ {print \$2}")
  # I've fixed the bugs re the original implementation of the next line.
  # As always, using eval entails a security risk; however, it does seem
  # to remain the most portable thing.
  eval "export $1=\${value@Q}"
  # For why this particular syntax:
  # (1) To be officially correct, eval must only be passed a single
  #     argument; thus the `export` needs to remain inside the quoted string.
  #     <https://stackoverflow.com/a/9938751>
  # (2) The best way to avoid bugs and security issues is to avoid letting
  #     the initial input parsing expand $value.  Since eval executes things
  #     in the same context as its own context, that means the local variable
  #     will be in scope, so we can just let the eval itself do the expansion.
  #     <https://stackoverflow.com/a/48590164>
  # (3) Per POSIX 2018 the right hand side of variable assignment does
  #     not require quotes.  <https://stackoverflow.com/a/9938751>
  # (4) However, since one can seldom rely on things to be POSIX-ly
  #     correct, we use parameter transformation to have $value expanded
  #     to a shell-quoted version.  <https://stackoverflow.com/a/51598268>
  #
  # If for some reason the above isn't enough to ensure both correctness
  # and portability, then we could avoid using eval at all by instead using:
  # (1) `declare -n` <https://stackoverflow.com/a/11460242>, or
  # (2) `printf -v` <https://stackoverflow.com/a/16973754>
  # See also <https://askubuntu.com/a/930104>

  #echo "DEBUG: exported $1=${!1}"
}

fixup_screen_client_env() {
  export_screen_client_env DISPLAY
  export_screen_client_env SSH_CLIENT
  export_screen_client_env SSH_AUTH_SOCK
  # If we're using the `scrn` wrapper, then that SSH_AUTH_SOCK will
  # be a symlink in ~/.tmp which points to the real auth sock.  N.B.,
  # if that symlink is broken we can try to use `fixup_ssh_auth_sock`
  # to automatically guess where the real auth sock is, and then use
  # `fixup_scrn_sock` to repair the symlink; however that's not guaranteed
  # to work correctly, for exactly the same reasons the `scrn` wrapper
  # was created in the first place.
  export_screen_client_env SSH_CONNECTION
  export_screen_client_env SSH_TTY
}

print_screen_client_env() {
  for v in DISPLAY SSH_CLIENT SSH_AUTH_SOCK SSH_CONNECTION SSH_TTY; do
    echo "$v=${!v}"
  done
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# The content below was copied from `scrn` itself (2021.08.10).
# Albeit I've done some reorganization, renaming, and cleaned up the style.

# This function is for internal use only, to DRY; alas we can't define
# local functions in Bash.
fixup_scrn_sock__relink() {
  # The *name* of the environment variable
  local env="$1"
  # Value of the environment variable, aka path to the actual socket
  local sock="${!env}"
  # Absolute path to the temporary symlink to $sock
  local link="$2"

  if [[ -z "$sock" ]]; then
    # No auth sock specified in the environment;
    # so remove the symlink, if any.
    rm -f -- "$link"
  elif [[ ! "$sock" -ef "$link" ]]; then
    # Construct expected symlink to point to auth sock.
    ln -snf -- "$sock" "$link"
    # And adjust the environment to point to the symlink.
    eval "export $env=\${link@Q}"
  fi
}

# This function is designed to be called from within screen (unlike the
# `scrn` wrapper itself, which requires being run from outside of screen).
fixup_scrn_sock() {
  # BUG: Why is this being returning true when I do in fact have STY set?
  #if [[ ! -z "$STY" ]]; then
  #  >&2 echo 'fixup_scrn_sock: Not in a screen session; Giving up.'
  #  return 1
  #fi
  #
  # The screen session name.
  # TODO: we have the env STY=$n.$s where $n is a number acreeing with
  # the socket "/tmp/ssh-*/agent.$n"; so we can/should be able to parse
  # $s from $STY rather than requiring an argument.
  local s="$1"
  # Tempdir where symlinks are stored.
  local d="$HOME/.tmp"
  # Create tempdir if it doesn't exist.
  [[ -d "$d" ]] || mkdir -m 700 "$d"
  # Relink both auth socks
  fixup_scrn_sock__relink SSH_AUTH_SOCK     "$d/$s.$USER.ssh_auth_sock"
  fixup_scrn_sock__relink FWD_SSH_AUTH_SOCK "$d/$s.$USER.fwd_ssh_auth_sock"
}
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
