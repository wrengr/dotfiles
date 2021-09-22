" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren gayle romano's vim config                    ~ 2021.09.16
"
" This file uses &foldmethod=marker, but I refuse to add a modeline
" to say that; because modelines are evil.
"
" See: ~/.vim/NOTES.md  for more guidance, commentary, and style notes.
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


" ~~~~~ Minimal preamble before loading plugins ~~~~~~~~~~~~~~~~ {{{1
set nocompatible " Avoid compatibility with legacy vi. (Must come first)
set nomodeline   " Avoid insecurity!  (See: ~/.vim/NOTES-modelines.md)
set ttyfast      " Avoid thinking we're still in the 1970s.
set noinsertmode " Avoid emacs-emulating silliness.

" See: ~/.vim/NOTES-versions.md
" Nevertheless, I may use `:h has-patch` below for versions older
" than 8.0 (maybe even anaconistically for older than Vim 7.4.237).
" This is mainly for documentation purposes, for my own interest.
if v:version < 800
  " N.B., :echo will gladly interpret newlines.  However, :echomsg
  " and :echoerr will not.  Cf., <https://vi.stackexchange.com/q/18203>
  let v:errmsg = 'ERROR: this Vim is older than 8.0.0000 (2016 Sep 12)'
    \ "\n" . '    Debian 9 "Stretch" (EOL: 2020-07-06)'
    \ "\n" . '        has Vim 8.0.0197'
    \ "\n" . '    OSX 10.13 "High Sierra" (EOL: 2020-12)'
    \ "\n" . '        has Vim 8.0.1283 (sans patches 504,681)'
    \ "\n" . '    So I don''t feel pressured to support Vim < 8.0'
  echohl ErrorMsg
  echo v:errmsg
  echohl NONE
  finish
endif

" One augroup to rule them all!
if has('autocmd')
  augroup wrengr_vimrc
    au!
  augroup END
endif

" Warning: setting `nocompatible` auto re-enables modelines!
" BUGFIX: While we made sure to `nomodeline` after `nocompatible`
" above, it seems likely we may run into other gotchas down the line
" (e.g., packages which set `nocompatible`).  So we're going to be
" extra aggressive about turning them off.
if has('autocmd') && (!has('patch-8.1.1365') || !has('patch-8.0.0056'))
  autocmd wrengr_vimrc BufReadPre * set nomodeline
endif

" Warning: The output of `:version` is a not entirely reliable indicator
" of when has('foo') will return true or false.  For example:
" * 'spell' isn't listed, yet has('spell') is true.
" * 'colorcolumn' isn't listed, and has('colorcolumn') returns false,
"   yet exists('+colorcolumn') returns true.
" * 'mac' isn't listed by either the Vim 8.0.1283{-504,-681,+1365}
"   that ships with OSX 10.14 nor by Fink's vim-nox 8.2.3404-1; and
"   has('mac') returns *false* on the former but true on the latter.

" BUG: Yes, you heard that right, the Vim that ships with OSX 10.14
" returns *false* for has('mac') !!!  Also be very aware of the
" fact that this version of OSX (and all of them probably) has a
" /usr/bin/vi symlink to /usr/bin/vim; whereas Fink doesn't install
" an analagous symlink for their /opt/sw/bin/vim, which means typing
" 'vi' as a shorthand will almost surely give you a different version
" of Vim than the one you want.

" See also: <https://stackoverflow.com/q/2842078>   " asked in 2010!


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ vim-plug <https://github.com/junegunn/vim-plug> ~~~~~~~~ {{{1
"
" To abbreviate the very long urls below, pretend we have:
"   let $VIMPLUG_URL='https://github.com/junegunn/vim-plug'

" We :finish because an augroup will re-source this file.
if wrengr#plug#Bootstrap() | finish | endif

" TODO: It's not really relevant anymore, since we've moved the
"   function off to a separate file, but: Figure out how exactly
"   to generate the <SID> for this file so we can make PlugWindow()
"   private yet still call it via g:plug_window.  The necessary
"   info is in `:h <SID>` and <https://vi.stackexchange.com/q/27224>,
"   but I haven't been able to get the pieces to work together...
let g:plug_window = 'call wrengr#plug#Window()'


" TODO: Use (ssh+)git-protocol in lieu of https:
"   <$VIMPLUG_URL/wiki/faq#whats-the-deal-with-git-in-the-url>
"let g:plug_url_format = 'git@github.com:%s.git'
"   N.B., this can be turned on and off throughout the plugin
"   listing; it only applies if currently defined at a given :Plug
"   call-site.
"
" Note: since git-1.6.6 (2010) plain ssh is equivalent to https:
"   <https://stackoverflow.com/a/3248848>.
" For other reasons to prefer one over the other:
"   <https://stackoverflow.com/a/11041782>.
" For more on what the heck the plain git-protocol even is/does:
"   <https://stackoverflow.com/a/33846897>.


" We use ~/.vim/bundle just cuz most other plugin managers do too.
" Though I suppose that might be a reason to use something different
" instead.
let s:vimplug_dir = wrengr#plug#DataDir('bundle')
call plug#begin(s:vimplug_dir)
"
" Note: vim-plug >=0.5.0 no longer does dependency resolution:
"   <$VIMPLUG_URL/wiki/plugfile>
" So the indentation and pipes below is just for stylistic clarity
" rather than actually doing anything (afaict; though maybe it's
" only dependency *auto-detection* that got removed, and the manual
" dependency annotations still do something? unclear.)
"
" Note: as discussed in the file where it's defined: outside of the
" usage in wrengr#plug#Cond(), one should rarely need to specify
" 'on'/'for'.  Below I'll use the tag [#jg] whenever I've added
" a 'for'/'on' to a plugin because I've seen that Junegunn does so
" in their own dotfiles repo; namely for plugins that are still
" commented out because I haven't had a chance to try them out yet.

" TODO: actually go through all these to see which plugins I actually want...


" ~~~~~ GNU PGP ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{2
" For security reasons, we manually manage this one and keep a copy
" in our dotfiles repo.
" TODO: maybe still list it but using the leading '~' notation to
"   inform vim-plug that it's manually managed.
"Plug 'jamessan/vim-gnupg'
  " Default to using ascii-armor. Hopefully this'll help deal with the
  " bug where saving modified files causes them to be saved as binary
  " in spite of the *.asc suffix.
  let g:GPGPreferArmor=1
  " Debugging Note: If you install a new version of gpg and are running
  " into issues with vim-gnupg, then you probably need to re-import
  " your secret keys.  For more info on how to do so (and how to check
  " if that's the issue), see: <https://stackoverflow.com/q/43513817>


" ~~~~~ Unicode ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{2
" See also <https://vi.stackexchange.com/a/560>
" <https://x-team.com/blog/inserting-unicode-characters-in-vim/>
" <https://jdhao.github.io/2020/10/07/nvim_insert_unicode_char/>
"Plug 'chrisbra/unicode.vim'
"Plug 'tpope/vim-characterize'
"Plug 'arp242/uni'


" ~~~~~ Colorschemes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{2
" TODO: some of these can be quite slow to load (e.g., the venerable
" 'chriskempson/tomorrow-theme', but also anything using a variant
" of my 'naivecolors.vim').  So we should (a) sift through them to
" figure out which ones we actually want to keep, and (b) add some
" sort of guards... though I'm not entirely sure which ones would be
" best.  (And frankly, they ought to be doing the guards themselves!)

"Plug 'junegunn/seoul256.vim'           " Low-contrast color scheme
"Plug 'vim-scripts/wombat256.vim'
"
"   This one has some nice integration with CtrlP and easymotion.
"   They also have a cutely different way of converting cterm256
"   codes to hex, via lookup table rather than computation :)
"   And an curious approach of encoding the cterm256 ordinals as
"   strings, and then using a function to convert those ordinal-strings
"   to the actual codepoints; it's not bad, just curious is all.
"   It leads to some nicely terse code since it only takes three
"   characters to specify any ordinal-string; though you loose some
"   intensionality information, since you don't use variable names
"   to say why various things are the same color.
"Plug 'dtinth/vim-colors-dtinth256'
"
" Vim port of Hamish Stuart Macpherson's theme for the E editor,
"   which was a port of Wimer Hazenberg's Monokai theme for TextMate.
" This has some nice qualities to it, but it uses a light grey
" background in lieu of a black background, which makes it all
" washed out and hard to read for files with lots of comments (like
" this one).  Apparently that was added by HSM...
" Note: this repo has been abandonware since 2015.
"Plug 'tomasr/molokai'
    " Don't use HSM's background color.
    "let g:molokai_original=1
    " Try some different cterm colors.
    "let g:rehash256=1
"
" TODO: Don't really like this one, but the code seems to have some
"   worthwhile things to look at.
"Plug 'mhartington/oceanic-next'
"
" Vim port of Atom's Seti theme by Jesse Weed.
" If we like this, then consider also:
"   <https://github.com/willmanduffy/seti-iterm>
"Plug 'trusktr/seti.vim'

"Plug 'luochen1990/rainbow'
"Plug 'mhinz/vim-janah'


" ~~~~~ Lines: Statusline, Tabline, etc. ~~~~~~~~~~~~~~~~~~~~~~~ {{{2
Plug 'vim-airline/vim-airline'
" TODO: this is one of the slower ones to load. Is there a way to
" guard it to only load the g:airline_theme we actually want/use?
Plug 'vim-airline/vim-airline-themes'
" The following is necessary for the pretty airline wedges; but
" doesn't seem to work well on OSX/iTerm2 (see notes below).
" For Monaco, things are tricky; cf.,
"     <https://github.com/powerline/fonts/pull/16>
"     <https://powerline.readthedocs.io/en/latest/installation/osx.html>
"     <https://gist.github.com/epegzz/1634235>                " 2012
"     <https://gist.github.com/baopham/1838072>               " 2014
"     <https://gist.github.com/rogual/6824790627960fc93077>   " 2014
"     <https://gist.github.com/kevinis/c788f85a654b2d7581d8>  " 2015
"     <https://github.com/robbyrussell/oh-my-zsh/issues/2869> " 2014
"     <https://github.com/powerline/fonts/issues/44> " The core ticket.
" N.B., be sure to set both the ASCII and non-ASCII fonts in iTerm2.
"Plug 'powerline/fonts', { 'do': './install.sh' }

"Plug 'bling/vim-bufferline'


" ~~~~~ Buffers & Tabs (other than their lines) ~~~~~~~~~~~~~~~~ {{{2
"   Originally I linked to 'weynham' version; but this one seems
"   newest (albeit still last changed in 2016).  Maybe also check
"   out 'arenieri' fork, for a few different patches.  If we like
"   it and it seems necessary, then we could may yet another fork
"   to try integrating changes from the hundreds of other forks.
"Plug 'brailsmt/vim-plugin-minibufexpl'
"   Delete buffers & close windows without ruining layout!
"Plug 'moll/vim-bbye'


" ~~~~~ Git & other VCSes ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{2
Plug 'airblade/vim-gitgutter', wrengr#plug#Cond(has('signs'))
"   Like gitgutter, but for several VCSes
"Plug 'mhinz/vim-signify',
"   \ (has('nvim') || has('patch-8.0.902')) ? {} : { 'tag': 'legacy' }
" HACK: Signify's README.md is wrong, 'legacy' is a 'tag' not a 'branch'.
" TODO: should we add {'tag':'stable'} for the async case?
"   let g:signify_vcs_list = ['git', 'hg', 'darcs']
"   let g:signify_difftool = 'gnudiff'      " for darcs to use -U0 flag
" HACK: to get Signify to work at google,
" (1) `let g:signify_disable_by_default=1` to circumvent <b/26261118>
"     (see #comment32 #comment41)
" (2) don't use 'perforce' in g:signify_vcs_list; instead add our
"   own entries to g:signify_vcs_cmds, g:signify_vcs_cmds_diffmode,
"   etc, so as to use <go/citcdiff> in lieu of p4's diff for better
"   performance.
"
"Plug 'ludovicchabant/vim-lawrencium' " like vim-fugitive, but for Mercurial
"Plug 'junegunn/vim-github-dashboard'
"   let g:github_dashboard = { 'username': 'wrengr' }
"Plug 'tpope/vim-fugitive'
"Plug 'int3/vim-extradite'
"   Automatically set &wildignore from .gitignore
"   (This one is much better maintained than the old 'vim-scripts/gitignore')
"Plug 'octref/RootIgnore'
"   Just the function gitbranch#name() but implemented smartly.
"   For a clever use, see: <https://github.com/mhinz/vim-startify/wiki/Example-configurations>
"Plug 'itchyny/vim-gitbranch'


