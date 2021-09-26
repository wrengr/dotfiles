" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/python.vim    ~ 2021.09.02
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" TODO: install <https://github.com/hynek/vim-python-pep8-indent/> ?
" TODO: install <https://github.com/nvie/vim-flake8> ?
"
" Force things to be Chromium style, rather than PEP8 style.
"
" This comment is now obsolete, but we're keeping it here until it finds a better home:
" N.B., when giving multiple commands to :au and using continuation
" lines, you need to either separate the commands with <bar>, or avoid
" any space after the line-leading backslash.  (It's also preferred
" to use a single :set command and pass all the options at once; but
" that just seems to be for stylistic/performance concerns.)
" <http://stackoverflow.com/a/36742908>
setlocal
    \ tabstop=2
    \ softtabstop=0
    \ shiftwidth=2
    \ textwidth=79
    \ expandtab
    \ autoindent
    \ smartindent
    \ cinwords=if,elif,else,for,while,try,except,finally,def,class
    \ fileformat=unix
" BUG: We should set b:undo_ftplugin to undo everything we changed.
