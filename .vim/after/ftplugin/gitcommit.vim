" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/gitcommit.vim ~ 2021.10.16
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

let b:undo_ftplugin =
  \ (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '')
  \ . 'setlocal '
  \ . (&spell      ? '' : 'no') . 'spell '
  \ . (&cursorline ? '' : 'no') . 'cursorline '
  \ . 'textwidth=' . &textwidth

" Try to enforce correct spelling and short messages.
setlocal spell nocursorline textwidth=72