" ~~~~~ File-tree browsing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{2
"Plug 'scrooloose/nerdtree',         { 'on': 'NERDTreeToggle' }
"Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
"Plug 'justinmk/vim-dirvish'  " Alternative to nerdtree.
"Plug 'Shougo/vimfiler.vim'   " Alternative to netrw (end-of-life => defx.nvim)
"Plug 'Shougo/defx.nvim'      " Alternative to netrw (Vim 8.2 | Nvim 0.4.0)
"Plug 'tpope/vim-vinegar'     " Enhancing netrw to obviate nerdtree.
"Plug 'eiginn/netrw'          " In case we want newer than the built-in version.
    " netrw versions:       Comes with:
    " 165  (2019 Jul 16)    Debian vim 8.1.2269    (2018 May 18)
    " 171e (2020 Dec 15)    'eiginn/netrw' f665b0d (2020 Dec 27)


" ~~~~~ Searching ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{2
" Of the main three: Ctrl-P is the oldest and requires the least
" configuration; command-t uses a custom C implementation tightly bound
" to vim; and fzf is the newest, with a custom Go implementation that
" works for any text stream.

"Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
"  Plug 'junegunn/fzf.vim'              " Better default wrappers for fzf.
"Plug 'Shougo/unite.vim'
"Plug 'ctrlpvim/ctrlp.vim'
"Plug 'wincent/command-t'
    " N.B., command-t's wildignore works differently than vim's builtin:
    " <https://github.com/octref/RootIgnore/issues/5>
    " <https://github.com/wincent/command-t/blob/7364a410bc4f0d7febc183678cd565066dfd1e73/doc/command-t.txt#L1102>
"Plug 'rking/ag.vim'                    " use :Ag instead of :grep
"Plug 'vim-scripts/IndexedSearch'
"Plug 'vim-scripts/SmartCase'
"Plug 'vim-scripts/gitignore'


