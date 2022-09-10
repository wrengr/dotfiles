#!/usr/bin/osascript
-- HT: <https://superuser.com/a/67468>
-- BUG: While this works (mostly), it's slow as dirt.  Given what
-- it's doing, I don't expect that compiling the script would make
-- much difference.
-- We might be able to speed things up a bit by using foreach loops (i.e. "repeat with _ in _"); e.g., as in <http://hea-www.harvard.edu/~fine/OSX/safari-tabs.html>
-- Also see <http://hints.macworld.com/article.php?story=20100803094600903>, in particular their "set URL of _currentTab to _somestring", "make new tab at (end of front window)",
-- May also be something useful to be had in <https://stackoverflow.com/questions/7277448/download-a-file-through-safari-with-applescript>

on run _argv
  try
    tell application "Safari" to activate
    repeat with _i from 1 to length of _argv
      -- Copy URL to clipboard
      tell application "Safari" to set the clipboard to item _i of _argv
      -- Tell Safari to open a new tab, paste the URL, and "hit" Return
      tell application "System Events"
        tell process "Safari"
          tell menu bar 1 to click menu item "New Tab" of menu "File" of menu bar item "File"
          tell menu bar 1 to click menu item "Open Location…" of menu "File" of menu bar item "File"
          -- BUG: this ends up passing things to the default search
          -- engine, rather than opening it as a url per se.
          tell menu bar 1 to click menu item "Paste" of menu "Edit" of menu bar item "Edit"
          key code 36
        end tell
      end tell
    end repeat
  end try
end run
