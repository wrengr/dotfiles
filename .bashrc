# This is a trivial bash non-login script          ~ 2008.07.29

# Work on ensuring promiscuity even for non-login shells
umask 0022

# N.B. if this produces output, non-login shells will die
# this includes `scp`, `rsync`, etc
[ -r ~/.bash_profile ] && source ~/.bash_profile
