#!/usr/bin/osascript -s o
-- Print the urls of all open tabs, one per line, for easily saving to a file.
-- N.B., due to AppleScript bugginess this prints to stderr not stdout!
-- BUG: according to the manpage the "-s o" flag to osascript will tell it to "log" to stdout instead of the default stderr ("-s e"); however, that's not actually happening.
--
-- Inspired by <http://hea-www.harvard.edu/~fine/OSX/safari-tabs.html>
--
-- For more hints about stuff, cf <https://scriptingosx.com/2020/09/avoiding-applescript-security-and-privacy-requests/>

(*
-- Re-open stdout:
-- HT: <https://groups.google.com/g/alt.comp.lang.applescript/c/1v0s0Tkn1bM?pli=1>
-- BUG: this doesn't work afterall:
--     execution error: File file Macintosh HD:dev:fd:1 wasn’t found. (-43)
set _u to "/dev/fd/1"
set _p to POSIX file _u
open for access _p with write permission
copy result to stdout
*)

tell application "Safari"
  repeat with _win in (every window)
    -- TODO: the original source work wrapped getting (every tab of _win)
    -- with a try block, so as to print out any errors along the
    -- way.  Maybe we should add that back in?
    repeat with _tab in (every tab of _win)
      set _url to URL of _tab
      -- Sometimes this comes up; I'm guessing for tabs that're empty?
      if _url = missing value then
        -- TODO: some kind of error message? or just ignore?
      else
        -- N.B., you need the "as string" otherwise it'll just list
        -- the AppleScript name: "URL of tab $N of window id $M"
        --
        -- BUG: "log" actually prints things to stderr not stdout!!
        log _url as string
        -- We can use "copy ... to stdout" but that's copy-assignment,
        -- so it'll only keep the last value.  (This was suggested in
        -- <https://stackoverflow.com/questions/15605288/print-to-stdout-with-applescript>.)
        --
        -- If we could get that stdout thing to work, then we could just:
        -- > write (_url as string) to stdout
        --
        -- Alas, looks like there's no option for stdout except to
        -- build up a whole monolithic string in memory first.
      end if
    end repeat
  end repeat
end tell
