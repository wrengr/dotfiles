~wren
=====

In the sharing spirit of \*nix, here are a bunch of my dotfiles, a
few random scripts, and other odds and ends. Compared to my old
darcs repo for sharing this stuff, I've removed a bunch of the
[catzen](http://www.cat.pdx.edu/thecat.html) stuff and the old Perl
stuff; both of them because I no longer use them and so they're
probably bitrotten.

## Shell scripting

Here's a quick synopsis of the scripts in `~/local/bin`:

* `_abspath` — make a path absolute and canonical
* `_normalize_space` — remove leading/trailing spaces and collapse duplicate space
* `_shell_quote` — single-quote a string, escaping characters as necessary
* `byte-sort` — sort lines beginning with human-readable bytesizes
* `cal` — like the built-in cal, but highlights today
* `darcs-newfiles` — determine which files aren't under darcs control. (like `darcs w -ls` but can be much faster)
* `dotsort` — sort hostnames in the correct way
* `hilight` — highlight matches; à la color grep, but without filtering out non-matching lines
* `http-head`
* `link_scrape`
* `literacy`
* `ls_all` — recursively `ls` every directory along a path
* `propagate` — push a bunch of files to a bunch of hosts, recursively as needed
* `psed` — run a program's output through several sed filters, returning the same exit code as the child program
* `w3ctime` — print the current time in [W3C date/time format](http://www.w3.org/TR/NOTE-datetime)

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
