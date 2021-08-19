" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/screen.vim    ~ 2021.08.19
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Override the formatoptions (and hard-wrapping) that the builtin
" /usr/share/vim/vim81/ftplugin/screen.vim forces upon us.
DisableHardWrapping
" Since the above only removes 'c' (for now)
set formatoptions-=r
set formatoptions-=o
