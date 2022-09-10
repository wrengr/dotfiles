" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/gitconfig.vim ~ 2021.10.16
"
" For ~/.gitconfig and a few other things detected as the same.
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

let b:undo_ftplugin =
  \ (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '')
  \ . 'setlocal '
  \ . (&expandtab ? '' : 'no') . 'expandtab '

setlocal expandtab
