#!/bin/sh
# This script is still WIP (2024-02-05)

# TODO: Pretty sure this won't work, since passing the key names
# to `default read` throws an error about "the domain/default doesn't
# exist". Most of these are nested under 'New Bookmarks', but I'm not
# sure how to do a nested path...
#
# For *interactive* munging of plist files, you might consider using
# the built-in `PlistBuddy` instead
# <https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man8/PlistBuddy.8.html>
alias WRITE="defaults write com.googlecode.iterm2"

# TODO: any others I need to patch up repeatedly?
# <https://alex.pearwin.com/2014/05/italics-in-iterm2-vim-tmux/>
WRITE 'Close Sessions On End'   1
WRITE 'Prompt Before Closing 2' 0
WRITE Rows                      48
WRITE columns                   100
WRITE 'Non Ascii Font'          'Monaco 15'
WRITE 'Non-ASCII Anti Aliased'  1
WRITE 'Normal Font'             'Monaco 15'
