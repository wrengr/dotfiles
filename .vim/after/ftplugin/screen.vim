" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/screen.vim    ~ 2021.10.16
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Override the formatoptions (and hard-wrapping) that the builtin
" /usr/share/vim/vim81/ftplugin/screen.vim forces upon us.
" TODO: should undo this in b:undo_ftplugin
call wrengr#utils#DisableHardWrapping()
