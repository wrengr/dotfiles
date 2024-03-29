" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/make.vim      ~ 2021.10.16
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" I'm just going to assume we need this here too...
" TODO: should also undo this in b:undo_ftplugin
call wrengr#utils#DisableHardWrapping()

let b:undo_ftplugin =
  \ (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '')
  \ . 'setlocal '
  \ . (&expandtab ? '' : 'no') . 'expandtab '
  \ . 'shiftwidth=' . &shiftwidth
  \ . 'softtabstop=' . &softtabstop

" The noexpandtab is the most important bit here.
setlocal noexpandtab shiftwidth=8 softtabstop=0
