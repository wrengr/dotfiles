" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/vim.vim       ~ 2021.10.03
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Override the hard-wrapping that the builtin
" /usr/share/vim/vim73/ftplugin/vim.vim forces upon us.
call wrengr#utils#DisableHardWrapping()

" Disable folding in the special cmdwin and optwin windows.
" (See `:h *cmdwin*` and `:h *optwin*` for more details.)
" On the one hand, folding makes no sense for these; on the other
" hand, malformed commands would cause to fold through to EOB/EOF.
" Of course, folding can be tivially re-enabled via various fold operators.
" HT: <https://vim.fandom.com/wiki/Syntax_folding_of_Vim_scripts>
if bufname('') =~# '^\%(' . (v:version < 702 ? 'command-line' : '\[Command Line\]') . '\|option-window\)$'
  setlocal nofoldenable
endif
