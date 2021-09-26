" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/help.vim      ~ 2021.09.26
"
" This is for Vim's help files.
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" BUG: these leave the window open when the other window is Startify.
nnoremap <buffer> q :<C-u>bd<CR>
nnoremap <buffer> Q :<C-u>bd<CR>

" BUG: We should set b:undo_ftplugin to undo everything we changed.
