" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" This is wren gayle romano's vim config            ~ 2015.09.07
"
" For more guidance, see:
"     http://vim.wikia.com/wiki/Keep_your_vimrc_file_clean
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"
" What do those funny symbols on :set mean?
"     :set foo    " turn foo on
"     :set nofoo  " turn foo off
"     :set invfoo " toggle foo
"     :set foo!   " toggle foo
"     :set foo&   " set foo to its default value
"     :set foo?   " show the value of foo
"
" What do all those variations on :{n,v,}{nore,}map mean?
"     the official story: <http://vimdoc.sourceforge.net/htmldoc/map.html>
"     the full story:     <http://stackoverflow.com/a/11676244>
"     the short version:  <http://stackoverflow.com/a/3776182>
" What does <silent> etc mean on key mappings?
"     <http://vimdoc.sourceforge.net/htmldoc/map.html#:map-arguments>
"
" What do those {&,@,g:,w:,...} prefixes on variables mean?
"     <https://codeyarns.com/2010/11/26/how-to-view-variables-in-vim/>
"     <http://learnvimscriptthehardway.stevelosh.com/chapters/19.html>
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Basic usability
set nocompatible         " Use all the bells and whistles of Vim (not vi)
set backspace=indent,eol,start " Allow backspacing anything (input mode)
"set whichwrap=b,s,<,>,~,[,]   " backspace and cursor keys wrap too
set number               " Show line numbers?
set showmatch            " When inserting a bracket, briefly jump to the match
"set matchtime=5         " how long (N/10 secs) to blink on matching bracket
"set updatetime=4000     " how long (N/10 secs) to highlight matching & save swp if nothing done
set ruler                " Show line and column position of the cursor
set showcmd              " Show command in the last line of the screen


" ~~~~~ Unicode support
" N.B., if the occurence of the utf8 characters below glitches out
" the cursor, then you probably need to adjust your terminal; since
" the terminal and vim are disagreeing about where the cursor
" actually is after printing the characters. (I.e., your terminal
" thinks they are typographically wide, taking up two columns; when
" in fact they should only take up one column.)
if has('multi_byte')
	scriptencoding utf-8
	set encoding=utf-8
	set termencoding=utf-8
	set fileencodings=ucs-bom,utf-8,latin1

	" Use `:set list` to turn these characters on.
	" However, note that doing so will disable linewrap:
	"     <https://groups.google.com/forum/#!topic/comp.editors/blelxLchTPg>
	if v:version >= 700
		set lcs=tab:»\ ,trail:·,eol:¶,extends:→,precedes:←,nbsp:×
	else
		" This line is still giving errors on version 6.2 ...
		set lcs=tab:»\ ,trail:·,eol:¶,extends:>,precedes:<,nbsp:_
	endif
endif
" Show ↪ at the beginning of wrapped lines
" It'd be better if we could get this in the numbering column...
"let &sbr = nr2char(8618).' '


" ~~~~~ History, backups, & stupidity
set history=100          " size of command and search history
"set undolevels=1000
" The following line has some sort of typo about '<' for version 6.2
set viminfo='20,<100,s100,\"100
"           |   |    |    |
"           |   |    |    +-- lines of history (default 50)
"           |   |    +------- Exclude registers larger than N kb
"           |   +------------ Maximum of N lines for registers
"           +---------------- Keep marks for N files
"set confirm             " ask before doing something stupid
set autowrite            " Autosave before commands like next and make
set nobackup             " Make a backup file?
"set patchmode=.orig     " save original file with suffix the first time
"set backupdir=$HOME/.vim/backup " where to put backup files
"set directory=$HOME/.vim/temp   " where to put temp files


