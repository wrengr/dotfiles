" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" This is wren gayle romano's vim config            ~ 2016.11.13
"
" For guidance, see ~/.vim/README
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Basic usability
set nocompatible         " Avoid compatibility with legacy vi
set backspace=indent,eol,start " Allow backspacing anything (input mode)
"set whichwrap=b,s,<,>,~,[,]   " backspace and cursor keys wrap too
set number               " Show line numbers?
set showmatch            " When inserting a bracket, briefly jump to the match
"set matchtime=5         " how long (N/10 secs) to blink on matching bracket
"set updatetime=4000     " how long (N/10 secs) to highlight matching & save swp if nothing done


" ~~~~~ Modelines
" One should never parse modelines by default, it's a security
" vulnerability. <http://usevim.com/2012/03/28/modelines/>
set nomodeline
"set modelines=5         " Search in the first N lines for modes
" TODO: is there a way to only parse modelines for detecting the
" filetype whenever our other ways of detecting it fail? Is that
" still insecure?


" ~~~~~ Commandline, Statusline, & Tabline
set showcmd              " Show the commandline
set cmdheight=1          " The commandline is N rows high
set noshowmode           " Don't show the mode in the commandline
set ruler                " Show line and column position of the cursor
                         " (N.B., is in commandline iff laststatus=1.
                         " Otherwise is in the statusline?)
set laststatus=2         " Always show statusline, even if there're no splits
"set statusline=%F%m%r%h%w\ [%{&ff}\|%Y\|%03.3b\|%04l,%04v\|%p%%\|LEN=%L] "\ %{Tlist_Get_Tag_Prototype_By_Line()}


" ~~~~~ Bells
"set novisualbell t_vb=  " Don't use the visual bell.
"set noerrorbells        " Error bells are annoying.


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

    if v:version >= 700
        set listchars=tab:»\ ,trail:·,eol:¶,extends:→,precedes:←,nbsp:×
    else
        " BUG: This line is still giving errors on version 6.2 ...
        set listchars=tab:»\ ,trail:·,eol:¶,extends:>,precedes:<,nbsp:_
    endif

    " Show ↪ at the beginning of wrapped lines
    " TODO: It'd be better if we could put this in the gutter, rather
    " than in the first column.
    "let &showbreak = nr2char(8618).' '
endif

" Enable &list to visualize invisible characters (<Tab>, nbsp, EOL, etc)
" The vizualisations are defined in &listchars. N.B., &list is incompatible
" with &linewrap, and enabling &list will override &linewrap's setting.
" This highly unexpected behavior has been deemed 'a feature':
"     <https://groups.google.com/forum/#!topic/comp.editors/blelxLchTPg>
"set list


