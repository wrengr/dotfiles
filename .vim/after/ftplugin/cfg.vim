" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/cfg.vim       ~ 2021.09.24
"
" This is what ~/.hgrc gets detected as, with the remark:
"   "because looks like generic config file"
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Override the &fo=cro that the builtin forces upon us.
call wrengr#utils#DisableHardWrapping()