" ~~~~~ Syntax highlighting
if has("syntax") && (&t_Co > 2 || has("gui_running"))
	syntax on
	set background=dark  " Optimize the colors to a dark background

	" ~~~~~ <https://github.com/altercation/vim-colors-solarized>
	"       I'm not sure I like this...
	"let g:solarized_termtrans=1
	"let g:solarized_visibility='low' " 'low', 'normal', 'high'
	"let g:solarized_bold=0
	"let g:solarized_italic=0
	"let g:solarized_underline=0
	"colorscheme solarized

	" ~~~~~ <https://github.com/chriskempson/tomorrow-theme>
	" TODO: move this to vim-plug so we don't need a copy in the repo
	colorscheme Tomorrow-Night-Bright
endif

" TODO: do we ever need to set &t_Co to something large, like 256?
" Or can we really trust that it's always the right thing?


" ~~~~~ Show the final column
" TODO: make a function that toggles this, rather than assuming
" always on.
" N.B., if this glitches out when using non-ASCII characters that
" aren't actually wide (typographically speaking), then you probably
" need to adjust your terminal; since the terminal and vim are
" disagreeing about where the cursor actually is.
if exists('+colorcolumn')
	" N.B., this is the column we highlight, hence should be one
	" more than where we want to wrap.
	set colorcolumn=81
	highlight ColorColumn ctermbg=DarkGrey ctermfg=white guibg=DarkGrey guifg=white
else
	" This was suggested by my source for this trick, but dunno if
	" I really want it or not...
	"autocmd! BufEnter <buffer> match ColorColumn /\%81v./

	" Another source <http://stackoverflow.com/a/235970> suggest:
	"highlight OverLength ctermbg=red ctermfg=white guibg=#592929
	"match OverLength /\%81v.\+/
endif
" TODO: even better than any of the above, see
" <http://stackoverflow.com/a/21406581>


" ~~~~~ Spelling
"if v:version > 700
"	set spell           " Highlight spelling errors automatically
"	setlocal spell spelllang=en_us
"	set spellsuggest=10 " Show top N spell suggestions
"	" Change to make spellfile.vim ask you again for downloading file
"	let g:spellfile_URL = 'http://ftp.vim.org/vim/runtime/spell'
"endif


" ~~~~~ Indentation, tabs, whitespace, & linewrapping
"set list                " Show Tabs and spaces and EOL always
set wrap                 " Soft-wrap overly long lines

" Try really hard to turn off hard-wrapping.
"     <http://vim.wikia.com/wiki/Word_wrap_without_line_breaks>
" BUG: none of this seems to do anything whatsoever. For debugging
" purposes, note that &textwidth is getting re-set back to it's
" default of 78 somehow. Also, it only seems to happen when inputting
" lines which are entirely comments (rather than having some code
" in front of them); wtf?
set nolinebreak          " (lbr) Only break lines at characters in &breakat, not in the middle of words
"set breakat=" ^I!@*-+;:,./?" " Note how the default value icludes a space.
set nolist               " Because &list disables &linebreak
    " This behavior of &list is a bug deemed a 'feature'
	" <https://groups.google.com/forum/#!topic/comp.editors/blelxLchTPg>
set textwidth=0 wrapmargin=0 " can't hard-wrap at column zero, ha!
set formatoptions-=t


set autoindent           " Keep indent levels line-to-line
set smartindent          " Tries to indent based on filetype

set shiftwidth=4         " Autoindent N characters (default 2?)
set tabstop=4            " Display a <Tab> as N characters
set softtabstop=4        " Every N positions are treated like one <Tab>
set shiftwidth=4         " Indent N positions by shifting text with </>

"set smarttab            " Insert 'shiftwidth' positions at line begin
                         "     and 'tabstop' elsewhere
"set nosmarttab          " A <Tab> always inserts 'tabstop' positions
"set expandtab           " Always insert positions --- no <Tab>s at all
set noexpandtab          " Real <Tab>s please!
" If you want to convert to/from tabs then do :retab

