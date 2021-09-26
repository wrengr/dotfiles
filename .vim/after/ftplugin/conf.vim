" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/conf.vim      ~ 2021.09.25
"
" This is what a bunch of random dotfiles get detected as.  The
" rule that does it just looks for any of the first five lines
" beginning with a hash; assuming it hadn't already been detected
" as something else by that point.
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Override the &fo=cro that the builtin forces upon us.
call wrengr#utils#DisableHardWrapping()
