" I don't fully understand what the vim-default ftplugin does, but I do
" know I dislike a bunch of it...

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

" ~~~~~ Step 2: Disable their style of three-part comments.
" TODO: Should we inclode our own thing for block comments? The three-part
" thing is gross, but the proper nested two-part thing should be okay...
setlocal comments&
setlocal comments=:--
" TODO: something like this?
" See also <https://github.com/neovimhaskell/haskell-vim/blob/master/after/ftplugin/haskell.vim>
"setlocal comments=b:--,sn:{-,m:,e:-}

" ~~~~~ Step 3: Stop adding extra indentation for lines following if/case.
let g:haskell_indent_if = 0
let g:haskell_indent_case = 0