" Supposedly we can use this to make it so that (shift-)tab in
" visual mode will un/indent the selection. However,
" (1) it doesn't seem to work; besides,
" (2) we never use visual mode, and
" (3) we can already use > and < like we do all the time in normal mode,
"     <http://vimdoc.sourceforge.net/htmldoc/visual.html#visual-operators>
" so why even bother? If we ever do want to start using visual mode, see:
"     <http://usevim.com/2012/05/11/visual/>
" Also, looks like in inser mode we can use <C-d> and <C-t> to un/indent...
"     <http://vim.wikia.com/wiki/Avoid_the_escape_key>
"vmap <Tab> <C-T>
"vmap <S-Tab> <C-D>


" ~~~~~ Wild
"set wildchar=<Tab>      " Expand the command line using tab
"set wildmenu            " Nice tab-completion on the command line
"set wildcharm=<C-Z>     " cf., <http://vim.wikia.com/wiki/Easier_buffer_switching>
"set wildignore+=.o      " Ignore some files in completion
"set wildmode=longest:full,list:full
"             |            |
"             |            +-- List matches, complete first match, use wildmenu
"             +--------------- Complete longest prefix, use wildmenu


" ~~~~~ Searching
set nohlsearch           " Should we highlight searches?
set incsearch            " While typing search command, show matches so far
set ignorecase           " Don't care if search for upper or lowercase
"set magic               " Make regex more easy
"set smartcase           " Only look for case when uppercases are used


" ~~~~~ Bells
"set novisualbell t_vb=  " Don't use the visual bell
"set vb t_vb=            " (what does the vb add to t_vb= ?)
"set novisualbell
"set noerrorbells        " Error bells are annoying