" ~~~~~ Terminal title
" <http://vim.wikia.com/wiki/Automatically_set_screen_title>
" <http://usevim.com/2012/06/13/set-title/>
if has('title')
    " BUG: many times screen doesn't set TERM to say that; and
    " even when it does, our ~/.bash_profile changes it.
    if &term == "screen"
        set t_ts=^[k
        set t_fs=^[\
    endif
    set title
    " BUG: how do we get the 'is edited' bit to use the format it
    " does in the default? (instead of with the square brackets and with
    " a bunch of space, I mean)
    " BUG: how do we get help pages to show up as appropriate,
    " rather than actually giving the path to the file where they're
    " stored?
    " N.B., the list of codes is at `:help statusline` not at the
    " helppage for titlestring
    "set titlestring=VIM\ %-25.55F\ %a%r%m
    set titlestring=VIM\ \ %t\ (%{expand(\"%:~:.:h\")})\ %a%r%m
    set titlelen=70
endif


" ~~~~~ Mouse support
" Setting this will make it so that selecting things with the mouse
" doesn't grab the numbers (etc) in the gutter!
" <http://vim.wikia.com/wiki/Using_the_mouse_for_Vim_in_an_xterm>
" BUG: alas, it seems to break something about using the OSX clipboard...
" <http://unix.stackexchange.com/q/139578>
"set mouse=a             " Copy/paste in "* register, normal behaviour with shift key pressed

" TODO: If we really want to go the mouse route, see also:
"if has('mouse')
"   (1) <https://iterm2.com/faq.html>
"   if has('mouse_sgr')
"       set ttymouse=sgr
"   (2) <http://usevim.com/2012/05/16/mouse/>
"   elseif has('mac')
"       set ttymouse=xterm2
"   else
"       ...
"   endif
"endif
" (3) <https://github.com/nvie/vim-togglemouse>
" (4) <http://unix.stackexchange.com/q/44513> re Gnome terminal bugginess

"set mousehide           " Hide mouse while typing


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
    " N.B., we set the &colorscheme later, after installing plugins.
    " TODO: should we just move what's left of this section down there?
endif
" TODO: &t_Co is often wrong. We need to set up our ~/.bash_profile
" to try to detect how many colors any given terminal actually
" supports, and then set the $TERM and other global variables
" accordingly, so that tput and vi and everyone else actually picks
" up the right thing. If that fails, then maybe we'll need to
" actually set &t_Co ourselves...
"
" Update 2016-09-12: Looks like my google workstation defaults to
" t_Co=8, even though it (seems to) actually supports 256. However,
" setting it to higher values causes the text to always be thin (never
" bold); and there's some bug with 32--128 where the yellow and teal
" colors get swapped.


" ~~~~~ Highlight the final column
" TODO: make a function that toggles this, rather than assuming
" always on.
" N.B., if this glitches out when using non-ASCII characters that
" aren't actually wide (typographically speaking), then you probably
" need to adjust your terminal; since the terminal and vim are
" disagreeing about where the cursor actually is.
" N.B., has(...) checks for compiled "features"; exists(...) checks options.
if exists('+colorcolumn')
    " N.B., this is the column we highlight, hence should be one
    " more than where we want to wrap. You can also use "+n" to set
    " it automatically based on &textwidth.
    set colorcolumn=81
    " Or, to shade everything beyond 81 instead of only 81 itself:
    "execute "set colorcolumn=" . join(range(81,335), ',')

    " BUG: the DarkGrey color constantly shows up differently
    " between Goobuntu and OSX/iTerm2. Sometimes it's an awesome
    " bluish grey thing, sometimes it's the same grey as comment
    " text, sometimes it's bright red. We need to figure out
    " what's causing all the issues and fix it. Probably something
    " about &t_Co being wrong, would be my guess. In any case,
    " if we can't fix &t_Co or whatever, then we should try
    " using a hexcode color instead.
    highlight ColorColumn guibg=#262626 ctermbg=234 guifg=white ctermfg=white
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


" ~~~~~ Indentation & tabs
set autoindent           " Keep indent levels line-to-line
set nosmartindent        " Don't be stupid about hash. Instead use ft stuff.
                         " <http://vim.wikia.com/wiki/Restoring_indent_after_typing_hash>
" Stop stupid unindenting when typing the hash key (e.g., in Python)
" cf., <http://stackoverflow.com/a/2360284/358069> or :help smartindent
"inoremap # X#

set tabstop=4            " Display a <Tab> as N characters
set softtabstop=0        " Don't pretend N positions are a <Tab>
set shiftwidth=4         " Indent N positions by shifting text with < and >

" Enabling smarttab means we will use &shiftwidth for how many
" positions to insert for <Tab> at the beginning of a line (instead
" of only using &shiftwith for the shift commands; i.e., < and >).
" N.B., <Tab> will still use &tabstop when *not* at the beginning
" of the line. Disabling smarttab means we will use &tabstop everywhere.
set smarttab
" Enabling expandtab means we will *always* convert <Tab> to positions
" (either &shiftwidth or &tabstop, depending on &smarttab). Disabling
" it means we will *never* convert <Tab> to positions. N.B., if you
" want to convert <Tab> manually, you should reset the &expandtab
" value and then use the :retab command.
"
" We're disabling expandtab by default (will be overridden by
" filetype stuff), so we don't muck up Makefiles and other things
" that actually do need the literal <Tab> character.
set noexpandtab

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


" ~~~~~ Line wrapping (or not, as the case may be)
set wrap               " Enable &wrap to soft-wrap overly long lines.
set linebreak          " (lbr) Only break lines at characters in &breakat;
                       " i.e., not in the middle of words.
                       " N.B., the default &breakat contains a space.
"set breakat=" ^I!@*-+;:,./?"
set nolist             " Disable &list because it invalidates &linebreak
    " This behavior is deemed to be 'a feature':
    " <https://groups.google.com/forum/#!topic/comp.editors/blelxLchTPg>

" Try really hard to turn off hard-wrapping.
"
" We break this out as a function, in case we need to invoke it
" manually or in a bunch of different .vim/after/ftplugin/*.vim
" files. Some sources for what we're doing are:
"     <http://vim.wikia.com/wiki/Word_wrap_without_line_breaks>
"     <http://vimdoc.sourceforge.net/htmldoc/change.html#fo-table>
"     <http://vi.stackexchange.com/a/1985>
"     <http://stackoverflow.com/a/2312888/358069>
"     <http://stackoverflow.com/a/23326474/358069>
function! DisableHardWrapping()
    set textwidth=0 wrapmargin=0 " can't hard-wrap at column zero, ha!
    " Must remove each one individually, because -= is string-based.
    set formatoptions-=t
    set formatoptions-=c
    set formatoptions-=a
    set formatoptions+=l
    set formatoptions+=1
endfunc
call DisableHardWrapping()


" ~~~~~ Searching
set nohlsearch           " Should we highlight searches?
set incsearch            " While typing search command, show matches so far
set ignorecase           " Don't care if search for upper or lowercase
"set magic               " Make regex more easy
"set smartcase           " Only look for case when uppercases are used


" ~~~~~ Wild
"set wildchar=<Tab>      " Expand the command line using tab
"set wildmenu            " Nice tab-completion on the command line
"set wildcharm=<C-Z>     " cf., <http://vim.wikia.com/wiki/Easier_buffer_switching>
"set wildignore+=.o      " Ignore some files in completion
"set wildignore+=*.o,*.out,*.obj,.git,*.rbc,*.rbo,*.class,.svn,*.gem
"set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz
"set wildignore+=*/vendor/gems/*,*/vendor/cache/*,*/.bundle/*,*/.sass-cache/*
"set wildignore+=*.swp,*~,._*
"
"set wildmode=longest:full,list:full
"             |            |
"             |            +-- List matches, complete first match, use wildmenu
"             +--------------- Complete longest prefix, use wildmenu


" ~~~~~ Spelling
" TODO: make a function/keybinding for toggling &spell
"if v:version > 700
"   set spell           " Highlight spelling errors automatically
"   setlocal spell spelllang=en_us
"   set spellsuggest=10 " Show top N spell suggestions
"   " Change to make spellfile.vim ask you again for downloading file
"   let g:spellfile_URL = 'http://ftp.vim.org/vim/runtime/spell'
"endif


" ~~~~~ Folding (:help usr_28)
" By default <z><a> is used for un/folding. but that can be annoying
" if you accidentally mistype the <z> and so enter append mode. Should
" use nnoremap to choose some other key combo for un/folding.
"
" For Python, you can get fancy with something like
" <https://github.com/tmhedberg/SimpylFold>, so you can still see docstrings
" when folded, etc.
if has('folding')
    "set foldenable          " Turn on folding
    " This shows the first line of the fold, with "/*", "*/" and "{{{" removed.
    "set foldtext=v:folddashes.substitute(getline(v:foldstart),'/\\*\\\|\\*/\\\|{{{\\d\\=','','g')
    "set foldmethod=syntax   " Make folding by: syntax, indent,...
    "set foldlevel=0         " Autofold (0)just this level, (99)all levels
    "set foldlevelstart=0    " Initially close all folds
    "set foldminlines=2      " Don't fold lines that are less than
    "set foldnestmax=3       " Maximum nesting for foldings

    " Use N columns of gutter to show the extent of folds.
    " (the N-th column is always empty, so only shows N-1 levels of nesting
    " in tree-like format; the rest are abbreviated by numbers for their depth)
    set foldcolumn=1

    "set foldopen+=insert    " Open folds when action happens
    "set foldopen+=jump      " Open folds when action happens
    "set foldopen=all        " Open folds when action happens
    "set foldclose=all       " Automatically close folds when leving

    " To automatically save manual folds and reload them:
    " (I'm not sure if I actually want this, but it's good to remember)
    "autocmd BufWinLeave * mkview
    "autocmd BufWinEnder * loadview
endif


" ~~~~~ Toggle between normal and relative line numbers
" HT: <https://github.com/alialliallie/vimfiles/blob/master/vimrc>
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
" TODO: use <leader> instead of <C>?
nnoremap <C-n> :call ToggleNumber()<cr>

" This should be set by default, but just to make sure. This is
" particularly helpful when dealing with ssh+screen, since that seems to
" cause issues with redrawing.
" TODO: might consider adding :nohlsearch<cr> before the redraw.
nnoremap <C-l> :redraw!<cr>


" ~~~~~ Toggle highlighting certain whitespace as errors
" TODO: actually make this toggle!
" BUG: this doesn't seem to work everywhere (e.g., inside `function!`
" itself; though it works just fine inside `if`)
" TODO: I like starting the name with "Toggle" for better tab-completion,
" but everyone else puts the "Toggle" at the end of the function name...
function! ToggleHighlightSpaces()
    " TODO: should prolly guard this one based on how &expandtab is set.
    syntax match tab display "\t"
    highlight link tab Error

    syntax match trailingWhite display "[[:space:]]\+$"
    highlight link trailingWhite Error

    " The \ze ends the match, so that only the spaces are highlighted.
    syntax match spaceBeforeTab display " \+\ze\t"
    highlight link spaceBeforeTab Error
endfunc


" ~~~~~ Etc.
"     http://www.tjansson.dk/filer/vimrc.html
"     http://saulusdotdyndnsdotorg/~david/config/vimrc
"         This one has a whole hell of a lot of stuff!
"     https://github.com/mad-raz/dotvim/blob/master/.vimrc
"     https://github.com/junegunn/dotfiles/blob/8646aae3aec418662d667b36444e771041ad0d23/vimrc#L12-L91
"     http://www.apaulodesign.com/vimrc.html
"     https://github.com/thoughtbot/dotfiles/blob/master/vimrc

"set lazyredraw          " Don't redraw while running macros, for speed
"set hidden              " Hide buffers when they are abandoned
set ttyfast              " Is our terminal connection 'fast'? (hint: yes)
"set autochdir           " Change directory to the file in the current window
"set nojoinspaces        " No additional spaces when joining lines with <J>
"set esckeys             " Allow cursor keys within insert mode
"set debug=msg,throw     " msg, throw, beep --- combinable
"set report=0            " Always report the number of lines changed
"set display=lastline    " Show as much of the last line as possible
"set nofsync             " Less power consumption *DANGEROUS* doesnt sync IO
"set swapsync=           "     this could result in data loss, so beware!
set noinsertmode         " Don't start in insert mode. That's some emacs kinda silliness.

"set fileformat=unix
"set ttimeout            " Let vim wait for timeouts
"set timeoutlen=3000     " How long does vim wait for mapping sequences
"set ttimeoutlen=100     " How long does vim wait for the end of escape sequence
"set path=$HOME/,.       " Set the basic path (see below)
" TODO: see <http://www.oualline.com/vim/10/top_10.html> for what
" these so-called 'tags' are all about.
"set tags=tags,$HOME/.vim/ctagsproject
"set shell=/bin/bash     " A shell
set scrolloff=5          " Show N lines in advance when scrolling
"set sidescrolloff=10    " Columns visible to the left/right of cursor when scrolling
"set winminheight=0      " Let splitted windows get as small as only the titlebar
" BUG: setting splitright moves the focus to the right window, against our wishes
"set splitright          " When splitting vertically, split to the right
set splitbelow           " When splitting horizontally, split below
"set browsedir=buffer    " :browse e starts in %:h, not in $PWD
"set grepprg=grep\ -nH\ $*
"set cursorline          " highlight the whole line the cursor is on

" Vim Grep
let Grep_Skip_Dirs = 'RCS CVS SCCS .svn .hg _darcs .git'


" ~~~~~ Copying & Pasting
"set pastetoggle=<F9>

" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

" TODO: guard this stuff to be OSX-only?
" <http://www.drbunsen.org/text-triumvirate.html>
" Yank text to the OS X clipboard
noremap <Leader>y "*y
noremap <Leader>yy "*Y

" Make <S-y> yank from cursor to end of line (a la <S-d>, and akin
" to <S-a>), rather than yanking the whole line (a la <y><y>, as
" is done in traditional vi).
nnoremap Y y$

" Preserve indentation while pasting text from the OS X clipboard
" TODO: this doesn't help for my Goobuntu workstation. Need to make smarter
" BUG: this seems to have broken on newer OSX.
noremap <Leader>p :set paste<CR>:put  *<CR>:set nopaste<CR>


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
" works on my Google OSX laptop; though <C-w> followed by arrow
" keys seems to work on my personal laptop (at least since upgrading
" to Sierra, though I think they didn't work before). The commands
" to do things directly are ':wincmd h/j/k/l'


" Enable OSX-like command for saving
" BUG: this doesn't seem to be working either :(
"nnoremap <C-s> :w<CR>
"inoremap <C-s> <ESC>:w<CR>


" ~~~~~ FileType stuff
" TODO: Most of this stuff should go into its own ft files. Not in here!
"     <http://vim.wikia.com/wiki/Keep_your_vimrc_file_clean>
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

" TODO: similar smarts for Bash/Perl/Python-style comments
" TODO: can I write a single smart macro that does all of them?


" ~~~~~ Functions
"" Removes all trailing spaces
"" If you want to just do it manually, then type what's between the quotes
"function! RmTrailingSpace()
"   silent! execute ":%s/\s\+$//"
"endfun

" Add type signatures to top-level functions
" From Sebastiaan Visser
"function! HaskellType()
"   w
"   execute "normal {j^YP"
"   execute (".!ghc -XNoMonomorphismRestriction -w % -e \":t " . expand("<cword>") . "\"")
"   redraw!
"endfunction
"
"function Haskell()
"   map <buffer> <silent> tt :call HaskellType()<Cr>
"   " more haskell stuff here
"endfunction
"
"autocmd BufRead,BufNewFile *.{ag,hs,lhs,ghs} call Haskell()
"
"" Compare vs the following Cabal integration hack
"
"function! SetToCabalBuild()
"   if glob("*.cabal") != ''
"       let a = system( 'grep "/\* package .* \*/"  dist/build/autogen/cabal_macros.h' )
"       let b = system( 'sed -e "s/\/\* /-/" -e "s/\*\///"', a )
"       let pkgs = "-hide-all-packages " .  system( 'xargs echo -n', b )
"       let hs = "import Distribution.Dev.Interactive\n"
"       let hs .= "import Data.List\n"
"       let hs .= 'main = withOpts [""] error return >>= putStr . intercalate " "'
"       let opts = system( 'runhaskell', hs )
"       let b:ghc_staticoptions = opts . ' ' . pkgs
"   else
"       let b:ghc_staticoptions = '-XNoMonomorphismRestriction -Wall -fno-warn-name-shadowing'
"   endif
"   execute 'setlocal makeprg=' . g:ghc . '\ ' . escape(b:ghc_staticoptions,' ') .'\ -e\ :q\ %'
"   let b:my_changedtick -=1
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

" TODO: how can we get plug.vim to open its status window on the right? I
" tried setting g:plug_window, but can't get it to work...

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


" ~~~~~ Syntax highlighting
" TODO: should we guard this for?: has("syntax") && (&t_Co > 2 || has("gui_running"))
" TODO: cf., the Cond function <https://github.com/junegunn/vim-plug/wiki/faq>
" TODO: do we need to do anything special since the vim code isn't top level?
Plug 'chriskempson/tomorrow-theme'
" I don't actually like Solarized, but for future reference:
"Plug 'altercation/vim-colors-solarized'


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


" ~~~~~ Git & other VCSes
Plug 'airblade/vim-gitgutter', has('signs') ? {} : { 'on' : [] }
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
"Plug 'godlygeek/tabular' | Plug 'plasticboy/vim-markdown' " Syntax highlighting for Markdown
"Plug 'junegunn/seoul256.vim'   " Low-contrast color scheme
"Plug 'junegunn/goyo.vim'       " A vim variant of OmmWriter?
"Plug 'junegunn/limelight.vim'  " Colorize only local chunks/paragraphs
" TODO: cf., the Cond function <https://github.com/junegunn/vim-plug/wiki/faq>
"Plug 'junegunn/vim-xmark', has('mac') ? {} : { 'on' : [] }
"Plug 'junegunn/vim-easy-align'
"Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
"Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
"Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
" or maybe: { 'do': './install.sh --gocode-completer  --tern-completer' }
"Plug 'tpope/vim-sensible' " More-sensible defaults
"Plug 'tomtom/quickfixsigns_vim'
"Plug 'scrooloose/syntastic'
"Plug 'jmcantrell/vim-virtualenv' " for Python virtualenvs
"Plug 'edkolev/tmuxline.vim'
"Plug 'gcmt/taboo.vim'
"Plug 'vim-ctrlspace/vim-ctrlspace'
"Plug 'edkolev/promptline.vim'
"Plug 'bling/minivimrc'
" ~~~~~ cf., <https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/>
" and <https://github.com/sheerun/dotfiles/blob/master/vimrc>
" and <https://github.com/sheerun/vimrc>
"Plug 'wellle/targets.vim'
"Plug 'sheerun/vim-polyglot'
"Plug 'sjl/vitality.vim'  " for Vim + iTerm2 (+ tmux)
"Plug 'grassdog/tagman.vim'
"Plug 'justinmk/vim-dirvish' " in lieu of nerdtree
"Plug 'terryma/vim-expand-region'
"Plug 'rking/ag.vim' " Lightning fast :Ag searcher
"Plug 'tomtom/tcomment_vim'
"Plug 'tpope/vim-rsi'
"Plug 'tpope/vim-endwise'
"Plug 'tpope/vim-repeat'
"Plug 'tpope/vim-sleuth'
"Plug 'tpope/vim-unimpaired'
"Plug 'danro/rename.vim' " Allow to :Rename files
"Plug 'flowtype/vim-flow'
"Plug 'airblade/vim-rooter' " Automatically find root project directory
"let g:rooter_disable_map = 1
"let g:rooter_silent_chdir = 1
"Plug 'AndrewRadev/splitjoin.vim' " Expand / wrap hashes etc.
"Plug 'fatih/vim-go', { 'for': 'go' }
"let g:go_fmt_command = "goimports"
"Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh', 'for': 'go' }
"Plug 'moll/vim-node', { 'for': 'javascript' }
"Plug 'christoomey/vim-tmux-navigator' " Navitate freely between tmux and vim
"Plug 'michaeljsmith/vim-indent-object' " ii / ai
"Plug 'ashisha/image.vim' " View images as ASCII art
"
"" For more reliable indenting and performance
"set foldmethod=indent
"set fillchars="fold: "
"
"" Nice file browsing with -
"Plug 'eiginn/netrw'
"let g:netrw_altfile = 1
"Plug 'tpope/vim-vinegar'
"
"" Better search tools
"Plug 'vim-scripts/IndexedSearch'
"Plug 'vim-scripts/SmartCase'
"Plug 'vim-scripts/gitignore'
call plug#end()


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Pretty colors
if has("syntax") && (&t_Co > 2 || has("gui_running"))
    colorscheme Tomorrow-Night-Bright

    " I don't actually like Solarized, but for tuture reference:
    "let g:solarized_termtrans=1
    "let g:solarized_visibility='low' " 'low', 'normal', 'high'
    "let g:solarized_bold=0
    "let g:solarized_italic=0
    "let g:solarized_underline=0
    "colorscheme solarized
endif


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ airline configuration
" TODO: guard this section with something like:
"if not(empty(glob('~/.vim/bundle/vim-airline/autoload/airline.vim')))

" Show all buffers in the tabline, when there's only one tab. Only
" looks good if your terminal has enough colors.
"let g:airline#extensions#tabline#enabled = 1

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
    "   let g:airline_symbols = {}
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

" From <https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/>
" TODO: For consideration...
let g:airline_theme='powerlineish'
let g:airline_left_sep=''
let g:airline_right_sep=''
let g:airline_section_z=''


" ~~~~~ gitgutter configuration
if has('signs')
    set updatetime=500
    let g:gitgutter_sign_column_always = 1
    "let g:gitgutter_max_signs = 500 " default=500
    "let g:gitgutter_map_keys = 0 " don't set up default mappings
    " Default mappings:
    "     nmap ]c         <Plug>GitGutterNextHunk
    "     nmap [c         <Plug>GitGutterPrevHunk
    "     nmap <Leader>hp <Plug>GitGutterPreviewHunk
    "     nmap <Leader>hs <Plug>GitGutterStageHunk
    "     nmap <Leader>hu <Plug>GitGutterUndoHunk
    "     omap ic         <Plug>GitGutterTextObjectInnerPending " all lines in hunk
    "     omap ac         <Plug>GitGutterTextObjectOuterPending " also trailing empty lines
    "     xmap ic         <Plug>GitGutterTextObjectInnerVisual
    "     xmap ac         <Plug>GitGutterTextObjectOuterVisual
    " TODO: the readme has all sorts of function suggestions
endif


" ~~~~~ nerdtree configuration
"if exists(":NERDTree")
    "map <C-t> :NERDTreeToggle<CR>

    " Allow vim to close if the only open window is nerdtree
    "autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

    " <http://stackoverflow.com/a/26161088>

    " Highlight based on extensions:
    " <https://github.com/scrooloose/nerdtree/issues/433#issuecomment-92590696>
"endif


" ~~~~~ syntastic configuration
"if exists(":SyntasticCheck")
"endif

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
