#!/usr/bin/env bash
# Source: <https://apple.stackexchange.com/a/147777>
# N.B., this is designed for OSX.  It won't work as desired on Debian:
# Either because `route` doesn't support the `get` command, or because
# `ifconfig` doesn't use the "status: active" syntax.  We may wish to
# enhance this to try using the various other approaches (`dig`,
# `netstat`, `scutil`,...) mentioned by other answers to that
# stackexchange question.  E.g., this one (though that seems to give
# the local-addr rather than the public-addr):
#
# $> ifconfig $(netstat -nr | awk '{ if ($1 ~/default/) { print $6} }') | awk '{ if ($1 ~/inet/) { print $2} }'
#
# Or this one seems to actually work right (the echo is needed because
# the `wget` doesn't print the newline):
#
# $> wget -qO - http://ipecho.net/plain; echo

dumpIpForInterface() {
  IT=$(ifconfig "$1")
  if [[ "$IT" != *"status: active"* ]]; then
    return
  elif [[ "$IT" != *" broadcast "* ]]; then
    return
  fi
  echo "$IT" | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'
}

main() {
  # snagged from here: https://superuser.com/a/627581/38941
  DEFAULT_ROUTE=$(route -n get 0.0.0.0 2>/dev/null | awk '/interface: / {print $2}')
  if [ -n "$DEFAULT_ROUTE" ]; then
    dumpIpForInterface "$DEFAULT_ROUTE"
  else
    for i in $(ifconfig -s | awk '{print $1}' | awk '{if(NR>1)print}'); do
      if [[ $i != *"vboxnet"* ]]; then
        dumpIpForInterface "$i"
      fi
    done
  fi
}

main