" ~~~~~ Folding
" By default <z><a> is used for un/folding. but that can be annoying if you
" accidentally mistype the <z> and so enter append mode. Should use nnoremap
" to choose some other key combo for un/folding.
"
" For Python, you can get faqncy with something like
" <https://github.com/tmhedberg/SimpylFold>, so you can still see docstrings
" when folded, etc.
"
"set foldenable          " Turn on folding
" This shows the first line of the fold, with "/*", "*/" and "{{{" removed.
"set foldtext=v:folddashes.substitute(getline(v:foldstart),'/\\*\\\|\\*/\\\|{{{\\d\\=','','g')
"set foldmethod=syntax   " Make folding by: syntax, indent,...
"set foldlevel=0         " Autofold (0)just this level, (99)all levels
"set foldlevelstart=0    " Initially close all folds
"set foldminlines=2      " Don't fold lines that are less than
"set foldnestmax=3       " Maximum nesting for foldings
"set foldcolumn=2        " Show N columns for indent of fold
"set foldopen+=insert    " Open folds when action happens
"set foldopen+=jump      " Open folds when action happens
"set foldopen=all        " Open folds when action happens
"set foldclose=all       " Automatically close folds when leving


" ~~~~~ Quick swap between normal and relative line numbers
" <https://github.com/alialliallie/vimfiles/blob/master/vimrc>
" TODO: I like starting the name with "Toggle" for better tab-completion,
" but everyone else puts the "Toggle" at the end of the function name...
function! ToggleNumber()
	if(&relativenumber == 1)
		set norelativenumber
		set number
	else
		set relativenumber
		" Use the new hybrid-mode, if available
		" <http://jeffkreeftmeijer.com/2013/vims-new-hybrid-line-number-mode/>
		if v:version >= 704
			set number
		endif
	endif
endfunc
nnoremap <C-L> :call ToggleNumber()<cr>


" ~~~~~ Quick swap highlight certain spaces as errors
" TODO: actually make this toggle!
" BUG: this doesn't seem to work everywhere (e.g., inside `function!`
" itself; though it works just fine inside `if`)
" TODO: I like starting the name with "Toggle" for better tab-completion,
" but everyone else puts the "Toggle" at the end of the function name...
function! ToggleHighlightSpaces()
	syn match tab display "\t"
	hi link tab Error
	syn match trailingWhite display "[[:space:]]\+$"
	hi link trailingWhite Error
endfunc


" ~~~~~ Etc.
"     http://www.tjansson.dk/filer/vimrc.html
"     http://saulusdotdyndnsdotorg/~david/config/vimrc
"         This one has a whole hell of a lot of stuff!
"     https://github.com/mad-raz/dotvim/blob/master/.vimrc
"     https://github.com/junegunn/dotfiles/blob/8646aae3aec418662d667b36444e771041ad0d23/vimrc#L12-L91
"     http://www.apaulodesign.com/vimrc.html

"set lazyredraw          " Don't redraw while running macros for speed
"set hidden              " Hide buffers when they are abandoned
set title                " Set terminal title to Vim + filename
set ttyfast              " Indicates a fast terminal connection
"set modeline            " Do interpret modelines
"set showmode            " Show what's happening
"set autochdir           " Change directory to the file in the current window
"set nojoinspaces        " No additional spaces when joining lines with <J>
"set esckeys             " Allow cursor keys within insert mode
"set debug=msg,throw     " msg, throw, beep --- combinable
"set report=0            " Always report the number of lines changed
"set display=lastline    " Show as much of the last line as possible
"set noinsertmode        " Don't start in insert mode
"set nofsync             " Less power consumption *DANGEROUS* doesnt sync IO
"set swapsync=           "     this could result in data loss, so beware!
"set mouse=a             " Copy/paste in "* register, normal behaviour with shift key pressed
"set mousehide           " Hide mouse while typing
"set cmdheight=1         " The command bar is 1 high
"set statusline=%F%m%r%h%w\ [%{&ff}\|%Y\|%03.3b\|%04l,%04v\|%p%%\|LEN=%L] "\ %{Tlist_Get_Tag_Prototype_By_Line()}
"set laststatus=2        " Always show the status line
"set formatoptions=1crql " See Help (complex)
"set pastetoggle=<F9>
"set modelines=5         " Search in the first N lines for modes

"set fileformat=unix
"set ttimeout            " Let vim wait for timeouts
"set timeoutlen=3000     " How long does vim wait for mapping sequences
"set ttimeoutlen=100     " How long does vim wait for the end of escape sequence
"set path=$HOME/,.       " Set the basic path (see below)
" TODO: see <http://www.oualline.com/vim/10/top_10.html> for what
" these so-called 'tags' are all about.
"set tags=tags,$HOME/.vim/ctagsproject
"set shell=bash          " A shell
set scrolloff=5          " Show N lines in advance when scrolling
"set sidescrolloff=5     " Lines visible to the left/right of cursor when scrolling
"set winminheight=0      " Let splitted windows get as small as only the titlebar
"set splitright          " When splitting vertically, split to the right
"set splitbelow          " When splitting horizontally, split below
"set browsedir=buffer    " :browse e starts in %:h, not in $PWD
"set grepprg=grep\ -nH\ $*

" Vim Grep
let Grep_Skip_Dirs = 'RCS CVS SCCS .svn .hg _darcs .git'

" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>


" TODO: guard this stuff to be OSX-only?
" <http://www.drbunsen.org/text-triumvirate.html>
" Yank text to the OS X clipboard
noremap <leader>y "*y
noremap <leader>yy "*Y

" Preserve indentation while pasting text from the OS X clipboard
" TODO: this doesn't help for my Ubuntu workstation. Need to make smarter
noremap <leader>p :set paste<CR>:put  *<CR>:set nopaste<CR>


" Switch between buffers ala tabs in Safari (and other OSX)
" This is based off <http://vim.wikia.com/wiki/Easier_buffer_switching>, but
" I'm not entirely sure what the <silent> stuff does...
" BUG: alas this won't work because apparently terminals can't
" distinguish <Tab> and <C-Tab> since terminals think <Tab> is
" identical to <C-i> for legacy reasons. It can only work in gVim...
"     <http://stackoverflow.com/q/1646819/358069>
" And apparently using multiple control keys is unreliable as well :(
"     <http://stackoverflow.com/a/26589192/358069>
"nnoremap <silent> <C-Tab> :bn<CR>
"nnoremap <silent> <C-S-Tab> :bp<CR>
" To switch between vim-tabs, use :tabp and :tabn instead
"
" BUG: none of the <C-w><h/j/k/l> stuff the internet says actually
" works on OSX. The commands to do things directly are ':wincmd h/j/k/l'


" ~~~~~ FileType stuff
if has("autocmd")
	" Enable file type detection
	" Use the default filetype settings. If you also want to
	" load indent files, to automatically do language-dependent
	" indenting, then add 'indent' as well.
	filetype plugin on

	" Allow filebased indentation 
	filetype indent on

	" Makes vim capable of guessing based on the filetype 
	"filetype on

	" http://www.ph.unimelb.edu.au/~ssk/vim/autocmd.html
	" Yes, all my *.pro files ARE prolog files
	autocmd BufNewFile,BufRead *.pro :set ft=prolog
	autocmd BufNewFile,BufRead *.ecl :set ft=prolog

	" TODO: move this all to ~/.vim/ftplugin/python.vim
	" TODO: install <https://github.com/hynek/vim-python-pep8-indent/> ?
	" TODO: install <https://github.com/nvie/vim-flake8> ?
	" Some of these bits are redundant with our general settings, but just to
	" be sure... N.B., Chromium style uses ts=2 in lieu of PEP8's ts=4 !
	"
	" N.B., in order to use the leading backslash notation with
	" multiple commands, you need to also use a trailing pipe,
	" or you need to avoid any space after the backslash.
	" <http://stackoverflow.com/a/36742908>
	autocmd BufNewFile,BufRead *.py
		\setlocal smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
		\setlocal tabstop=2
		\setlocal softtabstop=2
		\setlocal shiftwidth=2
		\setlocal textwidth=79
		\setlocal expandtab
		\setlocal autoindent
		\setlocal fileformat=unix

	" This causes GHC to type check every time you save the file
	"autocmd BufWritePost *.hs !ghc -c %
	" TODO: similar things for *.hsc, *.lhs,... you can use {,} alternation a-la Bash
	" N.B., Haskell-specific things are defined in ~/.vim/ftplugin/haskell.vim

	" TODO: actual support for Agda
	" <http://wiki.portal.chalmers.se/agda/agda.php?n=Main.VIMEditing>
	autocmd BufNewFile,BufRead *.agda :set ft=haskell
endif


" ~~~~~ Macros
" Haskell comment pretty printer (command mode)
" TODO: make this work for indented comments too
" N.B. The trailing newline is necessary for vim to work right
map =hs :.!sed 's/^-- //; s/^/   /' \| fmt \| sed 's/^  /--/'

" JavaDoc comment pretty printer.
" TODO: make this work for indented comments too
map =jd :.,+1!~/.vim/macro_jd.pl

" TODO: similar smarts for Bash/Perl/Python-stule comments
" TODO: can I write a single smart macro that does all of them?


" ~~~~~ Functions
"" Removes all trailing spaces
"" If you want to just do it manually, then type what's between the quotes
"function! RmTrailingSpace()
"	silent! execute ":%s#\s\+$##"
"endfun

" Add type signatures to top-level functions
" From Sebastiaan Visser
"function! HaskellType()
"	w
"	execute "normal {j^YP"
"	execute (".!ghc -XNoMonomorphismRestriction -w % -e \":t " . expand("<cword>") . "\"")
"	redraw!
"endfunction
"
"function Haskell()
"	map <buffer> <silent> tt :call HaskellType()<Cr>
"	" more haskell stuff here
"endfunction
"
"autocmd BufRead,BufNewFile *.{ag,hs,lhs,ghs} call Haskell()
"
"" Compare vs the following Cabal integration hack
"
"function! SetToCabalBuild()
"	if glob("*.cabal") != ''
"		let a = system( 'grep "/\* package .* \*/"  dist/build/autogen/cabal_macros.h' )
"		let b = system( 'sed -e "s/\/\* /-/" -e "s/\*\///"', a )
"		let pkgs = "-hide-all-packages " .  system( 'xargs echo -n', b )
"		let hs = "import Distribution.Dev.Interactive\n"
"		let hs .= "import Data.List\n"
"		let hs .= 'main = withOpts [""] error return >>= putStr . intercalate " "'
"		let opts = system( 'runhaskell', hs )
"		let b:ghc_staticoptions = opts . ' ' . pkgs
"	else
"		let b:ghc_staticoptions = '-XNoMonomorphismRestriction -Wall -fno-warn-name-shadowing'
"	endif
"	execute 'setlocal makeprg=' . g:ghc . '\ ' . escape(b:ghc_staticoptions,' ') .'\ -e\ :q\ %'
"	let b:my_changedtick -=1
"endfunction
"
"autocmd BufEnter *.hs,*.lhs :call SetToCabalBuild()


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ vim-plug stuff <https://github.com/junegunn/vim-plug>

" Autodownload vim-plug itself, if it's not already installed. That
" way we don't need to store a copy in our dotfiles git repo. Of
" course auto-installing opens us up to potential security issues.
" In lieu of auto-installing, we could just store this single file
" in the dotfiles repo (after verifying its trustworthiness), and
" then re-verify it before committing the new version gotten by
" calling :PlugUpgrade. Then again, auto-updating the other plugins
" also poses potential security issues; so how paranoid should we be?
"
" junegunn himself encourages committing plug.vim to dotfiles repos:
" <https://github.com/junegunn/vim-plug/issues/69#issuecomment-54735487>
" <https://github.com/junegunn/vim-plug/pull/240#issuecomment-110538613>
" To ease that, maybe we should turn this code into a PlugBootstrap function?
if empty(glob('~/.vim/autoload/plug.vim'))
	" TODO: detect if we're behind an HTTP proxy and fail with
	" a message. (Because no way am I going to pass --insecure
	" to curl, nor set GIT_SSL_NO_VERIFY to true).
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	" N.B., $MYVIMRC is magically set to point to this ~/.vimrc
	" file. Alas, there appears to be no equivalent for the
	" ~/.vim directory
	autocmd VimEnter * PlugInstall | source $MYVIMRC
endif


" We use ~/.vim/bundle since that's what most other plugin managers
" use. However, all the vim-plug docs prefer ~/.vim/plugged instead.
" So beware.
call plug#begin('~/.vim/bundle')
" TODO: use 'git@github.com:$WHO/$WHAT.git' formatting instead, to avoid https
" TODO: see which of these plugins I actually want...

" ~~~~~ Automatically use GNU PGP
" TODO: again, security blah blah. Do we want to do this, or just
" keep a copy in the dotfiles repo?
" TODO: This looks like the official git repo for:
"     <http://www.vim.org/scripts/script.php?script_id=3645>
" But is it actually organized correctly for use as a plugin?
"Plug 'jamessan/vim-gnupg'

" ~~~~~ Tabline & Statusline (just the basics; see also Buffers & Tabs)
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" This is necessary for the pretty airline wedges; but doesn't seem
" to work well on OSX/iTerm2 (see notes below). For Monaco, things
" are tricky; cf.,
"     <https://github.com/powerline/fonts/pull/16>
"     <https://gist.github.com/epegzz/1634235>
"     <https://gist.github.com/rogual/6824790627960fc93077>
"     <https://gist.github.com/baopham/1838072>
"     <https://github.com/robbyrussell/oh-my-zsh/issues/2869>
"     <https://github.com/powerline/fonts/issues/44>
"     <https://powerline.readthedocs.io/en/latest/installation/osx.html>
" N.B., 'Lokaltog/powerline-fonts' redirects to 'powerline/fonts'
"Plug 'Lokaltog/powerline-fonts', { 'do': './install.sh' }

" ~~~~~ Buffers & Tabs
"Plug 'bling/vim-bufferline'
"Plug 'majutsushi/tagbar'
"Plug 'weynhamz/vim-plugin-minibufexpl'

" ~~~~~ Git
"Plug 'airblade/vim-gitgutter'
"Plug 'mhinz/vim-signify' " like gitgutter, but for other VCSes
" <https://bitbucket.org/ludovicchabant/vim-lawrencium> " for Mercurial
"Plug 'junegunn/vim-github-dashboard'
"Plug 'tpope/vim-fugitive'

" ~~~~~ File-tree browsing
"Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
"Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }

" ~~~~~ Fuzzy searching
"Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
"Plug 'Shougo/unite.vim'
"Plug 'ctrlpvim/ctrlp.vim'

" ~~~~~ Undoing
"Plug 'sjl/gundo.vim'
"Plug 'mbbill/undotree'

" ~~~~~ Etc.
"Plug 'junegunn/seoul256.vim'   " Low-contrast color scheme
"Plug 'junegunn/goyo.vim'       " A vim variant of OmmWriter?
"Plug 'junegunn/limelight.vim'  " Colorize only local chunks/paragraphs
" TODO: cf., the Cond function <https://github.com/junegunn/vim-plug/wiki/faq>
"Plug 'junegunn/vim-xmark', has('mac') ? {} : { 'on' : [] }
"Plug 'junegunn/vim-easy-align'
"Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
"Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
"Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
"Plug 'tpope/vim-sensible' " More-sensible defaults
"Plug 'tomtom/quickfixsigns_vim'
"Plug 'scrooloose/syntastic'
"Plug 'jmcantrell/vim-virtualenv' " for Python virtualenvs
"Plug 'edkolev/tmuxline.vim'
"Plug 'gcmt/taboo.vim'
"Plug 'vim-ctrlspace/vim-ctrlspace'
"Plug 'edkolev/promptline.vim'
"Plug 'bling/minivimrc'
"Plug 'terryma/vim-expand-region' " cf., <https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/>
call plug#end()


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ airline configuration
" TODO: guard this section with something like:
"if not(empty(glob('~/.vim/bundle/vim-airline/autoload/airline.vim')))

" Show all buffers in the tabline, when there's only one tab.
let g:airline#extensions#tabline#enabled = 1

" Automatically show the statusline, even if there're no splits.
"set laststatus=2

" Some examples of things we may want to put in g:airline_section_N:
" '%{strftime("%c")}'
" 'BN: %{bufnr("%")}'
" '%{airline#util#wrap(airline#parts#ffenc(),0)}' " the default g:airline_section_y

if has('multi_byte')
	" Populate the g:airline_symbols dictionary with 'powerline/fonts'
	" symbols. N.B., requires those fonts to be installed first.
	"
	" TODO: insert guards to detect whether the powerline fonts
	" are installed. (Because even after running the ./install.sh
	" script for 'powerline/fonts' we still get those error glyphs)
	"
	" N.B., for iTerm2 on OSX (and probably more generally) you
	" need to go in and change the terminal's font before this
	" will actually work (instead of showing error glyphs).
	"let g:airline_powerline_fonts = 1

	" Or, manually do unicode hackery
	"if !exists('g:airline_symbols')
	"	let g:airline_symbols = {}
	"endif
	"let g:airline_left_sep = '▶' " '»'
	"let g:airline_right_sep = '◀' " '«'
	"let g:airline_symbols.crypt = '🔒'
	"let g:airline_symbols.linenr = '¶' " '␊', '␤'
	"let g:airline_symbols.maxlinenr = '' " '☰'
	"let g:airline_symbols.branch = '⎇'
	"let g:airline_symbols.paste = 'ρ' " 'Þ', '∥'
	"let g:airline_symbols.spell = 'Ꞩ'
	"let g:airline_symbols.notexists = '∄'
	"let g:airline_symbols.whitespace = 'Ξ'
endif


" ~~~~~ nerdtree configuration
"map <C-n> :NERDTreeToggle<CR>

" Allow vim to close if the only open window is nerdtree
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Highlight based on extensions:
" <https://github.com/scrooloose/nerdtree/issues/433#issuecomment-92590696>


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
