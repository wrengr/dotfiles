#!/bin/sh

LHS2TEX_FLAGS="-v --poly"
LATEXMK_FLAGS="$1"
# BUG: test to verify that $1 is a flag and $2 exists!!!
DIR="`dirname "$2"`"
BASE="`basename "$2" .tex`"

# TODO: incorporate chktex, either here or in ~/.latexmkrc
# <https://snim2.wordpress.com/2014/08/07/new-features-i-would-love-to-see-in-writelatex/>

cd "$DIR" || exit 1

if [ -e "$BASE.lhs" ]; then
	lhs2TeX $LHS2TEX_FLAGS "$BASE.lhs" -o ".$BASE.tex" || exit 2
elif [ ! -e ".$BASE.tex" ]; then
	ln -s "$BASE.tex" ".$BASE.tex" || exit 3
fi

if [ "$LATEXMK_FLAGS" = "-c" ]; then
	latexmk -c ".$BASE.tex" || exit 5
elif [ "$LATEXMK_FLAGS" = "-C" ]; then # TODO: also handle the obsolete -CA
	latexmk -C ".$BASE.tex" || exit 5
	rm -f ".$BASE.tex" "$BASE.pdf" missfont.log || exit 6
else
	rm -f "$BASE.pdf"                   || exit 4
	latexmk $LATEXMK_FLAGS ".$BASE.tex" || exit 5
	if [ -e ".$BASE.pdf" ]; then
		ln -f ".$BASE.pdf" "$BASE.pdf"  || exit 6
	fi
fi