" ~~~~~ Undoing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{2
"Plug 'sjl/gundo.vim'
"Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' } " [#jg]
"Plug 'simnalamburt/vim-mundo'          " Undo tree visualizer


" ~~~~~ Alignment, Indentation, & Folding ~~~~~~~~~~~~~~~~~~~~~~ {{{2
"Plug 'godlygeek/tabular'
"Plug 'junegunn/vim-easy-align'
"Plug 'michaeljsmith/vim-indent-object' " adds text objects `ii` / `ai`
"Plug 'vim-scripts/Align'
"Plug 'Yggdroot/indentLine', { 'on': 'IndentLinesEnable' } " [#jg]
    " junegunn uses:
    "autocmd wrengr_vimrc User indentLine doautocmd indentLine Syntax
    "let g:indentLine_color_term = 239
    "let g:indentLine_color_gui = '#616161'
    " Though we'll want to adapt that to our colorscheme.

"   For more reliable indenting and performance
"   (&fdm=syntax is notoriously slow)
"Plug 'Konfekt/FastFold'
  "set foldmethod=indent
  "set fillchars='fold: '


" ~~~~~ Simple text editing. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{2
" Limelight and Goyo go really well together; though neither strictly
" requires the other.  However, whenever the limelight module is
" loaded, it slows scrolling down (namely when crossing paragraph
" boundaries) even when the `:Limelight` mode is currently disabled.
" Thus we guard to make sure we only ever load these modules at the
" point where we explicitly want to enable their special modes.
"
" Limit colorization to local paragraphs/hunks.
Plug 'junegunn/limelight.vim',  { 'on': 'Limelight' }
" Reduce distractions, a~la OmmWriter.
Plug 'junegunn/goyo.vim',       { 'on': 'Goyo' }


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Language-Generic Programming Support ~~~~~~~~~~~~~~~~~~~ {{{2

" ~~~~~ LSP (and asynchronicity)                                 {{{3
" Normalize async job control api for vim and neovim.
Plug 'prabirshrestha/async.vim'
" A well weathered LSP implementation for vim.
Plug 'prabirshrestha/vim-lsp'
"Plug 'mattn/vim-lsp-settings'
" TODO: may also consider 'natebosch/vim-lsc'
" (doesn't conflict to have both vim-lsp and vim-lsc enabled at once)

" Some other/older things in a similar vein:
" (from: <https://github.com/vim-syntastic/syntastic/issues/699>)
"Plug 'tpope/vim-dispatch'
"Plug 'Shougo/vimproc.vim', { 'do': 'make' }
" <https://github.com/xolox/vim-misc/blob/8551f2b9dec7fd17dd5c3476d7869957185d692d/autoload/xolox/misc/os.vim#L82>
" <https://github.com/vim-syntastic/syntastic/issues/699#issuecomment-61709028>


" ~~~~~ Auto-completion                                          {{{3
" N.B., YCM is basically a full-fledged IDE; so it's probably never
" something we'd actually enjoy.
"Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
" TODO: why did we use 'Valloric' here rather than 'ycm-core' ?
" Warning: <$VIMPLUG_URL/wiki/faq#youcompleteme-timeout>
"Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
" or maybe: { 'do': './install.sh --gocode-completer --tern-completer' }

"Plug 'ervandew/supertab'

" TODO: if we switch to neovim (or get Vim 8.1/8.2 installed), then
" consider 'Shougo/deoplete.nvim' or 'Shougo/ddc.vim' as an alternative
" to asyncomplete.  See ~/.vim/NOTES-autocompletion.txt for more info.

"Plug 'prabirshrestha/asyncomplete.vim'
"  Plug 'prabirshrestha/asyncomplete-lsp.vim'   " for: 'prabirshrestha/vim-lsp'
"  Plug 'prabirshrestha/asyncomplete-necovim.vim'    | Plug 'Shougo/neco-vim'
"  Plug 'prabirshrestha/asyncomplete-necosyntax.vim' | Plug 'Shougo/neco-syntax'


" ~~~~~ Ctags (:help usr_29)                                     {{{3
" For additional help on ctags, see also:
"   <http://www.oualline.com/vim/10/top_10.html>
"   <https://andrew.stwrt.ca/posts/vim-ctags/>
"
" Browse ctags of current file, organized by scope.
" (N.B., despite the name, it is not a "line")
"Plug 'majutsushi/tagbar', wrengr#plug#Cond(has('patch-7.3.1058'), { 'on': 'TagbarToggle' }) " [#jg]
"   let g:tagbar_sort = 0
"Plug 'prabirshrestha/asyncomplete-tags.vim', wrengr#plug#Cond(executable('ctags'))
"  Plug 'ludovicchabant/vim-gutentags',       wrengr#plug#Cond(executable('ctags'))
"Plug 'grassdog/tagman.vim'
"Plug 'xolox/vim-easytags'
"   <https://ctags.io/>     "Universal Ctags" (much better than "Exuberant")
"   <https://github.com/sergioramos/jsctags>
"   <https://github.com/vim-php/phpctags>


" ~~~~~ Linting                                                  {{{3
"Plug 'vim-syntastic/syntastic'
"   Ones mentioned/recommended by Syntastic:
"   (I'm using 'for' here mainly for documentation purposes)
"Plug 'Quramy/tsuquyomi',   { 'for': 'typescript' } " Better than `tsc`
"Plug 'lilyball/vim-swift', { 'for': 'swift' }      " Better than `xcrun`
"Plug 'arrufat/vala.vim',   { 'for': 'vala' }       " Includes `valac`
    " Vala is Gnome's C-like OOP language (akin to ObjectiveC)
" Warning: at least historically, syntastic tends to trigger a lot
" of bugs in ncurses or similar, for more info on how to debug these
" problems, see: <https://github.com/vim-syntastic/syntastic/issues/822>
" Re iTerm2, see also:
"   <https://github.com/vim-syntastic/syntastic/issues/1068>
"   <https://github.com/vim-syntastic/syntastic/issues/2370>
" Re demonstrating that it's not a plugin problem, see:
" <https://github.com/vim-syntastic/syntastic/issues/1068#issuecomment-41939158>
"
" N.B., scrooloose is not the best goto anymore for this, I'm not
" sure whether vim-syntastic still is or if there's something newer, but see:
" <https://github.com/vim-syntastic/syntastic/issues/699#issuecomment-255338765>
" <https://github.com/vim-syntastic/syntastic/issues/1905>
"
" An alternative language-generic infrastructure for linting.
" (Cf., <https://github.com/vim-syntastic/syntastic/issues/699#issuecomment-284994550>
" and <https://github.com/ErikBjare/dotfiles/commit/2b946b5d0f95ba056ce99bf0487c3ff414ce3c51>)
"Plug 'w0rp/ale'


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Specific Programming Languages ~~~~~~~~~~~~~~~~~~~~~~~~~ {{{2

" Note: Assuming none of the language-specific things below need
" 'for', unless otherwise noted.
" Note: using tags to abbreviate what each thing does:
"   Exec        -- to give relevant github urls for executables.
"   [#syntax]   -- syntax for highlighting
"   [#indent]   -- indentation for syntax
"   [#complete] -- autocompletion
"   [#lint]     -- linters, their refactoring tools, and code formatters.
"   [#test]     -- code testing utilities
"   [#misc]     -- anything else.
" TODO: actually clean up all that tag nonsense


" ~~~~~ {for: vim} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
"Exec 'Vimjas/vint'             " [#lint] 'vint' for syntastic.
"Plug 'junegunn/vader.vim'      " [#test] unit-testing.


" ~~~~~ {for: haskell} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
" TODO: cf.,
"   <https://www.reddit.com/r/haskell/comments/67384o/how_do_you_haskell_in_vim/>
"   <http://www.stephendiehl.com/posts/vim_2016.html>
"   <https://github.com/begriffs/haskell-vim-now>
" TODO: need to go through and try each of these to see which I
"   actually like ::sigh::
"
" ~~~~~ [#syntax] [#indent]
" An improvement over the default; though maybe still crap.
"Plug 'vim-scripts/haskell.vim'
"
" This isn't entirely what I want, but seems workable for now.
"   (By raichoo, inspired by idris-vim.)
Plug 'neovimhaskell/haskell-vim'
  "   Link things to Keyword not to Structure.
  let g:haskell_classic_highlighting=1
  "   Yes please keep support for TH.
  let g:haskell_disable_TH=0
  "   Maybe one day we'll use backpack.
  "let g:haskell_backpack=1
  "   Enable all the syntax groups we use.
  let g:haskell_enable_quantification=1
  let g:haskell_enable_typeroles=1
  let g:haskell_enable_pattern_synonyms=1
  "   Other syntax groups we may use eventually.
  "let g:haskell_enable_static_pointers=1
  "let g:haskell_enable_recursivedo=1
  "let g:haskell_enable_arrowsyntax=1
"
" raichoo suggests this alternative if we don't like his version above.
"Plug 'alx741/vim-hindent'
"
" In lieu of the default thing, which is awful.
"Plug 'itchyny/vim-haskell-indent'

" ~~~~~ Other Haskell supports
" [#lint]
"   In lieu of syntastic.
"Plug 'eagletmt/ghcmod-vim'
"   Use 'mpickering/apply-refact' to apply hlint suggestions.
"Exec 'mpickering/apply-refact'
"Plug 'mpickering/hlint-refactor-vim',
"   \wrengr#plug#Cond(executable('refactor') && executable('hlint'))
"   Use 'haskell/stylish-haskell' for code formatting.
"Exec 'haskell/stylish-haskell'
"Plug 'nbouscal/vim-stylish-haskell',
"   \wrengr#plug#Cond(executable('stylish-haskell'))
" [#complete]
"   This is described as 'ghc-mod/hhpc completion for
"   neocomplcache/neocomplete/deoplete'.  So I'm not sure if it'll
"   work properly with asyncomplete, or if it really requires deoplete &c.
"Plug 'eagletmt/neco-ghc'
" [#misc]
"   Code editing helpers
"Plug 'edkolev/curry.vim'
"   Display unicode for symbols, but leave them ascii in the files.
"Plug 'enomsg/vim-haskellConcealPlus'
"   Query local Hoogle.
"Plug 'Twinside/vim-hoogle',
"   \wrengr#plug#Cond(executable('hoogle'))
    " Though you can configure g:hoogle_search_bin to look elsewhere


" ~~~~~ HDLs ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
" [#syntax]
" TODO: not so sure I trust these to not need the 'for'...
" TODO: need to make these play nice with Coq, since both use *.v
Plug 'mtikekar/vim-bsv',               { 'for': 'bsv' } " For BSV, not for BS!!
"Plug 'hanw/vim-bluespec',             { 'for': 'bsv' } " Another BSV plugin
"Plug 'michaeltanner/vim-bluespec',    { 'for': 'bsv' } " Yet another BSV
Plug 'nachumk/systemverilog.vim',      { 'for': 'systemverilog' }
Plug 'vhda/verilog_systemverilog.vim', { 'for': 'verilog_systemverilog' }
" A hack for Classic BlueSpec. Would be nice to have a real thing here...
if has('autocmd')
  " TODO: Like the other &ft setting autocmds below, we really should
  " move this off to a more appropriate place in ~/.vim/ftdetect
  autocmd wrengr_vimrc BufRead,BufNewFile *.bs set ft=haskell
endif


" ~~~~~ LLVM/MLIR ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
" The LLVM project itself provides the following plugin for syntax
" highlighting MLIR files:
"   <https://github.com/llvm/llvm-project/blob/main/mlir/utils/vim/>
" However, they don't have one for LLVM nor for TableGen ('.td'); at
" least nowhere in the history of the github monorepo, however they did
" used to have some.  One version is archived at:
"   <https://github.com/llvm-mirror/llvm/blob/master/utils/vim/syntax/tablegen.vim>
" and there are a few forks out there, like 'antiagainst/vim-tablegen'
" and more recently
"   <https://courchinoux.org/gaspard/chiara64-llvm/-/blob/master/utils/vim/syntax/tablegen.vim>
" But we'll use a newer version below.
"
" Since we already have a copy of the whole 'llvm/llvm-project' repo,
" we could always tell vim-plug to use the appropriate directory as an
" "unmanaged plugin" (i.e., one that we manually update, rather than
" one vim-plug is allowed to update).  The incantation for that is to
" use a path specifically beginning with the '~' character:
"Plug '~/src/llvm-project/mlir/utils/vim'
"
" This repo has all three of: syntax/{llvm.vim, mlir.vim, tablegen.vim}
" It also has ftdetect/llvm-lit.vim; as well as some ./scripts.vim thing
" that says to see `:help new-filetype-scripts`
" Bugginess:
" * They don't do #includes and other PreProc
" * Also they seem to be standardly bad about not parsing any identifiers,
"   but worse than usual b/c not doing types either!
" So, definitely need to fork it and make improvements; but at least
" it's a place to start.
Plug 'rhysd/vim-llvm'


" ~~~~~ {for: markdown} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
" TODO: given the 'markdown' vs 'markdown.pandoc' distinction, it's
"   unclear whether I can reliably leave out the 'for' for these...

"Plug 'godlygeek/tabular' | Plug 'plasticboy/vim-markdown'
" <https://stackoverflow.com/questions/10964681/enabling-markdown-highlighting-in-vim>
" N.B., some version of 'tpope/vim-markdown' is installed by default
" on Vim 8.0; Though I'm not sure how outdated that version is compared
" to the repo.
"Plug 'tpope/vim-markdown'
"Plug 'mzlogin/vim-markdown-toc'
"   The following two were cribbed from junegunn's vimrc, so edit
"   as necessary/desired.
"Plug 'junegunn/vim-xmark', wrengr#plug#Cond(has('mac')) " BUG: has('mac') is unreliable!
    " N.B., vim-xmark requires Homebrew and Chrome; so we'll probably
    " just stick with using <https://github.com/joeyespo/grip>
    " Also, vim-xmark is noted as being unmaintained, with a
    " recommendation to use 'iamcco/markdown-preview.nvim' instead
    " (even though junegunn still uses vim-xmark)
"Plug 'ferrine/md-img-paste.vim'
"  autocmd wrengr_vimrc FileType markdown
"    \ nnoremap <buffer> <silent> <leader>v
"    \ :call mdip#MarkdownClipboardImage()<CR>
"  let g:mdip_imgdir = 'images'
"  let g:mdip_imgname = 'image'
"if v:version >= 800 && !(has('win32') || has('win64'))
"  Plug 'iamcco/markdown-preview.nvim',
"    \ { 'do': ':call mkdp#util#install()'
"    \ , 'for': 'markdown'
"    \ , 'on': 'MarkdownPreview' }
"  Plug 'neoclide/coc.nvim',
"    \ {'branch': 'release', 'do': { -> coc#util#install() }}
"endif
" ~~~~~ {for: markdown.pandoc} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"Plug 'vim-pandoc/vim-pandoc'
"Plug 'vim-pandoc/vim-pandoc-syntax'



" ~~~~~ {for: applescript} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
" [#syntax]
" This particular fork seems a lot more complete than the original
" vim-scripts/applescript.vim; however, it's still not the greatest.
" In part because they use Statement for all the keywords (alebeit
" Keyword just links to Statement).
Plug 'vito-c/applescript.vim'

" ~~~~~ {for: [c, cpp]} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
" [#syntax]
" Supposedly this is halfway decent, but it barely does anything (even
" with the various globals enabled).
" BUG: beware of things like <https://githubmemory.com/repo/bfrg/vim-cpp-modern/issues/4>
" BUG: also, this *only* does after/syntax (so does the octol version)
" Looking at the file, they do define a bunch of :syntax, so I'm guessing
" the complete lack of highlighting is just because none of those groups
" are ever linked to the appropriate highlight groups.  They do have some
" `:hi def link` but not very many.
Plug 'bfrg/vim-cpp-modern'
  " Trying some of the flags they mention for actually highlighting things:
  " Contradicting the documentation, this is *only* checked for C, not C++!
  "let g:cpp_function_highlight=1
  let g:cpp_member_highlight=1
  " These are checked for both:
  let g:cpp_simple_highlight=1
  " These are only checked for C++
  let g:cpp_attributes_highlight=1
  " They also check a bunch of options 'cpp_no_cppXX' where XX is the
  " various cpp years; However, if those do exist there's nothing that
  " highlights the given constructs as being errors.
  " TODO: see also <https://idie.ru/posts/vim-modern-cpp>

" This version is the upsteam of 'bfrg/vim-cpp-modern' but it does a lot
" more despite not having been touched in years.  Also, junegunn still uses
" this one.  It still needs a lot of improvement, but it's better at least.
"Plug 'octol/vim-cpp-enhanced-highlight'

" [#complete]
"Plug 'keremc/asyncomplete-clang.vim'
"   " N.B., the original 'keremc' proclaims it's not ready for
"   " general use; and was last updated in 2017.  Whereas the
"   " 'wsdjeg' fork is a couple commits ahead (last updated 2018),
"   " and removed that warning, though it's for SpaceVim rather
"   " than plain Vim.

" ~~~~~ {for: clojure} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
" All of this was copied from junegunn's vimrc
"Plug 'kovisoft/paredit', { 'for': 'clojure' } " [#jg]
"   let g:paredit_smartjump = 1
"Plug 'tpope/vim-fireplace', { 'for': 'clojure' } " [#jg]
"Plug 'guns/vim-clojure-static'
"   let g:clojure_maxlines = 60
"   set lispwords+=match
"   let g:clojure_fuzzy_indent_patterns = ['^with', '^def', '^let']
"Plug 'guns/vim-clojure-highlight'
"Plug 'guns/vim-slamhound'

" ~~~~~ {for: coq} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
" [#syntax]
Plug 'jvoorhis/coq.vim'

" ~~~~~ {for: go} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
"Plug 'fatih/vim-go', wrengr#plug#Cond(v:version >= 800, { 'do': ':GoInstallBinaries' })
    "let g:go_fmt_command = 'goimports'
"Plug 'nsf/gocode', { 'rtp': 'vim', 'do': s:vimplug_dir . '/gocode/vim/symlink.sh' }

" ~~~~~ {for: javascript} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
"Plug 'moll/vim-node'
"Plug 'pangloss/vim-javascript'

" ~~~~~ LaTeX ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
" N.B., LaTeX files show up as &ft=tex
" omg this looks nice
"Plug 'LaTeX-Box-Team/LaTeX-Box'

" ~~~~~ {for: python} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
"Plug 'jmcantrell/vim-virtualenv'   " for Python virtualenvs (what about venv?)
"Plug 'tmhedberg/SimpylFold'        " Fancy folding so you can still see docstrings

" ~~~~~ {for: ruby} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
"Plug 'tpope/vim-bundler', { 'for': 'ruby' } " [#jg]

" ~~~~~ {for: rust} ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{3
" [#lint] includes `rustc` for syntastic.
" Though it probably does syntax et al too...
"Plug 'rust-lang/rust.vim'
" [#complete]
"Plug 'keremc/asyncomplete-racer.vim' | Plug 'racer-rust/racer'
"   " N.B., racer has been obsoleted by <https://rust-analyzer.github.io>
" [#misc]
"   Display unicode for symbols, but leave them ascii in the files.
"Plug 'rektrex/vim-conceal-rust'


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ To be sifted through                                     {{{2

" ~~~~~ Tmux & GNU Screen                                        {{{3
"Plug 'edkolev/tmuxline.vim'
"Plug 'sjl/vitality.vim'                " for iTerm2 (+ tmux)
"Plug 'christoomey/vim-tmux-navigator'  " Navitate freely between tmux and vim
" <https://gist.github.com/mikeboiko/b6e50210b4fb351b036f1103ea3c18a9>

" ~~~~~ Snippets                                                 {{{3
"Plug 'SirVer/ultisnips', wrengr#plug#Cond(v:version >= 704)
"    Plug 'honza/vim-snippets'
"Plug 'garbas/vim-snipmate'             " TextMate-like snippet features


" ~~~~~ Completely unsifted                                      {{{3
"Plug 'tpope/vim-sensible'              " More-sensible defaults
"Plug 'tomtom/quickfixsigns_vim'
"Plug 'gcmt/taboo.vim'
"Plug 'vim-ctrlspace/vim-ctrlspace'
"Plug 'edkolev/promptline.vim'
"Plug 'bling/minivimrc'
" ~~~~~ cf., <https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/>
" and <https://github.com/sheerun/dotfiles/blob/master/vimrc>
" and <https://github.com/sheerun/vimrc>
" and <https://github.com/vmchale/dotfiles/blob/master/.vimrc>
" and <https://github.com/Xe/dotfiles/blob/master/.vimrc>
" and <https://github.com/wklken/k-vim/blob/master/vimrc>
" and <https://github.com/amix/vimrc/blob/master/vimrcs/basic.vim>
" and <https://github.com/nicdumz/dotfiles/blob/master/.vimrc>
" and <https://github.com/AntJanus/my-dotfiles/blob/master/.vimrc>
" and <https://github.com/sunaku/.vim> re neovim
"Plug 'wellle/targets.vim'
"Plug 'sheerun/vim-polyglot'
"Plug 'terryma/vim-expand-region'
"Plug 'tomtom/tcomment_vim'
"Plug 'tpope/vim-rsi'
"Plug 'tpope/vim-endwise'
"Plug 'tpope/vim-repeat'                " better <.> repetition support
"Plug 'tpope/vim-sleuth'
"Plug 'tpope/vim-unimpaired'
"Plug 'tpope/vim-commentary'
"Plug 'tpope/vim-scriptease'            " Metatooling for writing plugins
"Plug 'danro/rename.vim'                " Allow to :Rename files
"Plug 'flowtype/vim-flow'
"Plug 'airblade/vim-rooter'             " Automatically find project's root dir
  "let g:rooter_disable_map = 1
  "let g:rooter_silent_chdir = 1
"Plug 'AndrewRadev/splitjoin.vim'       " Expand / wrap hashes etc.
"Plug 'ashisha/image.vim'               " View images as ASCII art
" Some other stuff from <http://www.stephendiehl.com/posts/vim_2016.html>
"Plug 'tomtom/tlib_vim'                 " Some kind of utility functions...
"Plug 'MarcWeber/vim-addon-mw-utils'
"Plug 'scrooloose/nerdcommenter'
"Plug 'sk1418/Join'                     " A hopefully better :Join command
"Plug 'mhinz/vim-startify'
    " N.B., if you follow `:h startify-faq-17` then you'll get
    " interaction problems with Goyo:
    " <https://github.com/mhinz/vim-startify/wiki/Known-issues-with-other-plugins>
"Plug 'kana/vim-fakeclip'               " Emulate '+clipboard'
"Plug 'nacitar/terminalkeys.vim'        " Improved support for rxvt
    " See also 'godlygeek/vim-files'
call plug#end()
unlet s:vimplug_dir


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Unicode support                                          {{{1
" Note: if the occurrence of the utf8 characters below glitches out
" the cursor, then you probably need to adjust your terminal; since
" the glitch means that vim and the terminal are disagreeing about
" where the cursor actually is after printing the characters.
" (I.e., your terminal thinks they are typographically wide, taking
" up two columns; when in fact they should only take up one column.)
if has('multi_byte')
  scriptencoding utf-8
  set encoding=utf-8
  set termencoding=utf-8
  set fileencodings=ucs-bom,utf-8,latin1

  " Enable &list to visualize invisible characters (<Tab>, nbsp,
  " EOL, etc), where the visualizations are defined in &listchars.
  " Note: &list is incompatible with &linebreak, and enabling &list
  " will override &linebreak's setting.  This highly unexpected
  " behavior has been deemed 'a feature':
  "   <https://groups.google.com/forum/#!topic/comp.editors/blelxLchTPg>
  " Note: Older versions of Vim are varyingly buggy about their
  " support for specific unicode characters.  For example, 6.2 is
  " okay with '»·¶' but buggy about '→←×'.  (The latter three were
  " fixed sometime before 7.0)  So far I haven't had any issues in 8.0
  " Note: for help debugging unicode shenanigans, check out `:h ga`
  " and <https://vi.stackexchange.com/a/560>.
  " TODO: if we ever actually want &list in lieu of &linebreak,
  " some other fun characters to consider are '➜' (U+279C) and '➻'
  " (U+27BB); though it seems like neither has a leftward variant
  " (and the second one looks much better in larger fonts).
  set listchars=tab:»\ ,trail:·,eol:¶,extends:→,precedes:←,nbsp:×

  " If you want to change the color they show up as, &listchars are
  " highlighted as SpecialKey.
endif


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Terminal configuration issues ~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{1
" ~~~~~ GNU Screen integration                                   {{{2
" <http://vim.wikia.com/wiki/GNU_Screen_integration>
" <https://github.com/mileszs/dotfiles/blob/master/screenrc>
" Actually that got deleted, so go back to this commit:
" <https://github.com/mileszs/dotfiles/blob/3883ca1d8f54b858f9c28599b5304eadae184743/screenrc>

"if $TERM =~? '^screen'
  " Disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " Cf., <http://snk.tuxfamily.org/log/vim-256color-bce.html>
  " (which now redirects to: <https://sunaku.github.io/vim-256color-bce.html>)
  "if &term =~? '256color'
  "  set t_ut=
  "endif

  " Fix <S-Tab> on GNU screen.  HT: <https://superuser.com/a/196162>
  " terminfo 'cbt' == vim &t_bt; terminfo 'kcbt' == vim &t_kB
  "set t_kB=[Z

  " Disable <C-a> when in GNU screen (not that we use it much anyways).
  "nnoremap <C-a> <Nop>
"endif

" TODO: the altscreen thing seems to occasionally fail and leave
" gibberish on the screen when we quit vim (especially after using
" a lot of `:!` or `:redir` commands); so we may want/need to much
" around with &t_te (and &t_ti).  See `:help xterm-screens` and
" <https://invisible-island.net/xterm/xterm.faq.html#xterm_tite>

" Note On TERM: some people like <https://blog.sanctum.geek.nz/term-strings/>
" think that this whole approach is totally wrongheaded.  In principle
" I agree, however in practice it's terribly convoluted to do the
" right thing.  See also <https://gist.github.com/KevinGoodsell/744284/717b220f7c168725748781d58609dce5d7cf8603>
" which offers some particular solutions for dealing with screen.
" Another source of hints on debugging this kind of stuff is
" <https://github.com/vim-syntastic/syntastic/issues/822>
" (while that bug is old and closed, it has helpful info.)



" Extend <C-l> to also stop highlighting the current search.
" N.B., the default <C-l> can also be lazy (both with and without
" &lazyredraw), so this is (I think) stricter about ensuring the
" redraw happens immediately.
nnoremap <silent> <C-l> :noh<CR>:redraw!<CR>

" Note: there also exists commands :redrawstatus[!] and :redrawtabline


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Terminal title                                           {{{2
" <http://vim.wikia.com/wiki/Automatically_set_screen_title>
" <http://usevim.com/2012/06/13/set-title/>
if has('title')
  " BUG: many times screen doesn't set TERM to say that; and
  " even when it does, our ~/.bash_profile changes it.  Frankly,
  " if we're going to do this then we might as well set these in
  " the ~/.screenrc itself.
  " See also the [Note On TERM] above.
  if &term =~? '^screen'
    set t_ts=^[k
    set t_fs=^[\
  endif
  set title
  " BUG: how do we cause &modified to be formatted like it is in
  " the default?  (as opposed to being formatted like "[+]" plus
  " a bunch of space, I mean.)
  " BUG: how do we get help pages to show up as appropriate,
  " rather than actually giving the path to the file where they're
  " stored?
  " N.B., the list of codes is at `:help statusline` not at the
  " helppage for titlestring
  "set titlestring=VIM\ %-25.55F\ %a%r%m
  set titlestring=VIM\ \ %t\ (%{expand(\"%:~:.:h\")})\ %a%r%m
  set titlelen=70
endif


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Mouse support                                            {{{2

" Setting this will make it so that selecting things with the mouse
" doesn't grab the numbers (etc) in the gutter!
" <http://vim.wikia.com/wiki/Using_the_mouse_for_Vim_in_an_xterm>
" BUG: alas, it seems to break something about using the OSX clipboard...
" <http://unix.stackexchange.com/q/139578>
"set mouse=a   " Copy/paste in "* register, normal behaviour with shift key pressed
"set mousehide " Hide mouse while typing

" TODO: If we really want to go the mouse route, consider:
"if has('mouse')
"  (1) <https://iterm2.com/faq.html>
"  if has('mouse_sgr')
"    set ttymouse=sgr
     " Note: On iTerm2 (3.4.9beta1) we automatically get mouse
     " support and &ttymouse=sgr, without actually doing anything
     " here.  Dunno when that happened nor what terminfo shenanigans
     " it required, but it's nice :)
"  (2) <http://usevim.com/2012/05/16/mouse/>
"  elseif has('mac') " BUG: has('mac') is unreliable! (see above)
"    set ttymouse=xterm2
"  else
"    ...
"  endif
"endif
" (3) <https://github.com/nvie/vim-togglemouse>
" (4) <http://unix.stackexchange.com/q/44513> re Gnome terminal bugginess


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Colorscheme                                              {{{1
if has('syntax') && (&t_Co > 2 || has('gui_running'))
  " N.B., must enable syntax before loading the colorscheme.
  " Also, see the helpfiles for :syn-enable vs :syn-on and how
  " they relate to colorschemes.
  syntax enable

  " N.B., the &background setting is intended to _inform_ Vim of
  " what the terminal's actual default hue is, not to set/change
  " the color scheme used by Vim.  This setting is hooked so that
  " whenever it's changed it'll cause the colorscheme to be reloaded.
  " When the colorscheme is (re)loaded, it will read the &background
  " setting and do one of two things: (1) load appropriate colors,
  " (2) revert the &background to its previous setting-- which Vim
  " takes to mean that the colorscheme cannot support the terminal's
  " &background, and therefore Vim will change the colorscheme to the
  " default one (which supports all &background settings, so will do
  " the right thing).  However, N.B., even though Vim resets to the
  " default colorscheme so as to get visible colors, it seems like
  " Vim doesn't re-revert the &background setting to whatever you
  " originally set it to; thus reading the &background setting after
  " falling down this path will give unreliable answers.  Moreover,
  " N.B., this hooking action will only adjust the 'default color
  " groups', it will _not_ adjust 'colors used for syntax highlighting'!
  " Thus, first loading a colorscheme and subsequently changing the
  " &background to something the colorscheme doesn't support, will
  " result in a bizarre mishmash of colors.
  " cf., <https://vi.stackexchange.com/a/13089>
  " <http://peterodding.com/code/vim/colorscheme-switcher/#known_problems>
  set background=dark

  " WIP: using my own new colorscheme
  " TODO: May also want to take a look at the source code for:
  "   <https://github.com/nanotech/jellybeans.vim/blob/master/colors/jellybeans.vim#L58>
  "   <https://github.com/mhartington/oceanic-next>
  " BUG: if our colorscheme `:throw` an exception, then that'll
  " somehow cause a syntax error in this file thereby causing the
  " rest of everything in this file to be ignored!  This is unlike
  " an internal exception (e.g., parsing error) which will only kill
  " the colorscheme module, rather than also killing us here.  WTF?
  colorscheme overmorrow
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

" TODO: possibly consider using
" <http://www.vim.org/scripts/script.php?script_id=1641> in order
" to avoid needing to push setting colorscheme all the way to the
" top like this.

" Also maybe try running `:runtime syntax/colortest.vim`

" TODO(2021-08-11): <https://github.com/mhartington/oceanic-next> suggests:
"if v:version >= 800 && has('termguicolors')
"  set termguicolors
"elseif v:version >= 700
"  set t_Co=256
"endif


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Cursor colors                                            {{{1
" N.B., apparently &cursorline causes slowness over ssh. So maybe
" consider disabling it when working remotely.
if has('syntax')
  set cursorline         " highlight the whole line the cursor is on
  " TODO: &cursorlineopt=number,line
  "set cursorcolumn      " highlight the whole column the cursor is on
  " TODO: consider: Only show cursor line/column in the focused window.
  "if has('autocmd')
  "  augroup cursor_linecolumn
  "    au!
  "    au WinLeave * setlocal nocursorline nocursorcolumn
  "    au WinEnter * setlocal cursorline cursorcolumn
  "  augroup END
  "endif
endif

" TODO: something fancy like <http://vim.wikia.com/wiki/Configuring_the_cursor>.
" N.B., setting &t_SI and &t_EI tends to cause the cursor to glitch out
" (using <C-l> fixes it). And it's highly terminal-dependent, so...


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Lines: cmdline, statusline, tabline                      {{{1
set showcmd             " Show the cmdline (cuz we're not still in the 1970s).
set cmdheight=1         " The cmd-*line*   is N rows high.
"set cmdwinheight=7     " The cmd-*window* is N rows high.
set noshowmode          " Don't show the mode in the cmdline
if has('cmdline_info')
  " Show the cursor's line/column position in the statusline (unless
  " &laststatus==1, then show it in the cmdline; or unless &statusline
  " is set, in which case shows the statusline in lieu of the ruler).
  set ruler
  " See also &rulerformat (requires '+statusline', but not '+cmdline_info').
endif

" Always(=2) show statusline, even if there're no splits.
set laststatus=2
" Note: &statusline is taken over by airline; also, requires '+statusline'.


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Columns: linenr, colorcolumn                             {{{1
" ~~~~~ Line numbers                                             {{{2
" BUG: when editing git commit messages, <C-n> gets overridden by
"   some sort of autocomplete thing... (possibly the built-in <C-n>)
" HT: <https://github.com/alialliallie/vimfiles/blob/master/vimrc>
" and <http://jeffkreeftmeijer.com/2013/vims-new-hybrid-line-number-mode/>
nnoremap <silent> <C-n> :call <SID>LineNrToggle()<CR>
fun! s:LineNrToggle()
  " TODO: why did we use `==1` instead of just the option's value?
  if &relativenumber == 1
    set norelativenumber number
  else
    set relativenumber
    if v:version >= 704 | set number | endif
  endif
  call OvermorrowRelinkLineNr()
endfun

set relativenumber
call s:LineNrToggle()


" ~~~~~ Final column                                             {{{2
" N.B., if this glitches out when using non-ASCII characters that
" aren't actually wide (typographically speaking), then you probably
" need to adjust your terminal; since the terminal and vim are
" disagreeing about where the cursor actually is.
" HACK: for whatever strange reason, we must use exists('+colorcolumn')
"   in lieu of has('colorcolumn').  On mayari the former is true
"   whereas the later is false.
if exists('+colorcolumn')
  " N.B., this is the column we highlight, hence should be one
  " more than where we want to wrap. You can also use '+n' to set
  " it automatically based on &textwidth.
  set colorcolumn=81
  " Or, to shade everything beyond 81 instead of only 81 itself:
  "execute 'set colorcolumn=' . join(range(81,335), ',')
  "
  " TODO: or even better, see: <http://stackoverflow.com/a/21406581>
endif


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ General usability ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{1

set backspace=indent,eol,start " Allow backspacing anything (input mode).
"set whichwrap=b,s,<,>,~,[,]   " Backspace and cursor keys wrap too.
" N.B., see <https://github.com/sorin-ionescu/prezto/issues/61>
" this can be reconfigured in iTerm2, but also see `:h :fixdel`

set showmatch           " When inserting brackets, briefly jump to the match

" ~~~~~ Timing                                                    {{{2
"set matchtime=5        " how long (N/10 secs) to &showmatch for.
"set updatetime=4000    " Doing nothing for N millisec will trigger stuff:
    " (1) saving the swapfile to disk,
    " (2) issue CursorHold event on the next keypress (requires keypress!),
    " (3) at least historically, stop highlighting searches (a~la `:noh`)
    " (N.B., gitgutter will set a short &ut below)
"set updatecount=200    " Save swapfile after typing N characters.
"if has('reltime')
"  set redrawtime=2000  " Only allow N millisec for redrawing/&hls.
"endif
"set ttimeout           " Let vim wait for timeouts
"set timeoutlen=3000    " How long does vim wait for mapping sequences
"set ttimeoutlen=100    " How long does vim wait for the end of escape sequence

" ~~~~~ Bells                                                    {{{2
"set belloff=           " Which (non-message) events should never ring the bell?
"set noerrorbells       " Should error messages ring the bell?
"set novisualbell       " Should bells be visual in lieu of beep?
"set t_vb=              " What command code implements visual bells?

" ~~~~~ Diff                                                     {{{2
"if has('diff')
"  " Comma-separated list of settings for diff-mode.
"  set diffopt=internal,filler,closeoff
"  " see also *fold-diff*, *diff-diffexpr*, &diffexpr, &vimdiff, &cursorbind
"endif

" ~~~~~ Scrolling                                                {{{2
set scrolloff=7         " Show N lines in advance when scrolling.
"set sidescrolloff=10   " Columns visible to the left/right of cursor when scrolling
" TODO: see also &scrollbind=no, &scrollopt=ver,jump, *scroll-binding*
" TODO: also &scrollfocus=no, &scrolljump=1
"set window=...         " Used by <C-f> and <C-b>

" TODO: Check out the VCenterCursor() function at:
" <https://vim.fandom.com/wiki/Keep_your_cursor_centered_vertically_on_the_screen>
" It toggles between &so=999 and whatever &so we set normally.
" It also shows how to use autocmd for the OptionSet event, to
" automatically run some code whenever someone changes an option.

" ~~~~~ Buffers                                                  {{{2
" I hate <Q> switching to ex-mode.  Also, I hate that wiping buffers
" also kills the window it's in.  So we remap <Q> to close buffers
" nicely.
nnoremap Q :call wrengr#BufferDelete()<CR>

" ~~~~~ Windows/Splits                                           {{{2
set winheight=20        " Try to keep the active window  at least this tall.
"set winminheight=1     " Try to keep non-active windows at least this tall.
"set winwidth=20        " Try to keep the active window  at least this wide.
"set winminwidth=1      " Try to keep non-active windows at least this wide.

"set equalalways
"set eadirection=both   " Does &ea apply to vertical, horizontal, or both?
"set winfixheight       " If &ea, then keep height fixed when opening/closing.
"set winfixwidth        " If &ea, then keep width  fixed when opening/closing.

"set splitright         " :vs puts the new window (and focus) to the right.
set splitbelow          " :sp puts the new window (and focus) to the bottom.

" TODO: a lot of times I'd really like to do a vertical split where
"   the new window goes to the right, but the focus stays with the
"   old window.  Is there any good shortcut for that rather than
"   defining our own bespoke command?

" ~~~~~ Bracketoids                                              {{{2
" TODO: pretty sure none of these clash with any builtins...
"   By default gitgutter wants to take `]c` and `[c`, so we can't
"   use them for :cnext/:cprev.  However, I'm thinking not to let
"   them, and to use some other thing instead, like `]g` `[g` (and
"   updating all the other gitgutter default mappings to match).
" Quickfix/errors
nnoremap ]q :cnext<CR>zz
nnoremap [q :cprev<CR>zz
" TODO: something for :cclose

" Quickfix/locations
nnoremap ]l :lnext<CR>zz
nnoremap [l :lprev<CR>zz
" TODO: something for :lclose

" Buffers
nnoremap ]b :bnext<CR>
nnoremap [b :bprev<CR>

" Tabpages
nnoremap ]t :tabn<CR>
nnoremap [t :tabp<CR>


" ~~~~~ Misc.                                                    {{{2

" Improve latency/responsiveness by not redrawing while running macros.
" This also improves latency for scrolling when there's a lot of
" syntax highlighting going on (e.g., the recent regression when
" editing Perl files).  Alas, it makes scrolling choppy whenever the
" viewport moves.  So which is worse: lagginess or choppiness?
" TODO: it might help to set &regexpengine=1 <https://stackoverflow.com/a/25276429>
" TODO: or perhaps setting &ttyscroll to something small (when redrawing is fast but scrolling is slow)
" TODO: maybe also `hi NonText cterm=NONE ctermfg=NONE`, as suggested by :h slow-terminal
" TODO: if all else fails, maybe it's an iTerm2 problem. Try setting
"   opacity to 100% and blur to 0. (This seems an unlikely culprit,
"   since I'm only really encountering issues with Perl files.)
set lazyredraw

"set hidden             " Allow hiding of buffers with unsaved changes.
                        " <http://items.sjbach.com/319/configuring-vim-right>
"set autochdir          " Change directory to the file in the current window.
"set nojoinspaces       " No additional spaces when joining lines with <J>
                        " (but see <gJ> if you only want that occasionally)
"set esckeys            " Allow cursor keys within insert mode.
"set debug=msg,throw    " Help debug &foldexpr, &formatexpr, &indentexpr by
                        " giving error messages that would normally be omitted.
"set report=0           " (0=)Always report the number of lines changed.
"set display=lastline   " Show as much of the last file-line as possible.
"set fileformat=unix
"set path=$HOME/,.      " Set the basic path (see below)
"set tags=tags,$HOME/.vim/ctagsproject
"set browsedir=buffer   " :browse e starts in %:h, not in $PWD

" TODO: consider these ctags macros (HT: 'junegunn/dotfiles')
" N.B., <C-]>   uses `:tag`     jumps to N'th match (default N=1), and push if &tagstack
"       g<C-]>  uses `:tjump`   like `:tselect` but jumps if only one match.
"       g]      uses `:tselect` lists a menu of matches.
" all three work in both normal- and visual-mode.
" Also, afaict `:pop` is basically the same as <C-t>; only difference
" seems to be that it allows a bang.  Also, `:tag` can be used to go
" the opposite direction in the stack (also allows a bang); the <C-]>
" usage is special in that it gives the word-under-cursor as an
" argument.
"nnoremap <C-]> g<C-]>
"nnoremap g[    :pop<CR>

" ~~~~~ TODO URLs                                                {{{2
"     http://www.tjansson.dk/filer/vimrc.html
"     http://saulusdotdyndnsdotorg/~david/config/vimrc
"         This one has a whole hell of a lot of stuff!
"     https://github.com/mad-raz/dotvim/blob/master/.vimrc
"     https://github.com/junegunn/dotfiles/blob/8646aae3aec418662d667b36444e771041ad0d23/vimrc#L12-L91
"     http://www.apaulodesign.com/vimrc.html
"     https://github.com/thoughtbot/dotfiles/blob/master/vimrc
"     https://dougblack.io/words/a-good-vimrc.html


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Movement                                                 {{{1

" TODO: consider setting &scrolljump

" Gentler scrolling with Shift-up/down.
noremap  <S-Up>   10k10<C-y>zz
inoremap <S-Up>   <ESC>10k10<C-y>zzi
noremap  <S-Down> 10j10<C-e>zz
inoremap <S-Down> <ESC>10j10<C-e>zzi
noremap  <C-Up>   <C-u>M
noremap  <C-Down> <C-d>M
" TODO: imaps for <C-Up> and <C-Down>?

" Move by display-lines rather than by file-lines.
noremap <Up>   gk
noremap k      gk
noremap <Down> gj
noremap j      gj


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ History, backups, & stupidity                            {{{1
set history=100                 " size of command and search history
"set undolevels=1000            " depth of undo tree

" N.B., vim-6.2 can't handle the '<' entry here.
set viminfo='20,<100,s100,\"100
"           |   |    |    |
"           |   |    |    +------ lines of history (default 50)
"           |   |    +----------- Exclude registers larger than N kb
"           |   +---------------- Maximum of N lines for registers
"           +-------------------- Keep marks for N files
"set confirm                    " ask before doing something stupid
set autowrite                   " autosave before commands like next and make
set nobackup                    " make a backup file?
"set patchmode=.orig            " save original file with suffix the first time
"set backupdir=$HOME/.vim/backup " where to put backup files
"set directory=$HOME/.vim/temp  " where to put temp files
"set nofsync swapsync=          " DANGEROUS: save power by never syncing to disk


" TODO: Do I still want the `:ClearUndoHistory` command now that I
"   have the `<leader>w` mapping?
command! -nargs=0 ClearUndoHistory call wrengr#ClearUndoHistory()
command! -nargs=0 ClearRegisters   call wrengr#ClearRegisters()

" This wrapper function is an egregious hack in order to:
" (1) see the 'foo written' message from `:write`;
" (2) not have the `:call` clobber that message.
" We can't simply inline this definition into the mapping, because:
" (1) using `:silence` only silences the *output* of the `:call`,
"   it doesn't silence the echoing of the `:silence call` command;
" (2) using `<silence>` will prevent echoing the command,
"   however it also silences the message from `:write`
" There's a chance that joining the commands via <Bar> rather than
" <CR> would make it work, but this wrapper function also works.
" TODO: we may want to make a bang version of this too
"
" Warning: Doesn't affect us here but, beware of the syntastic bugs
" around typing <C-z> too quickly after `:w`.  If we ever do run into
" issues like that, then maybe insert a brief pause into this mapping.
nnoremap <silent> <leader>w :call <SID>WriteAndClearUndoHistory()<CR>
fun! s:WriteAndClearUndoHistory()
  update " Like `:write` but only writes when &modified.
  silent call wrengr#ClearUndoHistory()
endfun

" TODO: if we used a control character or something else very
"   unlikely to be typed, we could also do something like this:
"inoremap <silent> <leader>w <C-o>:call <SID>WriteAndClearUndoHistory()<CR>
"   Maybe use <D-s> for regularity with OSX stuff; though I'm not
"   sure whether iTerm2 uses <D-s> for anything.  (Of course, if
"   <D-s> isn't used by iTerm2, then we could always use that for
"   the normal-mode mapping too!)
"   However, see <https://github.com/macvim-dev/macvim/issues/676>


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Auto-Indentation                                         {{{1

" (&ai) Retain the indentation level from line to line.
"   Applies To: i_<CR>, <o>, <O>.
"   Note: its behavior is altered by &cin and &si.
" Also note, most of the following expect &ai to be on if they are.
" (E.g., the docs for &lisp and &si explicitly say so, the docs for
" &inde mention that it falls back to &ai whenever the function
" returns -1.)
set autoindent

" When autoindenting, copy/preserve the <Tab>-vs-spaces structure
" of the previous line; unless &expandtab is enabled, in which case
" both of these are ignored.
"set copyindent
"set preserveindent

" The rules about what indention stuff applies when is rather
" complex.  We'll try to list them in order of precedence.
"
" #1: &lisp, &lispwords/lw, lispindent().
"   Applies To: i_<CR>, `cc`, <S>.
"   Requires: has('lispindent').
"   Overrules: &inde.
"
" #2: &indentexpr/inde, &indentkeys/indke, indent().
"   See Also: *indentkeys-format*, *indent-expression*.
"   Applies To: new line created, <=> operator, &indke in insert-mode.
"   Requires: has('cindent') && has('eval').
"   Overrules: &cin, &si.
"   Overruled By: &lisp.
"
" #3: &cindent/cin, &cinkeys/cink, &cinoptions/cino, cindent().
"   See Also: *C-indenting*, *cinkeys-format*, *cinoptions-values*
"   Requires: has('cindent')
"   Overrules: &si.
"   Overruled By: &inde.
"
" ?: &cinwords
"   Requires: has('cindent') && has('smartindent').
"   Extends: &si, &cin.
"
" #4: &smartindent/si, also reuses &cinwords.
"   Applies To: curly braces, hash mark, &cinwords, `>>` command.
"   Requires: has('smartindent').
"   Overruled By: &cin, &inde.
if has('smartindent')
  " Don't be stupid about hash (and also other stuff).
  set nosmartindent
  " If all we cared about was hash and liked the rest of &si, here's a hack:
  " <http://vim.wikia.com/wiki/Restoring_indent_after_typing_hash>
  " <http://stackoverflow.com/a/2360284/358069>
  "inoremap # X#
endif

" Note: When some filetype starts misbehaving, don't forget we have
" wrengr#utils#DisableIndent()

" TODO: see also junegunn's go_indent() with `gi` and `gpi` mappings:
" <https://github.com/junegunn/dotfiles/blob/master/vimrc#L1006>


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ <Tab> handling (:help *ins-expandtab*)                   {{{1

set tabstop=4       " Display a <Tab> character as if N characters wide.
set softtabstop=0   " (0=)Don't pretend N positions are a <Tab> character
                    " (-1: Pretend &ts positions are a <Tab> character).
set shiftwidth=0    " Indent by N positions for shift commands (0: use &ts)
" TODO: consider &shiftround
" TODO: consider &varsofttabstop requires '+vartabs'

" Enabling smarttab means we will interpret <Tab> keypress at beginning
" of line as indenting by &sw positions (instead of only using &sw for
" the shift commands).  N.B., will still use &ts/&sts everywhere else on
" the line, as usual.  Alas, enabling smarttab *also* means that a <BS>
" keypress at beginning of line will delete &sw worth of spaces (instead
" of just one).  Thus, we disable this since we hate that <BS> behavior.
set nosmarttab

" Enabling expandtab means we will *always* convert <Tab> character to
" positions (either &shiftwidth or &tabstop, depending on &smarttab).
" Disabling it means we will *never* convert <Tab> to positions.
" N.B., if you want to convert <Tab> manually, you should reset the
" &expandtab value and then use the :retab command.
set expandtab

" To un/indent in insert-mode use <C-d> and <C-t>.
" To un/indent in visual-mode, use `<` and `>` just like normal-mode.
" See `:h *visual-operators*`
"   <http://usevim.com/2012/05/11/visual/>
"   <http://vim.wikia.com/wiki/Avoid_the_escape_key>

" Stay in visual-mode after shifting.
" HT: <https://github.com/cypher/dotfiles/blob/master/vim/bindings.vim>
"vnoremap < <gv
"vnoremap > >gv


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Line wrapping (or not, as the case may be)               {{{1

" Yes, you may soft-wrap.
set wrap
if has('linebreak')
  " Only soft-wrap lines at characters in &breakat; i.e., not in the
  " middle of words.  N.B., the default &breakat contains a space.
  set linebreak
  " BUGFIX: Disable &list because it invalidates &linebreak.
  "   This highly unexpected behavior is deemed to be 'a feature':
  "   <https://groups.google.com/forum/#!topic/comp.editors/blelxLchTPg>
  set nolist
  "set breakat=' ^I!@*-+;:,./?'
  if has('patch-7.4.338')
    set breakindent         " Visually indent when wrapping lines.
    set breakindentopt=sbr  " Display &showbreak before applying indentation
    if has('multi_byte')
      " Show '↳' (nr2char(8627)) at the beginning of soft-wrapped
      " lines; plus an extra space since that glyph hangs a bit
      " over the single-column width.
      " HACK: We use nr2char() here because in older vim using the
      " actual unicode character caused some kind of glitchiness.
      " Though that may also have been sepcific to the '↪' (nr2char(8618))
      " we used to use here.
      let &showbreak = nr2char(8627).' '
    endif
  endif
endif

" No, you may not hard-wrap in any way.
call wrengr#utils#DisableHardWrapping()


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Searching                                                {{{1
set nohlsearch      " After finishing a search command, highlight matches?
set incsearch       " While typing a search command, highlight match-so-far?
set ignorecase      " Make search commands ignore case.
"set smartcase      " Become case-sensitive if the pattern has any uppercase.

" Treat regex-special characters more like Perl instead of Grep.
" See `:h */magic*` for a better description than `:h 'magic'`; and
" `:h *perl-patterns*` for a proper comparison with Perl's syntax.
" N.B., this is already on by default, but we want to make sure.
" (Also note that `:h *Vim9-script*` will always pretend this is on.)
set magic

" TODO: consider these, if we'd like to recenter the cursor every
" time.  (Not sure why my source for this trick added the `zv` in
" addition to the `zz`.)
"nnoremap n nzzzv
"nnoremap N Nzzzv

" Search for character under cursor.
" (Mainly for use with CJK unicode, probably not so useful otherwise.)
" See also: <https://vi.stackexchange.com/a/560> and `:h ga` and `:h g8`
" TODO: really need a better keybinding/name.
nnoremap <leader>z xu/<C-r>-<CR>

" TODO: really need a better keybinding/name.
" Also, we probably want something different from this.
nnoremap z/ :call wrengr#AutoHighlightToggle()<CR>


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Wild (:help *cmdline-completion*)                        {{{1

" What key/character should be used to invoke wildcard expansion?
" cf., <http://vim.wikia.com/wiki/Easier_buffer_switching>
" also: <https://vi.stackexchange.com/a/22628>
" (&wc should already be <Tab> by default, but just to be sure.)
set wildchar=<Tab>      " During manual cmdline entry.
"set wildcharm=<C-z>    " Within macros (i.e., mappings).

if has('wildmenu')
  " When &wildmode does 'full', also give a menu of options.
  set wildmenu

  " What should pressing the &wc key actually do?
  "
  " BUG: on OSX's builtin vim-8.0 `longest:full` doesn't actually
  " do the `longest` part.  Fink's vim-nox 8.2.3404-1 does most of
  " the time, but not always.  (It fails when the longest common
  " prefix differs in case.  Dunno if there are more situations.)
  set wildmode=full
else
  set wildmode=longest:list,list
endif

" Should we ignore case despite &fileignorecase=no?
set wildignorecase

" Define precedence order for expanding almost-same-name files:
"set suffixes=

" TODO: cf., 'octref/RootIgnore'
if has('wildignore') " '+wildignore' is both &wildignore and &wildoptions.
  " When using c_<C-d> to list matching completions,
  " if it's a tag being completed then also show its tag-kind and tag-file.
  "set wildoptions=tagfile

  " Ignore editor cruft
  set wildignore+=*.swp,*.swo,*~,._*
  " Ignore Haskell build stuff
  set wildignore+=*.o,*.hi,*.p_hi,*.prof,*.tix,
  set wildignore+=dist/*,.hpc/*,.hsenv/*,.cabal-sandbox/*
  " Ignore other languages' build stuff
  set wildignore+=*.pyc,*.rbc,*.rbo,*.class,*.gem,*.obj
  " Ignore common binaries
  set wildignore+=*.zip,*.tar.gz,*.tgz,*.tar.bz2,*.rar,*.tar.xz,*.pdf,*.ps
  " Ignore LaTeX build stuff
  set wildignore+=*.aux,*.toc,*.lof,*.lot,*.bbl,*.blg,*.btp,*.xyc,*.cb
  set wildignore+=*.idx,*.ilg,*.glo,*.glg,*.gls,*.nlo,*.nls,*.nav,*.snm
  " Ignore emacs-mode stuff
  set wildignore+=*.elc,*.cp,*.fn,*.fns,*.info,*.ky,*.pg,*.tp,*.vr,*.vrs,.depend
  " etc
  set wildignore+=.DS_Store,.git/*
endif

" Grep_Skip_Dirs was for 'vim-scripts/grep.vim' which was last
" updated in 2013 and we don't really use anymore.  If we use it
" again then we can re-define the variable.
" (Tangentially, note that modern Vim has both `:grep` and `:vimgrep` commands)


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Insert-mode Autocompletion (:help *ins-completion*)      {{{1
" &cpt is used by i_<C-p>, i_<C-n>, i_<C-x><C-l>, and maybe also i_<C-x><C-d>.
"set complete=.,w,b,u,t,i
"set completeopt=menu,preview
    " See also: *ins-completion-menu*, *complete-popuphidden*
"set completepopup=     (if '+textprop' or '+quickfix')
    " See also: *complete-popup*
"set infercase      " When doing *ins-completion* and &ignorecase is on...
" &dict is used by i_<C-x><C-k> and for others if 'k' is in &cpt.
"set dictionary=
" &tsr is used by i_<C-x><C-t> and for others if 's' is in &cpt.
"set thesaurus=

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ (:help *complete-functions*)                             {{{1
"set completefunc=      (if '+eval')


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Spelling                                                 {{{1
" Note: on mayari 'spell' is not listed by `:version`, yet has()
" returns true anyways (as well it should given as it does work).
if v:version > 700 && has('spell')
  setlocal spelllang=en_us " Set a local value of the global &spellang
  if has('syntax')
    " Show top N spell suggestions.
    set spellsuggest+=10
    " Note: &spellsuggest actually takes a comma-separated list of
    " algorithms/options.  The top-N suggestions is just one of
    " them; so we use `+=` to combine this with the default `best`.
    " (Yes, `+=` is smart enough to handle comma-separated.)
  endif
  " Change to make spellfile.vim ask you again for downloading file
  "let g:spellfile_URL = 'http://ftp.vim.org/vim/runtime/spell'

  " Toggle highlighting spelling errors (for local buffer only).
  " (N.B., this is how you spell <ctrl-space>.  Also, we can't
  " use <C-s> because the terminal steals that to mean 'stop output'.)
  nnoremap <silent> <C-@> :setlocal spell!<CR>
  " BUG: we need to have spell enabled in order to use `[s`, `]s`,
  " etc. Is there a way to enable it and instead just toggle whether
  " they're highlighted or not?

  " An interesting idea that I don't really like,
  " HT: <http://stackoverflow.com/a/5041384/358069>
  "if has('autocmd')
  "  augroup spell_unless_insert
  "    autocmd!
  "    autocmd InsertEnter * setlocal nospell
  "    autocmd InsertLeave * setlocal spell
  "  augroup END
  "endif
endif


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Highlight whitespace errors                              {{{1
" TODO: actually make this toggle!
" BUG: these patterns don't seem to work everywhere (e.g., inside
"   `function!` itself; though it works just fine inside `if`.
"   Similarly, it does nothing inside vimCommentLine)
" TODO: should prolly move this off to our colorscheme, ne?
command! -nargs=0 HighlightSpaces call s:HighlightSpaces()
fun! s:HighlightSpaces()
  " TODO: should prolly guard this one based on how &expandtab is set.
  syntax match hardTab display "\t"
  highlight link hardTab Error

  syntax match trailingWhite display "[[:space:]]\+$"
  highlight link trailingWhite Error

  " The \ze ends the match, so that only the spaces are highlighted.
  syntax match spaceBeforeTab display " \+\ze\t"
  highlight link spaceBeforeTab Error
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Folding (:help usr_28)                                   {{{1
" By default <z><a> is used for un/folding. but that can be annoying
" if you accidentally mistype the <z> and so enter append mode. Should
" use nnoremap to choose some other key combo for un/folding.
if has('folding')
  "set foldenable          " Turn on folding
  " This shows the first line of the fold, with '/*', '*/' and '{{{' removed.
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
  "set foldclose=all       " Automatically close folds when leaving

  " TODO: might should use wrengr#plug#DataDir(), but I've no idea
  "   what NeoVim uses for this.
  "set viewdir=$HOME/.vim/view  " Where to put `:mkview` files

  " To automatically save manual folds and reload them:
  " (I'm not sure if I actually want this, but it's good to remember)
  " TODO: add guards to the autocmds to check that &foldmethod==manual;
  "   since `:mkview` saves so much more than just manual folds.
  "if has('autocmd')
  "  augroup save_restore_manual_folds
  "    autocmd!
  "    autocmd BufWinLeave * mkview
  "    autocmd BufWinEnter * silent loadview
  "  augroup END
  "endif
endif


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Helper/external programs (beware portability)            {{{1

" The shell used for `!` and `:!` commands.
"set shell=/bin/bash

" Force the <~> key command to behave like an operator (thus, like `g~`).
"set tildeop

" The thing the <=> key command uses.
"set equalprg=
" TODO: cf., <http://vim.wikia.com/wiki/Par_text_reformatter>

" The thing `gq` uses.
"set formatexpr=
"set formatprg=

" The thing `g@` uses.
"set operatorfunc=

" The thing the <S-k> key command uses. (If blank/empty, then uses `:help`)
"set keywordprg=man\ -s

" Unmap <S-k>, since I keep hitting it accidentally and never want/need it.
map <S-k> <Nop>

" The thing `:grep` uses.
"set grepprg=grep\ -nHr\ $*
" TODO: cf., <https://robots.thoughtbot.com/faster-grepping-in-vim>,
"   the comment to <https://stackoverflow.com/a/4889864/358069>
" TODO: try <https://github.com/BurntSushi/ripgrep> maybe?
" TODO: see also <https://github.com/cypher/dotfiles/blob/master/vim/extensions.vim#L177>
"if executable('rg')
"  set grepprg=rg\ --vimgrep\ --no-heading
"  set grepformat=%f:%l:%m
"endif

" The thing `:make` uses.
"set makeprg=make


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Copying & Pasting                                        {{{1

"set pastetoggle=<F9>

" Make <S-y> yank from cursor to end of line (a~la <S-d>, and akin
" to <S-a>), rather than yanking the whole line (a~la <y><y>, as
" is done in traditional vi).
nnoremap Y y$

" In Visual/Select modes: have <p> replace selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-r>=current_reg<CR><Esc>

" BUG: neither "* nor "+ registers behave apropriately on the version
" of vim that ships with newer OSX. Instead must use MacVim
" <http://www.drbunsen.org/text-triumvirate.html>, or perhaps try
" something like
" <https://vim.sourceforge.io/scripts/script.php?script_id=2098>.
" But if they did...
" <https://vi.stackexchange.com/a/96>
" <https://vi.stackexchange.com/q/84#comment19762_96>
" Or to make use of pbcopy/pbpaste commandline tools, cf:
" <https://stackoverflow.com/a/20448266>
" <https://stackoverflow.com/a/20961530>
" TODO: See also: <https://github.com/christoomey/vim-system-copy>


" ~~~ Yank to clipboard
" BUG: mayari's OSX Vim is '-clipboard' and doesn't list 'unnamedplus'
"   among the features (also has() returns false for it, unlike the
"   case with 'spell'); it's also '-xterm_clipboard' fwiw.
"   We may want to install vim-gtk3 (or vim-gtk, or gvim) rather than our current vim-nox.
" See also <https://vim.fandom.com/wiki/Accessing_the_system_clipboard>
if has('clipboard')
  " This isn't the best idea... cf., <https://stackoverflow.com/a/16582932>
  set clipboard=unnamed " copy to the system clipboard
  if has('unnamedplus') " X11 support
    " changes the default Vim register to "+
    set clipboard+=unnamedplus
  endif
endif

" TODO: see also <https://vi.stackexchange.com/a/20325>, albeit
"   that's specifically for working around X11 issues in Linux.
"   Also see <https://askubuntu.com/a/729372> an explanation of how
"   Linux does things.  And `:h "+` says that the "* register is
"   the PRIMARY, whereas "+ is CLIPBOARD.  Thus, on Linux using "+
"   is preferred.  Conversely, on Windows and OSX using "* is
"   preferred (when '+clipboard', naturally).
"
" TODO: if we're desperate, we can always try using `!pbcopy` and `!pbpaste`.


" Preserve indentation while pasting text from the OS X clipboard.
" BUG: this is broken on newer OSX. Also broken on Goobuntu.
"   2021-09-11: I fixed part of the problem. For some reason the
"   old `:noremap` was only showing up as a `:vnoremap`; so I've
"   changed it to explicitly be `:nnoremap` (since neither :vmap nor
"   :omap make much sense here).  However, it still doesn't work because
"   we don't have the "* register...
"   Warning: N.B., when it crashes it'll leave us in `paste` mode!!
" TODO: if we get this working again, may prefer using <leader>v
"   or <D-v>  (Though as of recently someone's started binding <D-v>)
" TODO: see 'ConradIrwin/vim-bracketed-paste'
if has('clipboard')
  nnoremap <Leader>p :set paste<CR>:put *<CR>:set nopaste<CR>
endif

" Select the most-recently INSERTed text. (N.B., that'll be the
" whole file if you've just loaded it up and have never entered
" INSERT mode yet.)
" HT: <https://dougblack.io/words/a-good-vimrc.html>
"nnoremap gV `[v`]

" Auto indent pasted text
" HT: <https://github.com/victormours/dotfiles/blob/master/vim/vimrc>
"nnoremap p p=`]<C-o>
"nnoremap P P=`]<C-o>


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ OSX nonsense                                             {{{1

" Old links re the fact that terminals can't distinguish <Tab> vs <C-Tab>
" (since <Tab> is <C-i> for legacy reasons, thus we can't have <C-C-i>):
"     <http://stackoverflow.com/q/1646819/358069>
" And apparently using multiple control keys is unreliable as well :(
"     <http://stackoverflow.com/a/26589192/358069>

" TODO(2021.09.11): I just noticed that someone is setting the following:
"vnoremap <BS>  "-d
"vnoremap <D-c> "*y
"nnoremap <D-v> "*P
"vnoremap <D-v> "-d"*P
"vnoremap <D-x> "*d
" That's all well and good, but we should figure out where they
" came from, in case we want to adjust them.


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ FileType stuff                                           {{{1
" TODO: Most of this stuff should go into its own ft files. Not in here!
"     <http://vim.wikia.com/wiki/Keep_your_vimrc_file_clean>
if has('autocmd')
  " Enable file type detection, and load filetype-based indentation files.
  " N.B., plug#end() will set these for us too, by the way.
  filetype on
  filetype plugin on
  filetype indent on

  " TODO: move these off to ~/.vim/ftdetect/ where they belong.
  augroup wrengr_vimrc
    " Yes, all my *.pro files ARE prolog files
    autocmd BufNewFile,BufRead *.pro,*.ecl set ft=prolog

    " This causes GHC to type check every time you save the file
    "autocmd BufWritePost *.hs !ghc -c %
    " TODO: similar things for *.hsc, *.lhs,... you can use {,} alternation a-la Bash
    " N.B., Haskell-specific things are defined in ~/.vim/ftplugin/haskell.vim

    " TODO: actual support for Agda
    " <http://wiki.portal.chalmers.se/agda/agda.php?n=Main.VIMEditing>
    autocmd BufNewFile,BufRead *.agda set ft=haskell

    " Try to enforce correct spelling and short messages.
    autocmd Filetype gitcommit setlocal spell nocursorline textwidth=72
  augroup END
endif



" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Plugin Configurations ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{1
"
" TODO: if any of these are/stay short enough, we might should move
"   them up to where we actually list the plugin.  It's fine to put
"   a bunch of stuff in 'the plug block', just seldom necessary is all.

" ~~~~~ netrw                                                    {{{2
" BUG: for some reason netrw_alto and netrw_altv aren't working. I
" tried moving all the netrw stuff down here, just in case setting
" &sb reset things; but alas that's not it...
" TODO: cf., <https://stackoverflow.com/a/36676859>,
" <http://www.vim.org/scripts/script.php?script_id=1075>.
" We should probably switch to using 'eiginn/netrw' rather than
" whatever version ships built-in; though see the notes there about
" needing to uninstall the older version first...

" cf., <https://shapeshed.com/vim-netrw/>
let g:netrw_altfile      = 1  " 1= Make <C-^> return to the last-edited file.
let g:netrw_alto         = 0  " 1= make :Sex &splitbelow (default: &sb)
let g:netrw_altv         = 1  " 1= make :Vex &splitright (default: &spr)
let g:netrw_banner       = 0  " 0= hide the banner.    (Toggle with <I>)
let g:netrw_liststyle    = 2  " 2= `ls -CF`; 3= tree.  (Toggle with <i>)
let g:netrw_browse_split = 0  " Open files into window: 0= netrw; 4= previous.
let g:netrw_winsize      = 25 " What percent of the available extent to use.
let g:netrw_list_hide    = '\(^\|\s\s\)\zs\.[^\.]\+' " Toggle hiddenness with <gh>
"let g:netrw_keepdir=0          " 0= keep vim's :pwd in sync with b:netrw_curdir
"let g:netrw_fastbrowse=2       " TODO: look it up and consider
"let g:netrw_retmap=1           " TODO: look it up and consider
"let g:netrw_silent=1           " TODO: look it up and consider
"let g:netrw_special_syntax=1   " TODO: look it up and consider

" TODO: if we don't use vinegar, then should copy-paste the stuff
" for using 'suffixes' in lieu of the default strange C-oriented
" sorting. Also for enhancing the hidden files based on 'wildignore'.
" I do dislike vinegar's nmap for <->; would rather use <Q> or something
" else I don't use. (I mean the <-> mapping that applies to all
" buffers; not the local one inside the netrw window, that one's
" fine.)
"
" Also, apparently netrw is extremely buggy (especially the tree-view);
" so that's the main reason to want to go for something else
" <https://www.reddit.com/r/vim/comments/22ztqp/why_does_nerdtree_exist_whats_wrong_with_netrw/cgs4aax/>
"
"augroup wrengrvinegar
"  autocmd!
"  autocmd FileType netrw
"    \nnoremap <buffer> q :call wrengr#BufferDelete()<CR>
"    \| nnoremap <buffer> ~ :edit ~/<CR>
"augroup END


" ~~~~~ airline configuration                                    {{{2
" For more help on configuration options, see `:h airline`
"
" TODO: guard this section with exists(g:loaded_airline) and
" exists(g:loaded_airline_themes); as appropriate.

" Show all buffers in the tabline, when there's only one tab. Only
" looks good if your terminal has enough colors.
"let g:airline#extensions#tabline#enabled = 1

"let g:airline#extensions#syntastic#enabled = 1
"let g:airline#extensions#branch#enabled = 1
"let g:airline#extensions#tagbar#enabled = 1
"let g:airline_skip_empty_sections = 1

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
  "  let g:airline_symbols = {}
  "endif
  "let g:airline_left_sep           = '▶' " '»'
  "let g:airline_right_sep          = '◀' " '«'
  "let g:airline_symbols.crypt      = '🔒'
  "let g:airline_symbols.linenr     = '¶' " '␊', '␤'
  "let g:airline_symbols.maxlinenr  = '' " '☰'
  "let g:airline_symbols.branch     = '⎇'
  "let g:airline_symbols.paste      = 'ρ' " 'Þ', '∥'
  "let g:airline_symbols.spell      = 'Ꞩ'
  "let g:airline_symbols.notexists  = '∄'
  "let g:airline_symbols.whitespace = 'Ξ'
endif

" Other themes to bear in mind: tomorrow, wombat, luna, jellybeans, zenburn.
" WIP: make our overmorrow into an airline theme too
let g:airline_theme='tomorrow'
" From <https://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/>
" Removing left/right separators because we don't have the powerline fonts.
let g:airline_left_sep=''
let g:airline_right_sep=''
" By default section Z shows the current position in file; which
" isn't too useful to me.
let g:airline_section_z=''


" ~~~~~ gitgutter configuration                                  {{{2
if has('signs')
  set updatetime=500
  " Newer versions of gitgutter replaced g:gitgutter_sign_column_always
  " with &signcolumn, and complain about using the old variable.
  " However, older versions of vim (e.g., the version 7.4 which
  " ships with OSX 10.12.6) don't have &signcolumn.
  if exists('&signcolumn')
    set signcolumn=yes
  else
    let g:gitgutter_sign_column_always = 1
  endif
  "let g:gitgutter_max_signs = 500 " default=500
  "let g:gitgutter_map_keys  = 0   " don't set up default mappings
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
  " TODO: It looks like I've fixed the SignColumn stuff, but maybe
  "     check out the documentation for g:gitgutter_set_sign_backgrounds.
  " TODO: maybe also check out `:h gitgutter-statusline` for
  "     something to put into airline's section Z.
endif


" ~~~~~ nerdtree configuration                                   {{{2
"if exists(':NERDTree')
"  noremap <C-t> :NERDTreeToggle<CR>
"
"  " Allow vim to close if the only open window is nerdtree
"  autocmd wrengr_vimrc BufEnter * if (winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree()) | q | endif
"
"  " TODO: see also junegunn's `augroup nerd_loader`
"
"  " <http://stackoverflow.com/a/26161088>
"
"  " Highlight based on extensions:
"  " <https://github.com/scrooloose/nerdtree/issues/433#issuecomment-92590696>
"endif


" ~~~~~ syntastic configuration                                  {{{2
"if exists(':SyntasticCheck')
"  if executable('vint')
"    let g:syntastic_vim_checkers = ['vint']
"  endif
"endif


" ~~~~~ Limelight & Goyo configuration                           {{{2
" There don't seem to be any helpfiles, however the github does
" have README.md explaining the various settings and other suggested
" configuration tricks.  If commented out, then the default value is shown.

"   If you get error messages about our colorscheme not being supported:
"let g:limelight_conceal_ctermfg =
"let g:limelight_conceal_guifg =
"   Default argument to :Limelight (0.0 is white, 1.0 is black)
let g:limelight_default_coefficient = 0.4
"let g:limelight_paragraph_span = 0
"let g:limelight_bop = '^\s*$\n\zs'
"let g:limelight_eop = '^\s*$'
"   Set priority to -1 not to overrule hlsearch.
"let g:limelight_priority = 10
"
" TODO: this feels a little offcenter to the right; so we should
"   nudge it to the left a bit; requires passing the xoffset argument
"   to :Goyo, doesn't seem to be any g-variable we can set to do
"   it automatically.
"let g:goyo_width = 80
"   Can only set either g:goyo_height or g:goyo_margin_{top,bottom}
let g:goyo_height = '90%'
"let g:goyo_margin_top = 4
"let g:goyo_margin_bottom = 4
"let g:goyo_linenr = 0

" TODO: see <https://stackoverflow.com/a/5219213> re getting unique
"   window IDs. (Not that that's specifically relevant here, apparently)

" TODO: consider <https://github.com/junegunn/goyo.vim/wiki/Customization#ensure-q-to-quit-even-when-goyo-is-active>

" Note: According to the helpfiles, both &sc and &so are global-only
" options; thus we need only cache one copy of them, rather than one
" per tab/window/buffer.
let s:goyo_saved_sc = &showcmd
let s:goyo_saved_so = &scrolloff
fun! s:on_GoyoEnter()
  let s:goyo_saved_sc = &showcmd
  let s:goyo_saved_so = &scrolloff
  set noshowcmd
  set scrolloff=999
  Limelight
endfun
fun! s:on_GoyoLeave()
  let &showcmd   = s:goyo_saved_sc
  let &scrolloff = s:goyo_saved_so
  Limelight!
endfun
" Note: The 'User' event means these are not truly auto-commands,
" but rather must be manually invoked via `:doautocmd`.  The `nested`
" was recommended by Goyo's README, but I don't think it's really
" needed, since our functions shouldn't trigger any new auto events
" (unless Limelight uses a similar autocmd-as-callback trick).
augroup wrengr_vimrc
  autocmd User GoyoEnter nested call s:on_GoyoEnter()
  autocmd User GoyoLeave nested call s:on_GoyoLeave()
augroup END

" TODO: consider using something like this (or similar for Goyo):
"nnoremap <Leader>l <Plug>(Limelight)
"xnoremap <Leader>l <Plug>(Limelight)
"nnoremap <Leader>ll :Limelight!<cr>


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ 'prabirshrestha/vim-lsp' configuration (:help vim-lsp)   {{{2
" Also see <https://github.com/prabirshrestha/vim-lsp/blob/master/README.md>
"
" TODO: if we run into certain issues with asyncomplete doing too much,
" then take a look at: <https://github.com/prabirshrestha/vim-lsp/issues/328>


" ~~~~~ Setup Kythe for Google-specific code searching
" Kythe is almost entirely open source (just not the stubby wrapping);
" cf., <https://github.com/kythe/kythe/tree/master/kythe/go/languageserver>

" Alas, prabirshrestha doesn't follow the `g:loaded_{plugin}` convention.
" TODO: should we also guard for exists('g:async_vim') ?
if exists('g:lsp_loaded')
  fun! s:lsp_register_Kythe()
    let l:kythe_exe = '/google/bin/releases/grok/tools/kythe_languageserver'
    if executable(l:kythe_exe)
      call lsp#register_server({
        \ 'name': 'Kythe Language Server',
        \ 'cmd': {server_info->[l:kythe_exe, '--google3']},
        \ 'allowlist': ['cpp', 'go', 'java', 'proto', 'python'],
        \ })
    endif
  endfun
  autocmd wrengr_vimrc User lsp_setup call s:lsp_register_Kythe()

  " TODO: the next three were suggested by CiderLSP; do we actually want them?
  " [asyncomplete-lsp]: Send async completion requests.
  " WARNING: Might interfere with other completion plugins.
  "let g:lsp_async_completion = 1
  " Enable diagnostics signs in the gutter.
  " TODO: how different from g:lsp_diagnostics_signs_enabled?
  "let g:lsp_signs_enabled = 1
  " Enable echo under cursor when in normal mode.
  "let g:lsp_diagnostics_echo_cursor = 1

  " Not sure exactly how 'sign_define' differs from the usual 'signs' but...
  " Also, whenever the guard passes, it may already be enabled by default...
  if has('patch-8.1.0772') && has('sign_define')
    let g:lsp_diagnostics_signs_enabled = 1
  endif

  fun! s:on_lsp_buffer_enabled() abort
    " TODO: Do we actually want these two? (see `:h vim-lsp-omnifunc`)
    "setlocal omnifunc=lsp#complete
    " Specifies the function to be used to perform tag searches.
    " also see `:h vim-lsp-tagfunc` and g:lsp_tagfunc_source_methods
    "if has('patch-8.1.1228') && exists('+tagfunc')
    "  setlocal tagfunc=lsp#tagfunc
    "endif
    "
    " TODO: how exactly does the :LspDefinition<CR> version differ from
    "   the <plug>(lsp-definition) version?  See `:h vim-lsp-mappings`
    "   vs `:h vim-lsp-commands`; though that stull doesn't explain really.
    "   Though for us at least, the <plug> versions aren't working (i.e.,
    "   they don't do anything afaict)
    " BUG: all too often we get "No definition found" even when it's
    "   defined in the same file!  Does it need to be fully-qualified
    "   at the use site or not type-dependant or something?
    " TODO: consider also/instead :LspPeekDefinition
    nnoremap <buffer> gd :LspDefinition<CR>
    " BUG: "Retrieving declaration not supported for filetype 'cpp'";
    "   despite this command existing precisely for languages like C/C++
    "   which distinguish declarations from definitons.
    " TODO: consider also/instead :LspPeekDeclaration
    nnoremap <buffer> gD :LspDeclaration<CR>
    nnoremap <buffer> gr :LspReferences<CR>
    " Other mappings suggested in the readme
    " TODO: decide which of these I'd like
    "noremap  <buffer> gs <plug>(lsp-document-symbol-search)    " :LspDocumentSymbol (shows not searches)
    "nnoremap <buffer> gS <plug>(lsp-workspace-symbol-search)   " :LspWorkspaceSymbol, :LspWorkspaceSymbolSearch
    "nnoremap <buffer> gi <plug>(lsp-implementation)            " :LspImplementation, :LspPeekImplementation; this is for 'implementations of interfaces' whatever that means...
    "nnoremap <buffer> gt <plug>(lsp-type-definition)           " :LspTypeDefinition, :LspPeekTypeDefinition
    "nnoremap <buffer> <leader>rn <plug>(lsp-rename)            " :LspRename
    "nnoremap <buffer> [g <plug>(lsp-previous-diagnostic)       " :LspPreviousDiagnostic
    "nnoremap <buffer> ]g <plug>(lsp-next-diagnostic)           " :LspNextDiagnostic
    "nnoremap <buffer> K <plug>(lsp-hover)                      " :LspHover
    "
    " Scrolls the current displayed floating/popup window.
    "inoremap <buffer><expr> <C-f> lsp#scroll(+4)
    "inoremap <buffer><expr> <C-d> lsp#scroll(-4)
    "
    "let g:lsp_format_sync_timeout = 1000
    "autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
    "
    " See `:h vim-lsp-folding` also may want to wrap this in `augroup
    " lsp_folding` and only apply it to certain filetypes.
    set foldmethod=expr
      \ foldexpr=lsp#ui#vim#folding#foldexpr()
      \ foldtext=lsp#ui#vim#folding#foldtext()
    " TODO: also see `:h vim-lsp-semantic`
  endfun
  " Only called for languages that have a server registered.
  autocmd wrengr_vimrc User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
  " TODO: if we ever end up usng EasyMotion, then see
  "   `:h lsp#disable_diagnostics_for_buffer()` re autocommands to toggle
  "   lsp's diagnostics so as not to interfere with EasyMotion.
endif " exists('g:lsp_loaded')


" ~~~~~ 'prabirshrestha/asyncomplete.vim' configuration          {{{2
"fun! s:asyncomplete_setup()
"  " if 'asyncomplete-tags'
"  call asyncomplete#register_source(
"    \ asyncomplete#sources#tags#get_source_options({
"    \ 'name':      'tags',
"    \ 'allowlist': ['c'],
"    \ 'completor': function('asyncomplete#sources#tags#completor'),
"    \ 'config': { 'max_file_size': 50000000, },
"    \ }))
"  " if 'asyncomplete-necovim'
"  call asyncomplete#register_source(
"    \ asyncomplete#sources#necovim#get_source_options({
"    \ 'name':      'necovim',
"    \ 'allowlist': ['vim'],
"    \ 'completor': function('asyncomplete#sources#necovim#completor'),
"    \ }))
"  " if 'asyncomplete-necosyntax'
"  call asyncomplete#register_source(
"    \ asyncomplete#sources#necosyntax#get_source_options({
"    \ 'name':      'necosyntax',
"    \ 'allowlist': ['*'],
"    \ 'completor': function('asyncomplete#sources#necosyntax#completor'),
"    \ }))
"  " if 'keremc/asyncomplete-racer.vim'
"  call asyncomplete#register_source(
"    \ asyncomplete#sources#racer#get_source_options({
"    \ 'config': { 'racer_path': 'must fill in this path', },
"    \ }))
"endfun
"autocmd wrengr_vimrc User asyncomplete_setup call s:asyncomplete_setup()

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Other misc macros                                        {{{1

" BUG: why does wildmode not expand this to have a trailing space
"   after the `:Page` like it used to?
command! -nargs=+ -complete=command Page :call wrengr#Page(<q-args>)

" TODO: should probably give this a better mapping.
nnoremap <leader>s :call wrengr#SynStack()<CR>

" Insert blank line, without entering insert-mode.
nnoremap <leader>o o<ESC>
nnoremap <leader>O O<ESC>

" Haskell comment pretty printer (command mode)
" TODO: make this work for indented comments too
noremap =hs :.!sed 's/^-- //; s/^/   /' \| fmt \| sed 's/^  /--/'<CR>

" JavaDoc comment pretty printer.
" TODO: make this work for indented comments too
noremap =jd :.,+1!~/.vim/macro_jd.pl<CR>

" TODO: can I write a single smart macro (or external program) to
"   handle comments wrapping for all of Haskell, JavaDoc, Bash,
"   Perl, Python, etc.

" TODO: In case we ever want the help-window to open as a vertical
"   split, consider the following extreme dark magic:
" HT: <https://vi.stackexchange.com/q/5130#comment7839_5130>
"cnoreabbrev h <C-r>=(&columns >= 160 && getcmdtype() ==# ':' && getcmdpos() == 1 ? 'vertical botright help' : 'h')<CR>


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" TODO: Move all this how-to commentary off to personal notes.   {{{1
"
" N.B., you only need the :call if you're simply using the function
" for side effects and discarding any output.  Thus you never say
" `:let x = call f()` but rather just say `:let x = f()`; and
" similarly never say `:echo call f()` but just `:echo f()`; etc.
"
" TODO: re passing arguments to user-defined commands, try using
"   `:h :command-nargs` to get more info.
"   Or cf., <https://stackoverflow.com/a/5651751>
"   and also <https://superuser.com/a/1399163>

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
