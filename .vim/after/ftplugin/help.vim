" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/help.vim      ~ 2021.10.16
"
" This is for Vim's help files.
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" BUG: these leave the window open when the other window is Startify.
nnoremap <buffer> q :<C-u>bd<CR>
nnoremap <buffer> Q :<C-u>bd<CR>

let b:undo_ftplugin =
  \ (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '')
  \ . 'silent! nunmap <buffer> q '
  \ . '| silent! nunmap <buffer> Q '
