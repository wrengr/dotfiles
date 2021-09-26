" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/make.vim      ~ 2021.09.11
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" I'm just going to assume we need this here too...
call wrengr#utils#DisableHardWrapping()

" The noexpandtab is the most important bit here.
setlocal noexpandtab shiftwidth=8 softtabstop=0
" BUG: We should set b:undo_ftplugin to undo everything we changed.
