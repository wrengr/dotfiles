# This is a trivial bash non-login script          ~ 2008.07.29

# Uncomment the next line just to be sure
# i.e. if you're paronoid or bootstrapping the catacombs
#PATH="$PATH:/usr/bin:/usr/sbin:/bin:/sbin"

# Work on ensuring promiscuity even for non-login shells
umask 0022

# N.B. if this produces output, non-login shells will die
# this includes `scp`, `rsync`, etc
if [ -r ~/.bash_profile ] ; then source ~/.bash_profile ; fi
