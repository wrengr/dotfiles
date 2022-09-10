" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/changelog.vim ~ 2021.10.16
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" This may not be needed, but just to be sure.
" TODO: should also undo this in b:undo_ftplugin
call wrengr#utils#DisableHardWrapping()

" I don't like using the `<` syntax cuz that'll revert to Vim's
" default rather than to whatever was there before (which may be
" non-default!)
let b:undo_ftplugin =
  \ (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '')
  \ . 'setlocal '
  \ . (&expandtab ? '' : 'no') . 'expandtab '

setlocal expandtab
