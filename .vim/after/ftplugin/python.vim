" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/python.vim    ~ 2021.08.19
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" TODO: install <https://github.com/hynek/vim-python-pep8-indent/> ?
" TODO: install <https://github.com/nvie/vim-flake8> ?
"
" Force things to be Chromium style, rather than PEP8 style.
"
" N.B., when giving multiple commands to :au and using continuation
" lines, you need to either separate the commands with <bar>, or avoid
" any space after the line-leading backslash.  (It's also preferred
" to use a single :set command and pass all the options at once; but
" that just seems to be for stylistic/performance concerns.)
" <http://stackoverflow.com/a/36742908>
" TODO: do we still need this?
autocmd BufNewFile,BufRead *.py
	\setlocal smartindent |
	\setlocal cinwords=if,elif,else,for,while,try,except,finally,def,class

set tabstop=2
set softtabstop=0
set shiftwidth=2
set textwidth=79
set expandtab
set autoindent
set fileformat=unix
