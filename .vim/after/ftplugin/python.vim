" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/python.vim    ~ 2021.08.19
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" TODO: install <https://github.com/hynek/vim-python-pep8-indent/> ?
" TODO: install <https://github.com/nvie/vim-flake8> ?
"
" Force things to be Chromium style, rather than PEP8 style.
"
" N.B., in order to use the leading backslash notation with
" multiple commands, you need to also use a trailing pipe,
" or you need to avoid any space after the backslash.
" <http://stackoverflow.com/a/36742908>
" TODO: do we still need this?
autocmd BufNewFile,BufRead *.py
	\setlocal smartindent
	\setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class

set tabstop=2
set softtabstop=0
set shiftwidth=2
set textwidth=79
set expandtab
set autoindent
set fileformat=unix
