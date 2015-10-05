# ~/.bash_logout: executed by bash(1) when login shell exits.

# when leaving the console clear the screen to increase privacy
if [ "$SHLVL" = 1 ]; then
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi

# Kill ssh-agent before we forget who it is
# unless shell is non-interactive?   [ -z "$PS1" ] ||
#if [ "X$SSH_AGENT_PID" != X ]; then
#	ssh-agent -k
#fi
