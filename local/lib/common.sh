#!/bin/sh
# Common variables and routines for gmake-like program monitoring
# wren ng thornton <wren@cpan.org>                  ~ 2006.08.18
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#[ -z "$_home" ] && _home="~" # so we can use non-tilde if necessary
#_bin="$_home/local/bin"      # path to scripts
#_files="$_home/local/var"    # path to support files for scripts
#_etc="$_home/local/etc"      # path to config files for scripts

_quiet=0                     # (0) verbose, (1) quiet, (2) silent
_dryrun=0                    # (0) real, (1) dry run
_color=1                     # (0) mono, (1) color

_pre=""                      # string to prepend to standard output
_pre_err="*"                 # additional prepend for warnings, etc
_pre_fatal=" Fatal Error:"   # additional prepend for fatal errors


_echo() {
	if [ "$_quiet" -eq 0 ]; then
		if [ "X$_pre" = "X" ]; then
			echo "$_pre$*"
		else 
			if [ "$_color" -eq 1 ]; then
				printf "\e[01;34m$_pre\e[00m $*\n"
			else
				echo "$_pre $*"
			fi
		fi
	fi
}

_do() { [ "$_dryrun" -ne 1 ] && $* ; }

_edo() { _echo $*; _do $* ; }

_warn() {
	if [ "$_quiet" -lt 2 ]; then
		if [ "$_color" -eq 1 ]; then
			printf "\e[01;31m$_pre$_pre_err\e[00m $*\n"
		else
			echo "$_pre$_pre_err $*"
		fi
	fi
}

_die() {
	_quiet=0 # so the warning shows up
	_pre_err="$_pre_err$_pre_fatal"
	local _err="$1"
	shift
	_warn "$*"
	exit $_err
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
