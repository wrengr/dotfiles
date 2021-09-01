" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/haskell.vim   ~ 2021.09.01
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" N.B., much of this file is defending against the truly vile builtin
" ftplugin for Haskell. Now that we've switched to using something else,
" not all of it is relevant anymore.


" ~~~~~ Step 1: get &formatoptions back into a sane state.
" Disabling the "c" feature of &formatoptions used to be enough to
" keep from adding extra indentation every time we add a new comment
" line (whether by <Enter> in input mode, or by <o>/<O> in normal mode);
" but at some point removing "c" no longer helped fix that...
"
" Apparently, this particular bug is well-known and affects other folks
" too: <https://stackoverflow.com/q/10663888>. I should really just rip
" the old Haskell indentation file out and use something more modern. (Or
" if worst comes to worst, try and write my own.)
DisableHardWrapping


" ~~~~~ Step 2: Disable the builtin ftplugin's style for three-part comments.
" N.B., probably irrelevant to other plugins. Hence commented out for now.
"setlocal comments&
"setlocal comments=:--
" TODO: See also <https://github.com/neovimhaskell/haskell-vim/blob/master/after/ftplugin/haskell.vim>
"setlocal comments=b:--,sn:{-,m:,e:-}


" ~~~~~ Step 3: Adjust highlighting for raichoo's plugin

" Disable raichoo's opinionated highlighting, and go back to "classic".
"let g:haskell_classic_highlighting = 1

" Enable highlighting of some additional keywords.
let g:haskell_enable_quantification = 1   " highlight `forall`
let g:haskell_enable_recursivedo = 1      " highlight `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " highlight `proc`
let g:haskell_enable_pattern_synonyms = 1 " highlight `pattern`
let g:haskell_enable_typeroles = 1        " highlight type roles
let g:haskell_enable_static_pointers = 1  " highlight `static`
"let g:haskell_backpack = 1               " highlight backpack keywords
"let g:haskell_disable_TH = 1             " disable TH/QQ highlighting


" ~~~~~ Step 4: Adjust indentation rules.
" The default settings for g:haskell_indent_if and g:haskell_indent_case
" are particularly onerous. Moreover, those variable names (at least)
" are shared by the builtin thing and raichoo's plugin. I'm guessing
" that's intentional?

" Turn indentation off entirely.
" Good god, can nobody do indentation in a sensible way?!
let g:haskell_indent_disable = 1

let g:haskell_indent_if = 0                " `then`/`else` keywords
let g:haskell_indent_case = 0              " pattern branches
"let g:haskell_indent_case_alternative = 1 " a la Epigram style
let g:haskell_indent_guard = 4             " guard branches
let g:haskell_indent_let = 0               " body after `in` (when trailing above)
let g:haskell_indent_where = 6             " lines after `where`+line
let g:haskell_indent_before_where = 4      " the `where` keyword itself
let g:haskell_indent_after_bare_where = 0  " lines after `where` (on its own)
let g:haskell_indent_do = 3                " lines after `do`+line
let g:haskell_indent_in = 0                " `in` keyword itself

let g:cabal_indent_section = 4
