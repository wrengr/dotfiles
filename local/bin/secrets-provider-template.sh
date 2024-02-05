#!/bin/bash
# A secrets-provider for use with <https://github.com/awslabs/git-secrets>
#                                                   ~ 2021.09.17
#
# We do this as a provider (rather than a pattern) so that all these
# secrets aren't listed in the .git/config (!!).  Alas this means we
# must manually keep this file in sync across all repo instances (e.g.,
# across all machines).
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Just in case something blows up.
set -e
# Using an alias just to make thing more explicit what I mean.
_regex() { echo "$@"; }
# Escape regex characters a~la `git secrets --add --literal`
_literal() { sed 's/[\.|$(){}?+*^]/\\&/g' <<< "$@"; }

_literal 'DO_NOT_SUBMIT'

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
