" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/vim.vim       ~ 2021.08.19
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Override the hard-wrapping that the builtin
" /usr/share/vim/vim73/ftplugin/vim.vim forces upon us.
DisableHardWrapping
" Since the above only removes 'c' (for now)
set formatoptions-=r
set formatoptions-=o
