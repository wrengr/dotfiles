~wren
=====

In the sharing spirit of \*nix, here are a bunch of my dotfiles, a
few random scripts, and other odds and ends. Compared to my old
darcs repo for sharing this stuff, I've removed a bunch of the
[catzen](http://www.cat.pdx.edu/thecat.html) stuff and the old Perl
stuff; both of them because I no longer use them and so they're
probably bitrotten.

## Quick summary of scripts in `~/local/bin`

### Quality-of-life for Bash

* `_abspath` — Make a path absolute and canonical.
* `_normalize_space` — Remove leading/trailing spaces and collapse duplicate space.
* `_shell_quote` — Single-quote a string, escaping characters as necessary.
* `cal` — Like the built-in cal, but highlights today.
* `legate` — Wrapper/enhancement of `ssh-agent`.
* `ls_all` — Recursively `ls` every directory along a path.
* `psed` — Run a program's output through several sed filters, returning the same exit code as the child program.
    * TODO: rename this not to shadow the Perl Stream Editor (which ships with XCode)

### File munging

* `accumulate` — Combine (key,value) lines into (key, list of values) lines.  \[[Forked](http://blog.plover.com/prog/accumulate.html)\]
* `byte-sort` — Sort lines beginning with human-readable bytesizes.
* `cloc-1.53.pl` — Count lines of code.  \[[Copied](http://cloc.sourceforge.net)\]
* `compressibility` — Show how much space gzip/bz2 can save.  \[[Copied](https://github.com/garybernhardt/dotfiles)\]
* `dotsort` — Sort hostnames in the correct way.
* `find-duplicates` — A wrapper around `accumulate` to use `md5sum`.
* `hilight` — Highlight matches; à la color grep, but without removing non-matching lines.
* `literacy` — Grep for literate-programming content.

### Git subcommands

* `git-bb` — Enhanced version of `git branch -vv`.
* `git-parent` — Figure out the parent of a git branch.
* `git-reparent` — Try to rebase the current branch onto a new parent.

### Misc utilities (actively used)

* `darcs-newfiles` — Determine which files aren't under darcs control. (like `darcs w -ls` but can be much faster)
* `showrgb-color.pl` — Colorized version of `showrgb`.
* `w3ctime` — Print the current time in [W3C date/time format](http://www.w3.org/TR/NOTE-datetime).

### Misc utilities (maybe bitrotten)

* `http-head` — Get the HTTP header for a URL.
* `kill_dhcp` — kill DHCP leases on OSX 10.5
* `link_scrape` — Get all same-domain URLs from a webpage.
* `propagate` — Push a bunch of files to a bunch of hosts, recursively as needed.

## Email

I don't really use [Mutt](http://www.mutt.org) very much anymore,
and I never really got super into it, but it's here in case I ever
come back to it.


## Text Editing

### Vim

This is my primary text editor, but I'm far from being a guru with
it. If you have any suggestions on improving things, feel free to
send me a message.

### Emacs

I'm not an emacs person at all. I only ever really use it for Coq,
Isabelle, and Agda; since emacs is the only decent way to interact
with those languages. So take all this with a grain of salt.
