" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren gayle romano's vim config                    ~ 2024-02-17
"
" This file uses &foldmethod=marker, but I refuse to add a modeline
" to say that; because modelines are evil.
"
" See: ~/.vim/NOTES.md  for more guidance, commentary, and style notes.
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Minimal preamble before loading plugins ~~~~~~~~~~~~~~~~ {{{1
let g:skip_defaults_vim=1 " See: `:help skip_defaults_vim` (since Vim 7.4.2111)
" BUG: vint says we shouldn't `:set nocompatible` (which I find
" odd, since doing it used to be explicitly advocated style).  In
" any case, apparently modern vim will automatically unset &compatible
" when it detects a user's vimrc file.  So far as I can tell, us
" unsetting it again just means a slight slowdown from vim resetting
" everything once again? unclear. The helppages don't say we shouldn't
" do it...
set nocompatible " Avoid compatibility with legacy vi. (Must come first)
set nomodeline   " Avoid insecurity!  (See: ~/.vim/NOTES/modelines.md)
set ttyfast      " Avoid thinking we're still in the 1970s.
set noinsertmode " Avoid emacs-emulating silliness.

" See: ~/.vim/NOTES/versions.md
" Nevertheless, I may use `:h has-patch` below for versions older
" than 8.0 (maybe even anachronistically for older than Vim 7.4.237).
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
" Note: re plugins and `:h use-cpo-save`: it seems that `:set cpo&vim`
" does not re-enable modelines the way `:set nocp` does. (Or maybe
" it's just because I have a patched version?)
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

" TODO: maybe try using `uname -s` to see if it's "Darwin"; and
" then if/as needed check `uname -r` for the particular version.
" Is there a good way to script that up for use here?

" See also: <https://stackoverflow.com/q/2842078>   " asked in 2010!


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ vim-plug <https://github.com/junegunn/vim-plug> ~~~~~~~~ {{{1
"
" For abbreviation below, pretend we have $VIMPLUG_URL set to the url above.

" We :finish because an augroup will re-source this file anyways.
if wrengr#plug#Bootstrap() | finish | endif

" TODO: It's not really relevant anymore, since we've moved the
"   function off to a separate file, but: Figure out how exactly
"   to generate the <SID> for this file so we can make PlugWindow()
"   private yet still call it via g:plug_window.  The necessary
"   info is in `:h <SID>` and <https://vi.stackexchange.com/q/27224>,
"   but I haven't been able to get the pieces to work together...
let g:plug_window = 'call wrengr#plug#Window()'


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
" Note: one should rarely need to specify 'on'/'for'.  Below I'll
" use the tag [#jg] whenever I've added a 'for'/'on' to a plugin
" because I've seen that Junegunn does so in their own dotfiles repo;
" namely for plugins that are still commented out because I haven't
" had a chance to try them out yet.

" TODO: actually go through all these to see which plugins I actually want...
" TODO: should any of these have wrengr#plug#UseGitUrls() ?


" ~~~~~ GNU PGP  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
" For security reasons, we manually manage this one and keep a copy
" in our dotfiles repo.
" TODO: maybe still list it but using the leading '~' notation to
"   inform vim-plug that it's manually managed?
"Plug 'jamessan/vim-gnupg'
  " Default to using ascii-armor. Hopefully this'll help deal with the
  " bug where saving modified files causes them to be saved as binary
  " in spite of the *.asc suffix.
  let g:GPGPreferArmor=1
  " Debugging Note: If you install a new version of gpg and are running
  " into issues with vim-gnupg, then you probably need to re-import
  " your secret keys.  For more info on how to do so (and how to check
  " if that's the issue), see: <https://stackoverflow.com/q/43513817>


" ~~~~~ Unicode  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
" See also <https://vi.stackexchange.com/a/560>
" <https://x-team.com/blog/inserting-unicode-characters-in-vim/>
" <https://jdhao.github.io/2020/10/07/nvim_insert_unicode_char/>
"Plug 'chrisbra/unicode.vim'
    " Don't define mappings for me.
    "let g:Unicode_no_default_mappings=1
    "   nmap <F4>       <Plug>(MakeDigraph)         " Meh.
    "   vmap <F4>       <Plug>(MakeDigraph)         " Meh.
    "   imap <C-x><C-g> <Plug>(DigraphComplete)
    "   imap <C-x><C-z> <Plug>(UnicodeComplete)     " BUG: normally that's reserved for cancelling *ins-completion*
    "   imap <C-x><C-b> <Plug>(HTMLEntityComplete)
    "   imap <C-g><C-f> <Plug>(UnicodeFuzzy)        " requires 'junegunn/fzf'
    "   nmap <leader>un <Plug>(UnicodeSwapCompleteName)
"Plug 'tpope/vim-characterize'
"Plug 'arp242/uni'


" ~~~~~ Colorschemes ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
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
"Plug 'arzg/vim-colors-xcode'   " Port of Xcode 11's dark and light schemes.

" TODO(2024.01.28): Need to sort through these to figure out which
" one works best for &bg=light; so that we can update our own
" overmorrow's light palette (or perhaps even the scheme per se).
"Plug 'NLKNguyen/papercolor-theme'
"Plug 'sainnhe/everforest'
"Plug 'cormacrelf/vim-colors-github'
"Plug 'cocopon/iceberg.vim'
"Plug 'junegunn/seoul256.vim'           " Low-contrast color scheme
" https://vimcolorschemes.com/catppuccin/nvim/
" https://vimcolorschemes.com/olimorris/onedarkpro.nvim/

" ~~~~~ Tools for designing/debugging colorschemes
"Plug 'RRethy/vim-hexokinase'
"Plug 'lifepillar/vim-colortemplate'


" ~~~~~ Lines: Statusline, Tabline, etc. ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
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


" ~~~~~ Buffers & Tabs (other than their lines)  ~ ~ ~ ~ ~ ~ ~ ~ {{{2
"   Originally I linked to 'weynham' version; but this one seems
"   newest (albeit still last changed in 2016).  Maybe also check
"   out 'arenieri' fork, for a few different patches.  If we like
"   it and it seems necessary, then we could may yet another fork
"   to try integrating changes from the hundreds of other forks.
"Plug 'brailsmt/vim-plugin-minibufexpl'
"   Delete buffers & close windows without ruining layout!
"Plug 'moll/vim-bbye'
"   TODO: compare vim-bbye to this one:
"Plug 'qpkorr/vim-bufkill'


" ~~~~~ Git & other VCSes  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
Plug 'airblade/vim-gitgutter', wrengr#plug#Cond(has('signs'))
" Like gitgutter, but for several VCSes
" Note: since PR#307 (2019-10-01) you can use `:SignifyHunkUndo` to
" revert hunks a~la gitgutter (n.b., the command was renamed since that PR).
" Not sure if there's a command for staging hunks, but see:
"   <https://github.com/mhinz/vim-signify/issues/119>
" BUG: We cannot use the `||` operator in that conditional; something
"   about how the :Plug command (or any user-defined command?) handles
"   <Bar> causes it to break in an inscrutable manner.  So if we want
"   to re-add the condition that has('nvim') also works, then we'll need
"   to break the whole condition out as a function.
" Note: You also cannot use `s:` scoped variables in the conditions; see:
"   <https://www.reddit.com/r/neovim/comments/omrcje/using_vim_variables_in_vimplugs_arguments/>
Plug 'mhinz/vim-signify', (has('patch-8.0.902') ? {} : { 'tag': 'legacy' })
  " HACK: Signify's README.md is wrong, 'legacy' is a 'tag' not a 'branch'.
  " TODO: should we add {'tag':'stable'} for the async case?
  " Note: So far there's no way to add truly new VCSes to Signify,
  "   instead you need to coopt the name of one that's already supported.
  "   For more details, see: <https://github.com/mhinz/vim-signify/issues/327>
  let g:signify_vcs_list = ['git', 'hg', 'darcs']
  "let g:signify_difftool = 'gnudiff'      " for darcs to use -U0 flag
  " Note: using signify at google is tricksy; so ~/.vimrc_google will add
  "   some additional configuration.
  " BUG: Signify wants to bind `[c ]c` too; so it's gonna fight with
  "   gitgutter.  For now, we'll try this workaround.
  let g:gitgutter_enabled=0
  let g:signify_disable_by_default=0
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
" <https://gist.github.com/romainl/a3ddb1d08764b93183260f8cdf0f524f> " 'git-jump'
"
" This defines a command `:Diff [githash]`
" See: <https://gist.github.com/romainl/7198a63faffdadd741e4ae81ae6dd9e6>
" TODO: Should be easy enough to make a fork that handles both Git
"   and Mercurial (etc).
" TODO: Also, I kinda feel like the <q-mods> aren't being handled
"   entirely appropriately... Not that I know much about that.
"Plug 'homogulosus/vim-diff'


" ~~~~~ Picking up where you left off  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
" Note: there are a few latent interaction bugs with other plugins:
" * vim-plug    -- Uncommon, but see `:h startify-faq-12`
" * Goyo        -- Specifically when using `:h startify-faq-17`; bugfix is:
" <https://github.com/mhinz/vim-startify/wiki/Known-issues-with-other-plugins>
" * NERDTree    -- Common. `:h startify-faq-17`, `:h startify-faq-14`
Plug 'mhinz/vim-startify'
  " Limit the number of MRU and cwd-MRU files listed.
  let g:startify_files_number=5
  " No, don't change our :pwd thankyouverymuch.
  let g:startify_change_to_dir=0
  " TODO: (`:h startify-faq-18`) files on nfs mounts can cause a
  "   lot of slowdown.  That faq suggests adding nfs mounts to
  "   g:startify_skiplist, but that'll completely filter them out
  "   (defeating my purpose for using startify) rather than just
  "   disabling the IO checks.
  " TODO: easiest way to add a custom directory to g:startify_lists?
  " TODO: also, see the help of g:startify_lists for an idea about listing recent git (or other vcs) commits.
  let g:startify_padding_left=10
  "let g:startify_fortune_use_unicode=1     " For headers; iff it doesn't offend
  let g:startify_custom_header=['', '', ''] " Very boring header.
    " TODO: maybe keep the startify#fortune#quote() or even the
    " #boxed(); it's just that the #cowsay() was too huge!
  "
  " TODO: update our colorscheme to handle `:h startify-colors`
  " TODO: (unrelated to startify per se, but: update our colorscheme to
  "   handle helpExample better; because Comment isn't the best thing...)

"Plug 'farmergreg/vim-lastplace'


" ~~~~~ File-tree browsing ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
"Plug 'scrooloose/nerdtree',         { 'on': 'NERDTreeToggle' }
"Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
"Plug 'justinmk/vim-dirvish'  " Alternative to nerdtree.
"Plug 'Shougo/vimfiler.vim'   " Alternative to netrw (end-of-life => defx.nvim)
"Plug 'Shougo/defx.nvim'      " Alternative to netrw (Vim 8.2 || Nvim 0.4.0)
"Plug 'tpope/vim-vinegar'     " Enhancing netrw to obviate nerdtree.
"Plug 'eiginn/netrw'          " In case we want newer than the built-in version.
    " netrw versions:       Comes with:
    " 156  (2016 Apr 20)    OSX 10.14 vim     8.0.~1283  (8.0 == 2016 Sep 12)
    " 156  (2016 Apr 20)    Fink      vim-nox 8.1.0296   (8.1 == 2018 May 18)
    " 165  (2019 Jul 16)    Debian(?) vim     8.1.2269   (8.1 == 2018 May 18)
    " 171  (2021 Aug 16)    Fink      vim-nox 8.2.3404-1 (8.2 == 2019 Dec 12)
    " 171e (2020 Dec 15)    'eiginn/netrw'    f665b0d           (2020 Dec 27)


" ~~~~~ Searching  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2

" ~~~~~ Project-wide Fuzzy matching
" Of the main three: Ctrl-P is the oldest and requires the least
" configuration; command-t uses a custom C implementation tightly bound
" to vim; and fzf is the newest, with a custom Go implementation that
" works for any text stream.

"Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
"  Plug 'junegunn/fzf.vim'              " Better default wrappers for fzf.
"Plug 'Shougo/unite.vim'                " deprecated: > Shougo/denite.nvim > Shougo/ddu.vim
"Plug 'ctrlpvim/ctrlp.vim'
"Plug 'wincent/command-t'
    " N.B., command-t's wildignore works differently than vim's builtin:
    " <https://github.com/octref/RootIgnore/issues/5>
    " <https://github.com/wincent/command-t/blob/7364a410bc4f0d7febc183678cd565066dfd1e73/doc/command-t.txt#L1102>
"Plug 'Yggdroot/LeaderF',               " fuzzy + ctags + gtags + ripgrep +...
"  \ { 'do': ':LeaderfInstallCExtension' }  " Use C innstead of Python
"   <https://github.com/Yggdroot/LeaderF/wiki/Leaderf-rg>
"   <https://github.com/Yggdroot/LeaderF/wiki/Leaderf-gtags>

" ~~~~~ Grep replacements
"Exec <https://beyondgrep.com>          " The `ack` replacement for `grep` (sloooow)
"Exec 'ggreer/the_silver_searcher'      " The `ag` replacement for `ack`
"Exec 'BurntSushi/ripgrep'              " The `rg` replacement for `ag`
"Exec 'Genivia/ugrep'                   " The `ug`, faster even than `rg` (on ugrep's benchmarks; rg wins on some of rg's benchmarks)
" TODO: see WIP <~/.vim/autoload/wrengr/grepprg.vim>
" experimental, about the same speed as ripgrep; probably not production-ready but worthwhile to look at...
"Exec 'stealth/grab'
"Exec 'sampson-chen/sack'               " Wrapper around Ack/Ag to reduce repetition in searching & opening files.

"Plug 'wookayin/fzf-ripgrep.vim'        " fzf + rg
    " See also <https://medium.com/@crashybang/supercharge-vim-with-fzf-and-ripgrep-d4661fc853d2>
"Plug 'rking/ag.vim'                    " Use :Ag instead of :grep (deprecated!)
    " <https://github.com/rking/ag.vim/issues/124#issuecomment-227038003>
"Plug 'mileszs/ack.vim'                 " Use :Ack (for `ack` or `ag`)
    " <https://github.com/mileszs/ack.vim#can-i-use-ag-the-silver-searcher-with-this>
"Plug 'chrisjohnson/vim-grep'           " minor variation on 'mileszs/ack.vim'
    " 'vim-grep' has terrible mappings that clobber useful things; so don't use it but maybe copy stuff from it.
"Plug 'jremmen/vim-ripgrep'             " Prolly not the best one? (last: 2018)
"Plug 'wincent/ferret'                  " :Ack command for ack, ag, rg.
"Plug 'jesseleite/vim-agriculture'
    " See also <https://jesseleite.com/posts/4/project-search-your-feelings>

" ~~~~~
"Plug 'vim-scripts/IndexedSearch'
"Plug 'vim-scripts/SmartCase'
"Plug 'vim-scripts/gitignore'

" ~~~~~ Enhancing &incsearch and &hlsearch
"Plug 'haya14busa/incsearch.vim'
"  Plug 'haya14busa/incsearch-easymotion.vim'
"  Plug 'haya14busa/incsearch-fuzzy.vim'    " seems to do it's own fuzzy thing (and/or it uses 'osyo-manga/vital-over'?)
"  Plug 'haya14busa/incsearch-migemo.vim'   " Japanese kana+kanji(!!)
"   Exec 'koron/cmigemo'                    " Dependency
"   Plug 'Shougo/vimproc.vim'               " Dependency
"Plug 'romainl/vim-cool'
"Plug <https://vimawesome.com/plugin/traces-vim-left-unsaid>

" ~~~~~ Enhancing `* #`
" <https://stackoverflow.com/a/13682379>
" <https://stackoverflow.com/a/49944815>
" <https://stackoverflow.com/a/4262209> etc etc etc
" <https://stackoverflow.com/a/54324658>
"Plug 'bronson/vim-visual-star-search'
"Plug 'vim-scripts/star-search'

" ~~~~~ Enhancing `f F t T`
"Plug 'dahu/vim-fanfingtastic'
"Plug <https://www.vim.org/scripts/script.php?script_id=3877>
"Plug <https://www.vim.org/scripts/script.php?script_id=4726>
"Plug 'rhysd/clever-f.vim'


" ~~~~~ Undoing  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
" <https://docs.stevelosh.com/gundo.vim/>
" GPLv2+; requires: Vim >= 7.3, Python >= 2.4
" Git repo is active this year; though the most recent tagged version
" is 2016 (adding neovim support, and fixing python3 incompatibilities).
"Plug 'sjl/gundo.vim'

" Forked from gundo; supposedly adds a bunch of features and fixes,
" but the details are hazy (since it looks like gundo inncorporated
" them too).  Though the search feature seems really helpful.
" Still GPLv2, Vim >= 7.3 || neovim, python >= 2.4 || python3.
" Git repo is also active this year; latest release version was 2018.
"Plug 'simnalamburt/vim-mundo'

" Seems at least superficially similar; but is pure vimscript.
" Git repo also active this year; last official release was 2019.
" Though see <https://twitter.com/voldikss/status/1122515366524129280?lang=en>
"Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' } " [#jg]


" ~~~~~ Alignment, Indentation, & Folding  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
"Plug 'godlygeek/tabular'
"Plug 'junegunn/vim-easy-align'
"Plug 'michaeljsmith/vim-indent-object' " adds text objects `ii` / `ai`
"Plug 'vim-scripts/Align'
"Plug 'Yggdroot/indentLine', { 'on': 'IndentLinesEnable' } " [#jg]
    " junegunn uses:
    " BUG: um, isn't that a bit circular?
    "autocmd wrengr_vimrc User indentLine doautocmd indentLine Syntax
    "let g:indentLine_color_term = 239
    "let g:indentLine_color_gui = '#616161'
    " Though we'll want to adapt that to our colorscheme.
    " BUG: cterm-239 is #4e4e4e; whereas the closest to #616161 is cterm-241 (#626262)
    " Note: we already use cterm-239 for AbsoluteLineNr, fwiw

" Make &fdm faster by only updating folds as needed (instead of far
" too often).  This also provides enhancements for `:windo` and
" corrects several bugs therein.
"Plug 'Konfekt/FastFold'
"Plug 'Konfekt/FoldText'    " Fancy &foldtext
"Plug 'zhimsel/vim-stay'    " Automatically call `:mkview` and `:loadview`
"Plug 'wsdjeg/vim-fetch'    " (has integration with vim-stay)
"Plug 'kaile256/vim-foldpeek'   " Yet another version of fancy &foldtext


" ~~~~~ Simple text editing. ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
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
" ~~~~~ Language-Generic Programming Support ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
" ~~~~~ LSP (and asynchronicity)                                 {{{3
" Normalized async job control api for vim and neovim.
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
" ~~~~~ YCM
" N.B., YCM is basically a full-fledged IDE; so it's probably never
" something we'd actually enjoy.
"Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
" TODO: why did we use 'Valloric' here rather than 'ycm-core' ?
" Warning: <$VIMPLUG_URL/wiki/faq#youcompleteme-timeout>
"Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
" or maybe: { 'do': './install.sh --gocode-completer --tern-completer' }

" ~~~~~
"Plug 'ervandew/supertab'

" TODO: maybe consider 'Shougo/ddc.vim' as an alternative to asyncomplete.
"   See ~/.vim/NOTES/autocompletion.txt for more info.

" ~~~~~ AsynComplete
"Plug 'prabirshrestha/asyncomplete.vim'
"  Plug 'prabirshrestha/asyncomplete-lsp.vim'   " for: 'prabirshrestha/vim-lsp'
"    Plug 'prabirshrestha/asyncomplete-necovim.vim'    | Plug 'Shougo/neco-vim'
"    Plug 'prabirshrestha/asyncomplete-necosyntax.vim' | Plug 'Shougo/neco-syntax'
" N.B., Shougo's neco stuff has in the plugin/ part, the following:
"   autocmd User CmSetup call cm#register_source({...})
" That 'cm' is actually 'roxma/nvim-completion-manager' (which has
" been deprecated in favor of 'ncm2/ncm2').  However, because it's
" a User autocmd, I doubt that anyone will try to call it (excepting
" 'cm' itself); so technically we can install prabirshrestha's wrapper
" which will call Shougo's code, but without actually installing the
" 'cm' part.  If we're worried, we can always use :au! to remove
" those specific autocmds.
" TODO: may also consider using the 'ilms49898723/neco-syntax' and
" 'IngoMeyer441/neco-vim' forks, since they're better maintained (or
" at least ahead by a couple dozen commits).

" ~~~~~ Snippets
" The snippets engine itself.
" BUG: Mayari's vim-nox 8.2.3404-1 doesn't have '+python3'.
"Plug 'SirVer/ultisnips', wrengr#plug#Cond(v:version >= 704 && has('python3'))
"
" Some kinda alternative engine.  They mention being TextMate-like in their
" snippet features.
"Plug 'garbas/vim-snipmate'
"   Plug 'marcweber/vim-addon-mw-utils' " dependency; caching and lazy funcref.
"   Plug 'tomtom/tlib_vim'              " dependency; utility functions.
"
" The actual snippets themselves.  Both ultisnips and snipmate use this.
"Plug 'honza/vim-snippets'

" Yet another alternative engine. (N.B., this has been deprecated
" in favor of 'Shougo/deoppet.nvim'; however deoppet is NeoVim-only,
" and also requires Python3.)  Suggested to use with 'deoplete',
" but not required.
"Plug 'Shougo/neosnippet.vim'
"   " The default snippets themselves.
"   Plug 'Shougo/neosnippet-snippets'


" ~~~~~ Ctags (:help usr_29)                                     {{{3
" For additional help on ctags, see also:
"   <http://www.oualline.com/vim/10/top_10.html>
"   <https://andrew.stwrt.ca/posts/vim-ctags/>
" TODO: for debugging certain issues on OSX (and more generally):
" <https://dev.to/zev/how-i-got-go-to-definition-working-in-vim-in-2019-2ec2>
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
"Plug 'soramugi/auto-ctags.vim'

" TODO: see also "gtags" (GNU Global)
" <https://www.gnu.org/software/global/download.html>
" <https://github.com/Yggdroot/LeaderF/wiki/Leaderf-gtags>


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
"
"Plug 'vim-vdebug/vdebug', (has('python3') ? {} : {'tag': 'v1.5.2'})

" Async syntax checking.
"Plug 'osyo-manga/vim-watchdogs'
"   Plug 'thinca/vim-quickrun'                  " dependency (verified)
"   Plug 'Shougo/vimproc.vim', {'do' : 'make'}  " dependency (they say...)
"   Plug 'osyo-manga/shabadou.vim'              " dependency (they say...)
"   Plug 'jceb/vim-hier'                        " dependency? extension?
"   Plug 'dannyob/quickfixstatus'               " dependency? extension?


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Specific Programming Languages ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2

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

" TODO(2021-09-13): N.B., :PlugStatus is showing the following
" modules as loaded despite not opening any relevant files: 'vim-bsv',
" 'haskell-vim', 'applescript.vim', 'vim-cpp-modern', 'systemverilog.vim',
" (Not 'verilog_systemverilog.vim'!), 'coq.vim', 'vim-llvm'.  They
" may all be innocuous to load when unneeded, but worth keeping an
" eye on.  Also, remember to use `:scriptnames` to see the order
" things are loaded.


" ~~~~~ {for: vim} ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
" ~~~~~ [#lint]
"Exec 'Vimjas/vint'             " 'vint' for syntastic.
"Plug 'syngan/vim-vimlint'      " Easily usable by TravisCI; last mod: 2018-12-27
"   Plug 'ynkdir/vim-vimlparser'    " dependency
"   " N.B., since vimlint is written in vimscript(+python) the devs
"   " themselves say it's *very slow*; so while it can work with syntastic,
"   " they recommend using 'osyo-manga/vim-watchdogs' instead since it
"   " provides asynchronous syntax checking.
" The following three are alternatives mentioned by @syngan:
"Exec 'ujihisa/vimlint'         " written in Clojure; last mod: 2013-07-23
    " Is forked from 'Shougo/neocomplcache.vim'
"Plug 'dbakker/vim-lint'        " written in Python;  last mod: 2013-11-20
"Plug 'dahu/VimLint'            " pure VimScript;     last mod: 2010-08-11
" ~~~~~
"Plug 'junegunn/vader.vim'      " [#test] unit-testing.


" ~~~~~ {for: haskell} ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
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
" [#lsp]
" BUG: Doesn't work with ghc-9:
"   <https://github.com/ennocramer/floskell/issues/66>
"Exec 'haskell/haskell-language-server'
" [#lint]
"   In lieu of syntastic.
"Plug 'eagletmt/ghcmod-vim'
"   Use 'mpickering/apply-refact' to apply hlint suggestions.
"Exec 'mpickering/apply-refact'
"Plug 'mpickering/hlint-refactor-vim',
"   \wrengr#plug#Cond(executable('refactor') && executable('hlint'))
"   Use 'haskell/stylish-haskell' for code formatting.
" BUG: Doesn't work with ghc-9:
"   <https://github.com/haskell/stylish-haskell/issues/370>
"   <https://github.com/haskell/stylish-haskell/issues/378>
"   Also I got a typecheck error when trying to build it (or one of the dependencies)
"Exec 'haskell/stylish-haskell'
"Plug 'nbouscal/vim-stylish-haskell',
"   \wrengr#plug#Cond(executable('stylish-haskell'))
"   " See also <https://hackage.haskell.org/package/hls-stylish-haskell-plugin>
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
"Exec 'https://gitlab.haskell.org/haskell/ghcup-hs'
"Plug 'hasufell/ghcup.vim'


" ~~~~~ HDLs ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
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
  autocmd wrengr_vimrc BufRead,BufNewFile *.bs setf haskell
endif

" Not an HDL, but is somewhat related.
"Plug 'hwayne/tla.vim', { 'for': TLA+ }
" See also:
" TLA+ (itself):     <http://lamport.azurewebsites.net/tla/tla.html>
" TLA+ Proof System: <http://tla.msr-inria.inria.fr/tlaps/content/Home.html>
" TLA+ Toolbox:      <http://lamport.azurewebsites.net/tla/toolbox.html>


" ~~~~~ LLVM/MLIR  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
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


" ~~~~~ {for: markdown}  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
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
"Plug 'markdownlint/markdownlint'   " [#lint] the `mdl` program
" ~~~~~ {for: markdown.pandoc} ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
"Plug 'vim-pandoc/vim-pandoc'
"Plug 'vim-pandoc/vim-pandoc-syntax'



" ~~~~~ {for: applescript} ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
" [#syntax]
" This particular fork seems a lot more complete than the original
" vim-scripts/applescript.vim; however, it's still not the greatest.
" In part because they use Statement for all the keywords (alebeit
" Keyword just links to Statement).
Plug 'vito-c/applescript.vim'

" ~~~~~ {for: bash}  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
"Exec 'koalaman/shellcheck'     " [#lint] usable by syntastic, Ale, and Neomake
    " Or, for manual usage (cf., <https://vimways.org/2018/runtime-hackery/>):
    "makeprg=shellcheck\ -s\ bash\ -f\ gcc\ --\ %:S
    "errorformat=%f:%l:%c:\ %m\ [SC%n]
    " Or use `:compiler shellcheck` and see: </opt/sw/share/vim/vim82/compiler/shellcheck.vim>
    " shellcheck also has `-f diff` for use with `git apply` etc.

" ~~~~~ {for: [c, cpp]}  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
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

" TODO: see `:h ft-c-syntax` re gobal-var settings for the builtin/default C parser.

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

" ~~~~~ {for: tablegen}  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
" TODO: find a decent syntax highlghter for LLVM/MLIR (namely the tablegen/.td language)

" ~~~~~ {for: clojure} ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
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

" ~~~~~ {for: coq} ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
" [#syntax]
Plug 'jvoorhis/coq.vim'

" ~~~~~ {for: go}  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
"Plug 'fatih/vim-go', wrengr#plug#Cond(v:version >= 800, { 'do': ':GoInstallBinaries' })
    "let g:go_fmt_command = 'goimports'
"Plug 'nsf/gocode', { 'rtp': 'vim', 'do': s:vimplug_dir . '/gocode/vim/symlink.sh' }

" ~~~~~ {for: javascript}  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
"Plug 'moll/vim-node'
"Plug 'pangloss/vim-javascript'

" ~~~~~ LaTeX  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
" N.B., LaTeX files show up as &ft=tex
" omg this looks nice
"Plug 'LaTeX-Box-Team/LaTeX-Box'

" {for: [tex, bib]}
" However, this one is more modern and is still actively developed
" (v2.7.1 was released just a few days ago).  It started out as a
" rewrite of 'LaTeX-Box' to modernise it: <https://vi.stackexchange.com/a/5747>.
" For more comparison: <https://tex.stackexchange.com/a/148473>.
" Also re highlighting, be sure to see:
" <https://github.com/lervag/vimtex/issues/1946#issuecomment-843674951>
"Plug 'lervag/vimtex', wrengr#plug#Cond(has('patch-8.0.1453')) " Or neovim 0.4.3

" ~~~~~ {for: prolog}  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
" TODO: consider these, mentioned at <https://stackoverflow.com/q/19610734>
"   Actually for Logtalk, which extends Prolog: <https://logtalk.org>
"Plug 'LogtalkDotOrg/logtalk3' " ./coding/vim
"   Widely known, but abandoned since June 2014.  Mainly for ISO Prolog.
"   (See also the 'Aluriak/ASP.vim' fork)
"Plug 'adimit/prolog.vim'
"   Lesser known, but more updated and advanced.
"   Also supports different flavors of Prolog: SWI, GNU, etc.
"Plug 'soli/prolog-vim'
"   Not mentioned by the above, and untouched since 2018, but this one does LSP stuff:
"Plug 'LukasLeppich/prolog-vim'
"
" Only tangentially related, but, see this link re footpedals:
" <https://groups.google.com/g/swi-prolog/c/DwGFeg9k0Mg/m/avCpztD7AQAJ>

" ~~~~~ {for: python}  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
"Plug 'jmcantrell/vim-virtualenv'   " for Python virtualenvs (what about venv?)
"Plug 'tmhedberg/SimpylFold'        " Fancy folding so you can still see docstrings
"Plug 'abarker/cyfolds',            " Similarly fancy syntax-aware folding.
"  \ wrengr#plug#Cond(has('python3') && has('timers'))
"   Also requires actually compiling the Cython code.

" ~~~~~ {for: ruby}  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
"Plug 'tpope/vim-bundler', { 'for': 'ruby' } " [#jg]

" ~~~~~ {for: rust}  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{3
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

" ~~~~~ Quickfix                                                 {{{3
"Plug 'romainl/vim-qf'                  " like our bracketoids, and more
"Plug 'romainl/vim-qlist'               " Improve `:{i,d}list` and associated bracketoids
"Plug 'tomtom/quickfixsigns_vim'
"Plug 'stefandtw/quickfix-reflector.vim' " For editing qflists
"Plug 'mh21/errormarker.vim'
"Plug 'Konfekt/vim-compilers'
"Plug 'jceb/vim-hier'                   " Highlight qf/loclist entries in the buffer
"Plug 'jceb/vim-editqf'                 " For editing qflists
"Plug 'dannyob/quickfixstatus'          " Alternative highlighting for qf/loclist
    " Warning: both 'vim-hier' and 'quickfixstatus' were last touched
    " in 2011.  Whereas 'vim-editqf' was last touched in 2014.
"Plug 'salsifis/vim-qfmanip'

" ~~~~~ Completely unsifted                                      {{{3
"Plug 'tpope/vim-sensible'              " More-sensible defaults
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
" and <https://github.com/JesseLeite/dotfiles/blob/54fbd7c5109eb4a8e8a9d5d3aa67affe5c18efae/.vimrc#L444-L456>
"Plug 'wellle/targets.vim'
"Plug 'sheerun/vim-polyglot'
"Plug 'terryma/vim-expand-region'
"Plug 'tomtom/tcomment_vim'
"Plug 'tpope/vim-rsi'
"Plug 'tpope/vim-endwise'
"Plug 'tpope/vim-repeat'                " better <.> repetition support
"Plug 'tpope/vim-sleuth'
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
"Plug 'kana/vim-fakeclip'               " Emulate '+clipboard'
"Plug 'nacitar/terminalkeys.vim'        " Improved support for rxvt
    " See also 'godlygeek/vim-files'
"Plug 'jeffkreeftmeijer/vim-nightfall'  " Adjust &background based on OSX's dark mode.
    " The applescript doesn't look like it handles the new 'Auto' mode; but oh well.
"Plug 'justinmk/vim-ipmotion'           " Improve the <{> <}> motions
"Plug 'chrisbra/NrrwRgn'
call plug#end()
unlet s:vimplug_dir
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Unicode support ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{1
" Note: if the occurrence of the utf8 characters below glitches out
" the cursor, then you probably need to adjust your terminal; since
" the glitch means that vim and the terminal are disagreeing about
" where the cursor actually is after printing the characters.
" (I.e., your terminal thinks they are typographically wide, taking
" up two columns; when in fact they should only take up one column.)
if has('multi_byte')
  " Note: Per `:h :scriptencoding`, we must set &encoding before
  " we call :scriptencoding
  set encoding=utf-8
  scriptencoding utf-8
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


" ~~~~~ &langmap support                                         {{{2
" Prevent &langmap from applying to characters generated by a
" mapping, since that's liable to break the mappings.  &langremap
" is enabled by default, but that's only for backwards compatibility
" reasons.
" HT: vim82/defaults.vim
if has('langmap') && exists('+langremap')
  set nolangremap
endif


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Terminal Configuration ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{1
" NOTE: Vim has both `$TERM` (for the env var) and `&term` (for internal use).
" The example at `:h term-dependent-settings` suggests we should
" be checking `&term` rather than `$TERM`.

" WARNING: Some people like <https://blog.sanctum.geek.nz/term-strings/>
" think that this whole approach is totally wrongheaded.  In principle
" I agree; however in practice it's terribly convoluted to do the
" right thing.  See also <https://gist.github.com/KevinGoodsell/744284/717b220f7c168725748781d58609dce5d7cf8603>
" which offers some particular solutions for dealing with screen.
" Another source of hints on debugging this kind of stuff is
" <https://github.com/vim-syntastic/syntastic/issues/822>
" (while that bug is old and closed, it has helpful info.)

" ~~~~~ GNU Screen integration ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
" <http://vim.wikia.com/wiki/GNU_Screen_integration>
" <https://vim.fandom.com/wiki/GNU_Screen_integration>
" <https://github.com/mileszs/dotfiles/blob/3883ca1d8f54b858f9c28599b5304eadae184743/screenrc>

" If our ~/.screenrc has changed the TERM env var, then we'll need
" to adjust some things because Vim doesn't understand/like that.
" NOTE: Our ~/.bash_profile etc may end up re-resetting TERM, so can't
" rely on this for detecting whether we are in fact inside screen.
if &term =~? '^screen'
  " Disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  " HT: <https://sunaku.github.io/vim-256color-bce.html>
  " TODO: Shouldn't we really be checking for the '-bce' suffix instead?
  if &term =~? '256color'
    set t_ut=
  endif

  " FIXME: Since we can't get italics to work within GNUScreen (i.e., as
  " actual italics, rather than as standout), we're disabling them for now.
  let g:overmorrow#cterm_italic = ''

  " NOTE: We use the `exe "set foo=\<esc>bar"` idiom to avoid needing
  " to type literal escape characters (since those don't copy-paste well).

  " Fix <S-Tab> on GNU screen.  HT: <https://superuser.com/a/196162>
  " terminfo 'cbt' == vim &t_bt; terminfo 'kcbt' == vim &t_kB
  "exe "set t_kB=\<Esc>[Z"

  " TODO: Frankly, if we're going to do these two, then we might
  " as well set them in the ~/.screenrc itself.
  " BUG: This is setting GNUScreen's `:title` rather than the actual
  " iTerm2 window's title.
  "if has('title')
  "  exe "set t_ts=\<Esc>k"
  "  exe "set t_fs=\<Esc>\\"
  "endif

  " Disable <C-a> when in GNU screen (not that we use it much anyways).
  "nnoremap <C-a> <Nop>
endif

" TODO: the altscreen thing seems to occasionally fail and leave
" gibberish on the screen when we quit vim (especially after using
" a lot of `:!` or `:redir` commands); so we may want/need to much
" around with &t_te (and &t_ti).  See `:help xterm-screens` and
" <https://invisible-island.net/xterm/xterm.faq.html#xterm_tite>

" ~~~~~ Extend <C-l> to also stop highlighting the current search.
" N.B., the default <C-l> can also be lazy (both with and without
" &lazyredraw), so this is (I think) stricter about ensuring the
" redraw happens immediately.
" Note: see `:h map_bar` about the different spellings of bar.
" However, I can't find anywhere that says anything about when to
" use `<Bar>` vs `<CR>:` (both work just fine here).
nnoremap <silent> <C-l> :<C-u>noh<Bar>redraw!<CR>
" Note: there also exists commands :redrawstatus[!] and :redrawtabline

" ~~~~~ Terminal title ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
" <http://vim.wikia.com/wiki/Automatically_set_screen_title>
" <http://usevim.com/2012/06/13/set-title/>
if has('title')
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

" ~~~~~ Set up terminal colors, etc. ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
" TODO: see the help pages for &termguicolors, 'xterm-true-color',
" 'tmux-integration'.

" ~~~~~ Mouse support  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
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
" ~~~~~ Colorscheme ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{1
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
  "
  " First we set a default value, in case wrengr#SetBackground() bails out.
  set background=dark
  " TODO: Add this to an augroup, a~la 'jeffkreeftmeijer/vim-nightfall';
  " so that it's called automatically every so often, but not too
  " terribly often.
  call wrengr#SetBackground()

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
" ~~~~~ Lines & Columns ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{1
" ~~~~~ Cursor ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
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

" ~~~~~ Lines: cmdline, statusline, tabline  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
set showcmd             " Show the cmdline (cuz we're not still in the 1970s).
set cmdheight=1         " The cmd-*line*   is N rows high.
"set cmdwinheight=7     " The cmd-*window* is N rows high. (cf., `:h c_CTRL-F`)
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

" Always(=2) show the tabline, even if there's only one tabpage.
"set showtabline=1

" ~~~~~ Columns: linenr, colorcolumn ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
" ~~~~~ Line numbers                                             {{{3
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
  " BUG: (2023-01-03) When using CRD>gWindows this gives E117;
  " whereas when using ssh>gWindows it works fine. So we need to
  " update some sort of path setting somewhere; dunno if we can do
  " that from within vim, or if it needs to be done on the gWindows
  " machine...
  call OvermorrowRelinkLineNr()
endfun

set relativenumber
call s:LineNrToggle()

" ~~~~~ Final column                                             {{{3
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
" ~~~~~ Tabpages, Windows/Splits, Buffers, Diffs, & bracketoids  {{{1
" ~~~~~ Diff ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
if has('diff')
  " `diffopt` == Comma-separated list of settings for diff-mode.
  " The defaults are:
  " * Fink           8.2.3404                    : `internal,filler,closeoff`;
  " * Debian Rodete  8.2.4793-1+gl0              : `internal,filler,closeoff`;
  " * Catalina/10.15 8.1.1312 (minus 504 and 681): `internal,filler`;
  " * Monterey/12.4  8.2.4113                    :          `filler,closeoff`;
  " Warning: Apple's versions of vim remove xdiff support and
  " therefore don't allow `internal`.  This causes all sorts of
  " problems including E474 about not supporting `algorithm:patience`,
  " and on older macOS issues about still including `internal` in
  " the default despite it not actually being supported.  For all
  " the gory details, see:
  " <https://github.com/agude/dotfiles/issues/2#issuecomment-843639956>
  " <https://github.com/thoughtbot/dotfiles/issues/655#issuecomment-605019271>
  " <https://www.micahsmith.com/blog/2019/11/fixing-vim-invalid-argument-diffopt-iwhite/>
  "
  " 'closeoff' == when closing penultimate window-in-tab-with-&diff, do :diffoff
  "
  " HACK: Try to detect when we're using Apple's Vim, so we can
  " remove `internal` if we're on an old buggy version that still
  " includes it in the default.
  " BUG: has('mac') is unreliable! (see above)
  if has('mac') && $VIM == '/usr/share/vim'
    set diffopt-=internal
  elseif has('patch-8.1.0360') " HT: <https://stackoverflow.com/a/63079135>
    " Even though `internal` is part of the default (except on Apple),
    " we include it since it's necessary for `algorithm:patience`.
    set diffopt+=internal,algorithm:patience
  endif
  set diffopt+=vertical             " prefer vertical splitting
  if has('patch-8.2.2490') " <https://groups.google.com/g/vim_dev/c/fHjMJxVnSRg>
    set diffopt+=followwrap         " leave &wrap alone
  endif
  " see also *fold-diff*, *diff-diffexpr*, &diffexpr, &vimdiff, &cursorbind
endif

" ~~~~~ Buffers  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
" I hate <Q> switching to ex-mode.  Also, I hate that wiping buffers
" also kills the window it's in.  So we remap <Q> to close buffers
" nicely.
nnoremap Q :call wrengr#BufferDelete()<CR>

" Have quickfix and :sb{*} commands go to windows that already have
" the file open, whether in current tab or another.  If there is none,
" then quickfix commands will open in a new tabpage (rather than
" ruining the current layout via 'split'/'vsplit', or hiding current
" work via 'uselast').
"set switchbuf=useopen,usetab,newtab

" ~~~~~ Windows/Splits ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
set winheight=20        " Try to keep the active window  at least this tall.
"set winminheight=1     " Try to keep non-active windows at least this tall.
"set winwidth=20        " Try to keep the active window  at least this wide.
"set winminwidth=1      " Try to keep non-active windows at least this wide.

"set equalalways
"set eadirection=both   " Does &ea apply to vertical, horizontal, or both?
"set winfixheight       " If &ea, then keep height fixed when opening/closing.
"set winfixwidth        " If &ea, then keep width  fixed when opening/closing.

"set splitright         " :vs puts the new window (and focus!) to the right.
set splitbelow          " :sp puts the new window (and focus!) to the bottom.

" TODO: a lot of times I'd really like to do a vertical split where
"   the new window goes to the right, but the focus stays with the
"   old window.  Is there any good shortcut for that rather than
"   defining our own bespoke command?


" ~~~~~ Bracketoids (and related macros) ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
" Many of these are a~la 'tpope/vim-unimpaired', though I came to
" them through other means.  (And I'm not using vim-unimpaired
" because I'm not a fan of how the other mappings are done.)

" TODO: pretty sure none of these clash with any builtins...
"   By default gitgutter wants to take `]c` and `[c`, so we can't
"   just give those to :cnext/:cprev.  That comes from the default
"   mappings for `[c ]c` meaning to go to start/end of change (I'm
"   guessing in Vim's undo-history sense?).  See also: `g+ g- g, g;`
"   And Signify also wants to set those `[c ]c` mappings.
" In any case, I'm thinking to not let gitgutter (or signify) do
" that, and to map them to `[g ]g` or something instead; and updating
" all the other gitgutter mappings to match, naturally.

" Note: Re getting these to work with counts: when vim processes
" the `:` it will automatically expand it to `:.,.+N` where N is one
" less than the count provided.  Unfortunately these commands don't
" accept such ranges.  So we must use <C-u> to remove that auto-expanded
" range.  Then we need to inject the actual v:count to pass that to
" the underlying command.  (Note that v:count defaults to 0 when no
" count is provided; so for commands that can't hande that, we use
" v:count1 instead.)  I'm opting to do that via <expr> because it's
" inoffensive re handling the special characters <C-u> and <CR>.
" Though we could always use other implementations, like using <C-r>=
" or :execute.
" TODO: for some of these, we may consider using `:h :map-cmd` in
"   lieu of the leading xo_`:<C-u>` or i_`<C-o>:`.  Since all these
"   are just for n-mode that doesn't actually apply here, but it's
"   important to remember for all the ohter places we use <expr> or <C-u>.
" Note: for commands that can't handle a zero count, there's always
" v:count1 instead.  Also, some of the commands have explicitly
" special behavior when there's *no* count given.  Also, some
" commands have wraparound behavior, but they differ in the specifics.
" TODO: we might should use the (v:count?v:count:'') idiom more
"   liberally, to ensure we don't accidentally eliminate such special
"   behavior. (HT: tpope)

" TODO: make these all honor &foldopen and &foldclose.  The
"   wrengr#qf#BracketExpr() function handles &foldopen for quickfix
"   windows, but the others will need to check different things
"   within &foldopen.
" BUG: vim/iterm2 has been behaving oddly ever since I factored
"   wrengr#qf#BracketExpr() out for these mappings.  I don't know
"   why/how that would cause problems, but it seems indicative of
"   some sort of bug somewhere.

if has('quickfix')
  " ~~~~~ Quickfix/errors                                        {{{3
  " Note: these understand v:count=0 just fine; it's just a bit
  "   unsightly to be echoed that way.
  nnoremap <expr> [q  wrengr#qf#BracketExpr(1, 'cprev')
  nnoremap <expr> ]q  wrengr#qf#BracketExpr(1, 'cnext')
  nnoremap <expr> [Q  wrengr#qf#BracketExpr(0, 'cfirst')
  nnoremap <expr> ]Q  wrengr#qf#BracketExpr(0, 'clast')
  " My names for these two are punning off the meaning of line(".")
  " TODO: these have default v:count=1 so do they actually allow v:count=0 ?
  " TODO: the :c{above,below} commands best match line(".") but
  " maybe we'd prefer to bind these to :c{before,after} instead
  " (ala getpos("."))?
  nnoremap <expr> [.q  wrengr#qf#BracketExpr(1, 'cabove')
  nnoremap <expr> ].q  wrengr#qf#BracketExpr(1, 'cbelow')
  " And these two are based off the patterning of the names in:
  " <https://github.com/tpope/vim-unimpaired/issues/195#issuecomment-921453951>
  " Though imo they should have different names instead...
  nnoremap <expr> [.Q  wrengr#qf#BracketExpr(1, 'cpfile')
  nnoremap <expr> ].Q  wrengr#qf#BracketExpr(1, 'cnfile')
  " TODO: should we also have stuff for :c{older,newer}?
  "   For a handly reference, see <https://stackoverflow.com/a/55117681>
  "   Re :c{older,newer} beware of getting E380;
  "   cf., <https://vimways.org/2018/colder-quickfix-lists/>
  "   Also see <https://github.com/romainl/vim-qf/blob/master/autoload/qf/history.vim>
  " TODO: others we might consider just to avoid using the cmdline
  "   so much include :cc, :cclose, :c{f,g,b,l}
  nnoremap <expr> <leader>zq ':<C-u>copen ' . (v:count ? v:count : '') . '<CR>'
  nnoremap        <leader>dq  :<C-u>cclose<CR>

  " TODO: want this?
  " HT: <https://gist.github.com/romainl/ce55ce6fdc1659c5fbc0f4224fd6ad29>
  "autocmd QuickFixCmdPost [^l]* cwindow
  " See also: <#gistcomment-3881035> therein.

  if has('autocmd') && has('localmap')
    augroup wrengr_vimrc
      autocmd FileType qf
        \ nnoremap <silent> <buffer> dd
          \ :call wrengr#qf#RemoveQuickfixItemUnderCursor()<CR>
    augroup END
  endif

  " ~~~~~ Quickfix/locations                                     {{{3
  nnoremap <expr> [l          wrengr#qf#BracketExpr(1, 'lprev')
  nnoremap <expr> ]l          wrengr#qf#BracketExpr(1, 'lnext')
  nnoremap <expr> [L          wrengr#qf#BracketExpr(0, 'lfirst')
  nnoremap <expr> ]L          wrengr#qf#BracketExpr(0, 'llast')
  nnoremap <expr> [.l         wrengr#qf#BracketExpr(1, 'labove')
  nnoremap <expr> ].l         wrengr#qf#BracketExpr(1, 'lbelow')
  nnoremap <expr> [.L         wrengr#qf#BracketExpr(1, 'lpfile')
  nnoremap <expr> ].L         wrengr#qf#BracketExpr(1, 'lnfile')
  nnoremap <expr> <leader>zl ':<C-u>lopen ' . (v:count ? v:count : '') . '<CR>'
  nnoremap        <leader>dl  :<C-u>lclose<CR>
  " TODO: ditto everything from above (though it's :ll ~ :cc because
  " vimish); including the 'tpope/vim-unimpaired' comments; and the
  " autocmd (with l* pattern and lwindow)
  " TODO: while `:copen` will work fine when there's no qflist;
  " `:lopen` will error when there's no loclist.  So we should
  " wrapper that to make it behave nicer; or wrapper :copen to
  " behave analogously (since :{c,l}{next,prev} all error when
  " there's no list, and the error message depends only on the 'c' vs 'l').
endif

" ~~~~~ Buffers                                                  {{{3
" Note: these commands have wraparound behavior, and they're robust
"   enough to always handle the v:count.  Though we still use the
"   idiom because it's a bit unsightly to echo the 0.
" Note: when there's only one listed buffer, these simply echo the
"   command (like :tab{p,n}) rather than issuing an error message
"   (like :{c,l}{prev,next}).  The command is also echoed whenever
"   the v:count causes us to loop around to the exact same buffer
"   we started from.
" BUG: The helppage says that when used in a help-buffer these'll
"   move between help-buffers; but that's not working for me, not
"   even with typing the commands manually (so it's nothing about
"   this mapping).
nnoremap <expr> [b         ':<C-u>' . (v:count ? v:count : '') . 'bprev<CR>'
nnoremap <expr> ]b         ':<C-u>' . (v:count ? v:count : '') . 'bnext<CR>'
nnoremap        [B          :<C-u>bfirst<CR>
nnoremap        ]B          :<C-u>blast<CR>
nnoremap        <leader>zb  :<C-u>ls<CR>
" TODO: would we want to have <leader>db for wrengr#BufferDelete()?
" TODO: we should also define some easy thing for <C-6> since that's impossible to reach.

" ~~~~~ Argument List                                            {{{3
" TODO: unlike the others, I got these actually from 'tpope/vim-unimpaired'.
"   And unlike the others, these fail hard whenever the arglist is
"   empty etc; are arglists some new/unused/unmaintained thing?  In
"   any case, if we do these then we'll want to do some extra
"   wrapping to make them friendlier.
"nnoremap <expr> [a ':<C-u>' . (v:count ? v:count : '') . 'prev<CR>'
"nnoremap <expr> ]a ':<C-u>' . (v:count ? v:count : '') . 'next<CR>'
"nnoremap        [A  :<C-u>first<CR>
"nnoremap        ]A  :<C-u>last<CR>
" TODO: when the arglist is empty it just leaves the command echoed
" there, rather than showing an empty list like :jumps etc do.  And
" when it's non-empty it just shows things as a list, rather than the
" nicer vertical formatting of :ls etc.  So we should make a wrapper
" that makes this nicer.
nnoremap <leader>za :<C-u>args<CR>

" ~~~~~ Tabpages                                                 {{{3
" Note: these commands *cannot* handle a 0 count.
" Note: these commands have wraparound behavior, but only when *no*
"   count is given; consequently, when the count is too high they
"   simply stop at the ends.  They're not robust like the buffer commands.
" Note: when there's only one tabpage, these simply echo the command
"   (like :b{prev,next}) rather than issuing an error message (like
"   :{c,l}{prev,next}).
" TODO: given the fragility mentioned above, these surely need more testing.
nnoremap <expr> [t ':<C-u>' . (v:count ? v:count : '') . 'tabprev<CR>'
nnoremap <expr> ]t ':<C-u>' . (v:count ? v:count : '') . 'tabnext<CR>'
" Remove now-redundant mappings.
map gT      <Nop>
map gt      <Nop>
map <C-w>gT <Nop>
map <C-w>gt <Nop>
" I guess we can leave the {nvi}_<C-PageUp>/<C-PageDown> bindings there.
" N.B., there's also g<Tab>, <C-w>g<Tab>, and <C-Tab> for analogue of <C-w>p
nnoremap [T         :<C-u>tabfirst<CR>
nnoremap ]T         :<C-u>tablast<CR>
nnoremap <leader>zt :<C-u>tabs<CR>

" TODO: 'tpope/vim-unimpaired' also does :ptprev and :ptnext; but if doing that then why not also do :ptfirst and :ptlast?  And really, that belongs under some other name than 't'; since ctags should not be confused with tabpages.


" ~~~~~ Misc (includes, declarations, tags,...)                  {{{3
" TODO: consider this pair from <https://www.reddit.com/r/vim/comments/7boh5s/comment/dpjr0ow/?utm_source=reddit&utm_medium=web2x&context=3> (N.B., `[z` and `]z` already exist...; though `[Z`/`]Z` may make sense as names for these)
"nnoremap <silent> z] :<C-u>silent! normal! zc<CR>zjzozz
"nnoremap <silent> z[ :<C-u>silent! normal! zc<CR>zkzo[zzz


" N.B., there's also these often unremarked upon ones by default:
"   [i      ]i      :isearch          [d      ]d      :dsearch
"   [I      ]I      :ilist            [D      ]D      :dlist
"   [<C-i>  ]<C-i>  :ijump            [<C-d>  ]<C-d>  :djump
"      <C-w>i       :isplit              <C-w>d       :dsplit
" TODO: see 'romainl/vim-qlist' for improvements to `:{i,d}list`
"   That's a bit unhygenic about metadata when saving/restoring
"   registers; but otherwise the implementation seems decent enough,
"   even if there are other bits I find unhygenic.  (Be sure to see
"   the 'studio-vx' fork if you want to add :botright to the :cwindow
"   calls. And see the 'wolloda' fork re adding a g:qlist_ignorecase
"   variable.)


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
" If we do those, then we should also handle the <C-w> variants.

" There's also:
"   <C-w><C-]>  :stag
"   <C-w>]      (also :stag)
"   <C-w>g<C-]> :stjump
"   <C-w>g]     :stselect
"
"   :cstag      for cscope+ctags integration; is like either
"               `:cs find g` or `:tjump` depending.
"
"   <C-w> {f <C-f> F gf gF} for exiting file under cursor, in new split or tab
"   <C-w><C-i> for opening include-files
"
"   <C-w>P      goto preview window. (is an error if there is none though, so we might want to wrap this to fail more gracefully)
"   <C-w>z      :pclose
"               :ppop       Should probably get mapped to <C-w>{
"   <C-w>}      :ptag
"   <C-w>g}     :ptjump


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Movement & Scrolling ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{1

set scrolloff=7         " Keep N lines between cursor and window top/bottom.
set sidescrolloff=10    " Keep N columns between cursor and window left/right.
" TODO: see also &scrollbind=no, &scrollopt=ver,jump, *scroll-binding*
" TODO: also &scrollfocus=no, &scrolljump=1
"set window=...         " Used by <C-f> and <C-b>
" TODO: consider setting &scrolljump; not sure if it'd ever matter though

" TODO: Check out the VCenterCursor() function at:
" <https://vim.fandom.com/wiki/Keep_your_cursor_centered_vertically_on_the_screen>
" It toggles between &so=999 and whatever &so we set normally.
" It also shows how to use autocmd for the OptionSet event, to
" automatically run some code whenever someone changes an option.


" ~~~~~ Gentler scrolling with Shift-Up/Down.  [non-jump]
" (Because they should not be synonymous with <PageUp>/<PageDown>!)
" TODO: what was the point of the <C-y>/<C-e> if we're just going to `zz`?
" TODO: can we wrap these to take a count again?
" TODO: reconsider whether the vo-modes should exist / get slightly
"   different definitions,
noremap  <S-Up>   10k10<C-y>zz
inoremap <S-Up>   <ESC>10k10<C-y>zzi
noremap  <S-Down> 10j10<C-e>zz
inoremap <S-Down> <ESC>10j10<C-e>zzi

" ~~~~~ Vertically-recenter the cursor after window scrolling.  [non-jump]
" (Adjust distance with &scroll; see also &startofline.)
" Note: the `M` command is a jump, but <C-u> and <C-d> aren't; and
" for these bindings we want the semantics of <C-u>/<C-d> just with
" moving the cursor to a better location (like `zz` would do, but we
" want to do it without undoing the extent of scrolling provided
" by <C-u>/<C-d>).
" Thus, to avoid updating the jumplist we use the command :keepjumps.
" Unfortunately that takes an Ex-command, so we have to use :normal!
" to convert our desired normal-mode `<C-u>M` to an ex-command.  But
" that doesn't work quite right because the <C-u> is a special
" character.  Usually we get around that by using :execute or <expr>,
" however in this case those would only make things worse: because
" they'd want to interpret our <C-u> as c_CTRL-u (rather than leaving
" it to the :normal to interpret it as n_CTRL-u), which then gives
" errors about ambiguous wildcard expansions.  We could get around
" that by doing yet another layer of escaping (ending up with
"   :execute "keepjumps normal! \<lt>C-d>M"<CR>
" ) and that works.  But only the `M` needs to be wrapped in :keepjumps,
" not the <C-u>; so it's easier to just say exactly that :)
nnoremap <C-Up>   <C-u>:keepjumps normal! M<CR>
nnoremap <C-Down> <C-d>:keepjumps normal! M<CR>
" TODO: imaps for <C-Up> and <C-Down>?

" ~~~~~ Move by display-lines rather than by file-lines.
" Warning: traditional `j`/`k` are linewise, whereas `gj`/`gk` are
" exclusive.  (Though exclusive makes more sense to me, so I'm cool
" with that.)  Fwiw, you can still use <C-n>/<C-p> to get the old
" file-linewise.
" HT: <https://vi.stackexchange.com/a/22576> re insertmode
noremap  <Up>   gk
inoremap <Up>   <C-\><C-o>gk
noremap  <Down> gj
inoremap <Down> <C-\><C-o>gj

" Simple `k`/`j` move by display-lines; whereas when providing a count,
" then uses file-lines and stores the motion in the jumplist (so you can
" cycle through them with <C-o> and <C-i>).
" HT: <https://www.reddit.com/r/vim/comments/4ifnbo/comment/d2y6zij/?context=3>
" HT: <https://www.hillelwayne.com/post/intermediate-vim/>
"     TODO: They also have a bunch of other nice hacks, like using <;>
"     as the <leader> for i-maps, since one seldom wants to type
"     non-whitespace characters immediately after a semicolon.
noremap <expr> k (v:count > 1 ? 'm`' . v:count . 'k' : 'gk')
noremap <expr> j (v:count > 1 ? 'm`' . v:count . 'j' : 'gj')

" I swap these two because: (a) `0` is so much easier to reach than
" `^`; (b) because '^' means the true BOL in regexes, so the discrepancy
" always struck me as odd.
noremap 0      g^
noremap ^      g0
" Note: can still use `1|` or <Home> to get to the file-line first
" character, also keeping their unique property of setting curswant=col.
" I don't really care for `g$` so much, also `$` and <End> have the
" unique property of setting curswant='$', so that would be lost by
" using `g$` instead.


" TODO: They prolly deserve a separate section, but consider also
"   the following commands for moving whole lines around (HT: junegunn),
"   instead of my <d><p> shenanigans for achieving the same effect.
" TODO: see also 'matze/vim-move' for a more sophisticated version.
" TODO: why isn't '< needed for the x_<C-k>, but '> is needed for x_<C-j>?
" TODO: alas these won't work for the same reasons as trying to map
"   <C-k> to <C-w>k etc; namely <C-j> *is* <NL>, if you're using the
"   terminal.  Though we could always use <leader>j/<leader>k or similar
"   instead.
"nnoremap <silent> <C-k> :move-2<CR>
"nnoremap <silent> <C-j> :move+<CR>
"xnoremap <silent> <C-k> :move-2<CR>gv
"xnoremap <silent> <C-j> :move'>+<CR>gv
" TODO: consider using `:h :map-cmd` in lieu of the x_`:` to avoid
"   needing the `gv` trick.


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Misc/General Usability ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{1

set backspace=indent,eol,start " Allow backspacing anything (input mode).
"set whichwrap=b,s,<,>,~,[,]   " Backspace and cursor keys wrap too.
" N.B., see <https://github.com/sorin-ionescu/prezto/issues/61>
" this can be reconfigured in iTerm2, but also see `:h :fixdel`

" TODO: I've been getting rather annoyed by {ic}_<C-w> lately.
" Should either remap that to something else, or remap all the :wimcmd
" things to something else.

set showmatch           " When inserting brackets, briefly jump to the match

" ~~~~~ Timing ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
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
set timeout             " enable time out on mappings and keycodes.
set ttimeout            " enable time out on keycodes.
"set timeoutlen=3000    " Wait N milisec for mapping sequences (default: 1000)
set ttimeoutlen=100     " Wait N milisec for keycodes (i.e., end of escape sequence).
                        " If &ttimeoutlen < 0, then uses &timeoutlen

" ~~~~~ Bells  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
"set belloff=           " Which (non-message) events should never ring the bell?
"set noerrorbells       " Should error messages ring the bell?
"set novisualbell       " Should bells be visual in lieu of beep?
"set t_vb=              " What command code implements visual bells?

" ~~~~~ Directories  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2
" Actually, I'll set these closer to wherever seems relevant; but
" for reference, there are at least the following directory options
" (most of which are actually comma-lists):
"
" For &path see <https://gist.github.com/romainl/7e2b425a1706cd85f04a0bd8b3898805>
"set path       " Analogue of $PATH, where we search for files to open.
"set tags       " ctags files
"set backupdir  " backupfiles               (&g:bk, &g:wb, &g:pm)
"set directory  " swapfiles                 (&b:swf)
"set undodir    " '+persistent_undo' files  (&b:udf)
"set viewdir    " `:mk{view,session}` files (&g:vop, &g:ssop)

" ~~~~~ Misc.  ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ {{{2

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
"set path=$HOME/,.      " Set the basic path
    " Actually, for &path see <https://gist.github.com/romainl/7e2b425a1706cd85f04a0bd8b3898805>
"set tags=tags,$HOME/.vim/_ctags
"set browsedir=buffer   " :browse e starts in %:h, not in $PWD

" Don't recognize octal numbers for <C-a> and <C-x>.
" HT: vim82/defaults.vim
set nrformats-=octal

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
" ~~~~~ History, Backups, & Stupidity ~~~~~~~~~~~~~~~~~~~~~~~~~~ {{{1
set history=200                 " size of command and search history.
"set undolevels=1000            " depth of undo tree.

if has('viminfo')
  " N.B., vim-6.2 can't handle the '<' entry here.
  set viminfo='20,<100,s100,\"100
  "           |   |    |    |
  "           |   |    |    +------ lines of history (default 50)
  "           |   |    +----------- Exclude registers larger than N kb
  "           |   +---------------- Maximum of N lines for registers
  "           +-------------------- Keep marks for N files
endif
"set confirm                    " ask before doing something stupid
set autowrite                   " autosave before commands like :next and :make

" See: `:h *backup-table*`
" Before overwriting an existing file: If (&backup || &writebackup
" || &patchmode) && &backupskip !~ %, then make a backup of the
" original, according to how &backupcopy says to do it (copying vs
" renaming).  After a successful write: If &backup, then keep it
" around; If !&backup && &writebackup, then delete the backup; If
" &patchmode && !exists(% . &patchmode), then rename the backup into
" the patchfile (thus, only keeping the oldest version of the file).
set nobackup                    " Make and retain backups? (default: no)
if has('writebackup')
  set writebackup               " Make temporary backups? (default: yes)
endif
"set patchmode=.orig            " Keep oldest backup with a suffix? (def: '')
"if has('wildignore')
"  set backupskip=....
"endif
set backupcopy=auto             " Create backups via copy or move?
set backupdir=$HOME/.vim/_backup " Where to put backup files? (comma-list)
" Note: must use $HOME or expand('~'); can't just use '~'.
" Warning: if none of the directories in &backupdir exist/writable,
" then vim won't make backups; which means, if the other options say
" to make backups before writing, then you can't write!

" See: `:h *swap-file*`
set swapfile                    " Create swapfiles? (default: yes; buffer-local)
set directory=$HOME/.vim/_swap  " Where to put swapfiles? (comma-list)
"set nofsync swapsync=          " DANGEROUS: save power by never syncing to disk

" TODO: consider &undoreload too
" TODO: consider this option
"if has('persistent_undo')
"  set nobackup noswapfile nowritebackup history=10000 undolevels=10000
"    \ undofile undodir=$HOME/.vim/_undo
"endif

" TODO: May want to check that &backupdir, &directory, and &undodir
" have at least one existing writable directory; just to report the
" problem early rather than leaving it to only be discovered once we
" try to write out.


" i_<C-u> deletes a lot; so we first i_<C-g>u to break the undo
" sequence and start a new change, that way we can <C-u> after
" inserting a line break.
" HT: vim82/defaults.vim
inoremap <C-u> <C-g>u<C-u>

" TODO: an interesting idea from <https://github.com/JesseLeite/dotfiles/blob/54fbd7c5109eb4a8e8a9d5d3aa67affe5c18efae/.vimrc#L190-L194> is to also have insertmode break undo-chains after certain characters, namely the basic punctuations .,!?

" Make n_<.> work as expected despite using arrow keys when making the edit.
inoremap <Left>  <C-g>U<Left>
inoremap <Right> <C-g>U<Right>


" TODO: for some of these, we may consider using `:h :map-cmd` in
"   lieu of the leading xo_`:<C-u>` or i_`<C-o>:`.  Since all these
"   are just for n-mode that doesn't actually apply here, but it's
"   important to remember for all the ohter places we use <expr> or <C-u>.
" Note: I use ClearUndoHistory far more often than I really should.
" For my purposes, `:earlier 1f` will do (more or less) what I want:
" which is to get back to the most recently saved version.  However,
" beware that that only works if you're in a changed state; if you're
" already on the most recent save, then it'll go to the previous one!
" So eventually I'll need to define my own thing to make it idempotent.
" Plus, of course, I should make a mapping for it.
" See Also: `:h usr_32` and `:h undo-redo`.
nnoremap <leader>du :<C-u>call wrengr#ClearUndoHistory()<CR>
nnoremap <leader>dr :<C-u>call wrengr#ClearRegisters()<CR>
nnoremap <leader>dm :<C-u>delmarks<CR>
if has('jumplist')
  nnoremap <leader>dj :<C-u>clearjumps<CR>
else
  nnoremap <leader>dj <Nop>
endif
" Re tags, see <https://vi.stackexchange.com/q/11964>

" TODO: Since all those share the <leader>d prefix, maybe make some
" extra wrapper that'll give a popup of completions if/when the
" <leader>d timesout (or we do some other key like <Space> or <CR>)?

" Note: the letter 'z' is punning off the ex-command `:z` for echoing
" a bunch of stuff.  It is (afaict) completely unrelated to the
" normal-mode `z` ops for adjusting the screen.
" TODO: is there a better second letter for these? Can't use 'p'
"   as in 'print'/'put' unless we want to change the clipboard thing
"   currently bound to `<leader>p`
nnoremap <leader>zu :undolist<CR>
" while `g; g,` say they need '+jumplist'; `:changes` doesn't say so...
nnoremap <leader>zc :changes<CR>
nnoremap <leader>zr :registers<CR>
nnoremap <leader>zm :marks<CR>
if has('jumplist')
  nnoremap <leader>zj :jumps<CR>
endif


" Because this is so much easier to type than `:w<CR>`
nnoremap <leader>w :update<CR>
" Note: :update is like :write, but it only writes when the buffer
" has been &modified.
" TODO: is there a good way to make :update tell us when it when
"   it didn't write?  Cuz I'd like to always get a message a~la :write,
"   just to have some feedback that yes the command did indeed run.
" TODO: is there a way to form a new branch in the undo tree (so
"   that n_<C-r> doesn't go anywhere), but without actually making
"   additional changes?  If there's no such builtin, then we may
"   want to implement a hack to achieve such.
" TODO: I'm guessing :update doesn't allow using `:earlier 1f`
"   anymore.  If not, then we'll definitely have to implement our
"   checkpointing hack, so that we can jump back to the most recent
"   time we called this mapping (or otherwise wrote to disk).
" TODO: if we used a control character (or something else excedingly
"   unlikely to be written) then we could also make an :imap for
"   doing this.  Maybe we could use <D-s>?  Not sure if iTerm2
"   already uses <D-s> for anything; of course, if they don't then
"   we could use it for the normal-mode mapping too.  However, see
"   <https://github.com/macvim-dev/macvim/issues/676>


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
"   N.B., &si is from the olden days and shouldn't really be used
"   now; everyone uses &cin with custom settings, or some other
"   language-specific algorithm.
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
" See: <https://www.reddit.com/r/vim/wiki/tabstop> for a nice
" clarification of what three behaviors &ts, &sts, and &sw are
" really distinguishing (which is poorly explained by Vim, imo).
" See: <https://en.wikipedia.org/wiki/Tab_key#Tab_characters> for
" the history of how punchcards lead to <HT>=8chars and <VT>=6lines
" (in lieu of the typewriter's <HT>=5chars).  And a bit more history
" about how <VT> has been repurposed over the years:
" <https://stackoverflow.com/q/3380538>

set tabstop=4       " Display real <Tab> characters as if N characters wide.
set softtabstop=0   " (0=)Don't pretend N positions are a <Tab> character
                    " (-1: Pretend &ts positions are a <Tab> character).
set shiftwidth=4    " Indent by N positions for shift commands (0: use &ts)
set noshiftround    " Make `>` and `<` operators round to a multiple of &sw
                    " (like i_<C-t> and i_<C-d> always do).

" Note(2021-11-28): apparently I despise &shiftround.  For
" indentation-sensitive languages like Haskell it totally breaks
" the relative-indentation structure because it applies the rounding
" separately to each line.

" if has('vartabs'), then there are two other options of note:
" &vartabstop and &varsofttabstop.  Both of these override their
" non-'var' counterparts to specify a non-regular sequence of
" hard/soft tabstops.  IMO they're not for general use, but rather
" only for specific filetypes (e.g., assembly code) that warrant
" such non-regularity.


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
"xnoremap < <gv
"xnoremap > >gv


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
if has('reltime')
  set incsearch     " While typing a search command, highlight match-so-far?
endif
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

" TODO: figure out exactly what this does (and how) before enabling it
" Clear the search register.
"nnoremap <leader>cs :let @/=''<CR>
" The above is intended to be used together with:
"set hlsearch
"let @/ = ""

" Search for character under cursor.
" (Mainly for use with CJK unicode, probably not so useful otherwise.)
" See also: <https://vi.stackexchange.com/a/560> and `:h ga` and `:h g8`
" TODO: really need a better keybinding/name.
nnoremap <leader>f xu/<C-r>-<CR>
nnoremap <leader>F xu?<C-r>-<CR>

" TODO: really need a better keybinding/name.
" Also, we probably want something different from this.
nnoremap z/ :call wrengr#AutoHighlightToggle()<CR>


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Auto-Completion                                          {{{1
" ~~~~~ Wild (:help *cmdline-completion*)                        {{{2

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
" ~~~~~ Insert-mode Autocompletion (:help *ins-completion*)      {{{2
" &cpt is used by i_<C-p>, i_<C-n>, i_<C-x><C-l>, and maybe also i_<C-x><C-d>.
"set complete=.,w,b,u,t,i
"   Used by i_<C-x><C-k> and if &cpt =~ 'k' then for others too.
"set dictionary=
"   Used by i_<C-x><C-t> and if &cpt =~ 's' then for others too.
"set thesaurus=
"if has('eval')
"  " Really these two should be set based on FileType; thus they
"  " shouldn't really be set here.
"  " See also: *complete-functions*
"  "    Used by i_<C-x><C-u>
"  set completefunc=
"  "    Used by i_<C-x><C-o>
"  set omnifunc=
"endif
"   See also: *ins-completion-menu*, *complete-popuphidden*
set completeopt=menu,preview,noselect,longest
"if has('textprop') || has('quickfix')
"  " See also: *complete-popup*
"  set completepopup=
"endif
set pumheight=15
"set pumwidth=15
"set infercase      " When doing *ins-completion* and &ignorecase is on...

" Note: Both <Up>/<Down> and <C-p>/<C-n> change the selection in
" the pmenu; the difference is: <C-p>/<C-n> will also insert/update
" the provisional completion, whereas <Up>/<Down> will not.
" TODO: what should we have map to <C-e> ?
inoremap <expr> <CR>       pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <expr> <Tab>      pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab>    pumvisible() ? "\<C-p>" : "\<S-Tab>"


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
  " BUG: (2021-10-03T00:13:15-07:00) For some reason just now this
  " mapping broke (when I wasn't doing anything in this part of the
  " file!).  It started doing the equivalent of <w> instead.  After
  " some investigating I tried disabling iTerm2's "Profiles >> Keys
  " >> Apps can change how keys are reported" and that fixed it.  I
  " don't recall having had that setting enabled before; so if I
  " didn't, then I'm not sure how it got set; and if I did, then I'm
  " not sure what I did in vim that would've caused it to suddenly
  " decide to start remapping <C-@> to <w>.  Fwiw, the only thing
  " I was doing at the time it broke was messing around with the
  " quickfix bracketoids.

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
" TODO: move this off to autoload/wrengr.vim or similar
" TODO: actually make this toggle!
" TODO: also, make sense to add an augroup to toggle it off whenever
"   in insert-mode; though it's only a minor annoyance to see the
"   spaces briefly highlighted while you're typing.
"   See: 'ntpeters/vim-better-whitespace'
" Note: using matchadd() ensures that this has higher priority than
" any :syntax, as well as higher than searches when &hls is enabled.
" That should help ensure that it does indeed match everywhere.
" Also note that since matchadd() only applies to the current window,
" this command too will only dis-/enable highlighting whitespace
" errors for the buffer from which it's called.
command! -nargs=0 HighlightWhiteError call s:HighlightWhiteError()
" Note: must autovivify w:whiteErrorID from within these functions;
" because it's window-local, we can't do it from outside (without
" adding an autocmd).
fun! s:HighlightWhiteError()
  if !exists('w:whiteErrorID')
    let w:whiteErrorID = []
  elseif !empty(w:whiteErrorID)
    return
  endif
  if &expandtab
    call add(w:whiteErrorID, matchadd('Error', '\t'))
  endif
  " \s matches only <Space> (\x20) and <Tab> (\x09).
  let l:slash_ess='\u0009\u0020'
  " We want to highlight any <Space> before <Tab>.  (The \ze ends the
  " highlighted portion of the match, thus the <Tab> isn't highlighted.)
  " TODO: should we actually '[\u0020'.l:ascii_extra.']\+\ze\t' instead?
  call add(w:whiteErrorID, matchadd('Error', '\ \+\ze\t'))
  " [[:space:]] matches all ASCII whitespace, as per C's isspace()
  "     That is: <Space>, <Tab>, <NL>, VertTab, <FF>, <CR>
  "     C0 notation:      ^I     ^J    ^K       ^L    ^M
  "     ASCII hex:        \x09   \x0A  \x0B     \x0C  \x0D
  "     Moreover, beware that since Vim uses the code \x0A in buffers
  "     as a representation of the code \x00 in files, that means [[:space:]]
  "     will also match <Nul> (\x00, ^@); which seems okay for our purposes.
  " So this is everything in [[:space:]] that's not in \s
  " TODO: Should we highlight these everywhere, like we do for l:unicode_white?
  let l:ascii_extras='\u000A-\u000D'
  " Unicode horizontal whitespace other than <Space> and <Tab> are as follows
  " (HT: 'ntpeters/vim-better-whitespace')
  "     \u00A0  NBSP                \u1680  OghamSpace
  "     \u180E  MVS                 \u2000  EnQuad
  "     \u2001  EmQuad              \u2002  EnSpace
  "     \u2003  EmSpace             \u2004  3PerEmSpace
  "     \u2005  4PerEmSpace         \u2006  6PerEmSpace
  "     \u2007  FigureSpace         \u2008  PunctSpace
  "     \u2009  ThinSpace           \u200A  HairSpace
  "     \u200B  ZWSP                \u202F  NarrowNBSP
  "     \u205F  MMSP                \u3000  IdeographicSpace
  "     \uFEFF  BOM, ZWNBSP
  let l:unicode_extras='\u00A0\u1680\u180E\u2000-\u200B\u202F\u205F\u3000\uFEFF'
  " We want these characters to be highlighted anywhere they occur.
  " TODO: Should guard this so that it only applies when has('multi_byte')
  " and when &encoding/&fileencodings are utf-8 (I'm not sure which one
  " is the correct one to check).
  call add(w:whiteErrorID, matchadd('Error', '[' . l:unicode_extras . ']\+'))
  " At EOL we want to also include the rest of [[:space:]]
  call add(w:whiteErrorID, matchadd('Error', '[' . l:slash_ess . l:ascii_extras . l:unicode_extras . ']\+$'))
endfun
command! -nargs=0 NoHighlightWhiteError call s:NoHighlightWhiteError()
fun! s:NoHighlightWhiteError()
  if !exists('w:whiteErrorID') | return | endif
  for l:id in w:whiteErrorID
    call matchdelete(l:id)
  endfor
  unlet w:whiteErrorID
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Folding (:help usr_28)                                   {{{1
if has('folding')
  " &foldenable turns folding on; but we don't need to set it here
  " because there are default mappings (N.B., &fen is window-local only):
  "     nnoremap zn :set nofen
  "     nnoremap zN :set fen
  "     nnoremap zi :set fen!
  " Also, many of the fold commands will automatically enable &fen
  " too, namely: `zc zC za zA zx zm zM`

  "set foldmethod=syntax    " How to make folds? (manual, marker, indent, syntax, expr)
  "set foldexpr=...         " Expression used by &fdm=expr.  Requires '+eval'.
  "set foldignore=#         " Characters used by &fdm=indent.
  "set foldmarker={{{,}}}   " Markers used by &fdm=marker. (Bad idea to change)
  set foldnestmax=5         " Maximum nesting level for &fdm={indent,syntax}.
  set foldminlines=2        " Minimum screen-lines to bother displaying as folded.
  "set foldlevelstart=-1    " Initial value of &foldlevel: 0=`zM`, 99=`zR`
    " Again, there's no point in setting &foldlevel itself (in $MYVIMRC).
    " You can adjust it with the `zm zM zr zR` commands; and the
    " `zx zX` commands will reapply its current setting (in case
    " something doesn't automatically do so).

  " This shows the first line of the fold, with '/*', '*/' and '{{{' removed.
  "set foldtext=v:folddashes.substitute(getline(v:foldstart),'/\\*\\\|\\*/\\\|{{{\\d\\=','','g')

  " TODO: &fillchars
  " See also <https://groups.google.com/g/vim_dev/c/xc006C7XJfo>

  " Use N columns of gutter to show the extent of folds.
  " (the N-th column is always empty, so only shows N-1 levels of nesting
  " in tree-like format; the rest are abbreviated by numbers for their depth)
  set foldcolumn=1

  " TODO: &foldopen, &foldclose

  " TODO: might should use wrengr#plug#DataDir(), but I've no idea
  "   what NeoVim uses for this.
  "if has('mksession')
  "  set viewdir=$HOME/.vim/_view  " Where to put `:mkview` files
  "  set viewoptions={...todo...}
  "  set sessionoptions={...todo...}
  "endif

  " TODO: if you want to automatically call `:mkview`/`:loadview`
  " then see 'zhimsel/vim-stay' rather than rolling our own autocmds.
endif


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Helper/external programs (beware portability)            {{{1

" The shell used for `!` and `:!` commands.
"set shell=/bin/bash

"if has('quickfix')
"  set errorfile=
"  set errorformat=
"endif

" Force the <~> key command to behave like an operator (thus, like `g~`).
"set tildeop

" The thing the <=> key command uses.
"set equalprg=
" TODO: cf., <http://vim.wikia.com/wiki/Par_text_reformatter>
" TODO: I'm sure it's woefully outdated, but maybe consider the
" example for setting &equalprg re HTML tidy:
" <https://github.com/jgm/dotvim/blob/master/doc/vimtips.txt>
" Not that we'd want to do that per-se; rather, it may be helpful
" for seeing how to get these external programs to dump things into
" &errorfile for quickfix'ing.

" The thing `gq` uses.
"set formatexpr=
"set formatprg=

" The thing `g@` uses.
"set operatorfunc=

" The thing the <S-k> key command uses. (If blank/empty, then uses `:help`)
"set keywordprg=man\ -s

" Unmap <S-k>, since I keep hitting it accidentally and never want/need it.
" (N.B., below we actually decide to remap it to something else.)
map <S-k> <Nop>

" The thing `:grep` uses.
"set grepprg=grep\ -nHr\ $*
" TODO: see WIP <~/.vim/autoload/wrengr/grepprg.vim>

" The thing `:make` uses.
"set makeprg=make
" Despite the name, this is used not just for :make, but also :grep, :cf, :lf, etc
"set makeencoding=...
" TODO: We may want to add something like the following to ftplugin/java.vim
"   HT: <https://github.com/jgm/dotvim/blob/master/doc/vimtips.txt>
"   set makeprg=jikes -nowarn -Xstdout +E %
"   set errorformat=%f:%l:%c:%*\d:%*\d:%*\s%m

" See <http://cscope.sourceforge.net> and `:h *cscope-suggestions*`
" Note: cscope is strictly for C; for C++ or any other language,
" just use some modern version of ctags.
" Note: All these options are global-only.  Default values shown in parens.
"if has('cscope')
"  set cscopeprg=           " string('cscope')  The program to run.
"  set cscoperelative       " boolean(off)      When no prefix(-P) something something
"  set cscopepathcomp=      " number(0)         # of path components to show
"  if has('quickfix')
"    set cscopequickfix=    " comma-list('')    Which :lcs subcommands use loclist?
"  endif
"  set cscopetag            " boolean(off)      Have `:tag` and <C-]> use :cstag
"  set cscopetagorder=      " number(0)         First search 0:cscope, 1:ctags
"  set cscopeverbose        " boolean(off)
"endif


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Copying & Pasting                                        {{{1

"set pastetoggle=<F9>

" Make n_Y yank from cursor to end of line (a~la n_D and n_C, and
" akin to n_A), rather than yanking the whole line (a~la n_yy, as
" is done in traditional vi).  (Unfortunately it's not entirely cut
" and dried, because n_S is also linewise; then again there is no
" n_ss, and n_s takes a character count like n_x rather than a
" motion like n_d or n_c.)  Note that I'm being specific about the
" normal-mode because for the visual-mode the capital letters do
" generally mean linewise (including n_V, o_V, v_D, v_C, v_S,...)
nnoremap Y y$

" In Visual/Select modes: have <p> replace selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-r>=current_reg<CR><Esc>
" TODO: consider using `:h :map-cmd` in lieu of `:` to avoid needing the `gv` trick.

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
  nnoremap <Leader>p :set paste<Bar>put *<Bar>set nopaste<CR>
endif

" Select the most-recently INSERTed text. (N.B., that'll be the
" whole file if you've just loaded it up and have never entered
" INSERT mode yet.)
" HT: <https://dougblack.io/words/a-good-vimrc.html>
" Warning: if we ever want this facility, we should give it a
" different name, since `gV` is already mapped to preventing automatic
" reselection (i.e., the inverse of `gv`)
"nnoremap gV `[v`]

" Auto indent pasted text
" HT: <https://github.com/victormours/dotfiles/blob/master/vim/vimrc>
"nnoremap p p=`]<C-o>
"nnoremap P P=`]<C-o>

" ~~~~~ OSX copy&paste                                           {{{2
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

  " Help the default filetype.vim improve its guesswork.
  let g:filetype_pl = 'perl'  " *.pl are always always Perl (unnecessary so far)
  let g:bash_is_sh  = 1       " *.sh are almost always Bash
  let g:tex_flavor  = 'latex' " Help choose between LaTeX, ConTeXt, & PlainTeX.

  " TODO: move these off to ~/.vim/ftdetect/ where they belong.
  augroup wrengr_vimrc
    " Yes, all my *.pro files ARE prolog files
    autocmd BufNewFile,BufRead *.pro,*.ecl setf prolog

    " This causes GHC to type check every time you save the file
    "autocmd BufWritePost *.hs !ghc -c %
    " TODO: similar things for *.hsc, *.lhs,... you can use {,} alternation a-la Bash
    " N.B., Haskell-specific things are defined in ~/.vim/ftplugin/haskell.vim

    " TODO: actual support for Agda
    " <http://wiki.portal.chalmers.se/agda/agda.php?n=Main.VIMEditing>
    autocmd BufNewFile,BufRead *.agda setf haskell

    " HT: <https://www.hillelwayne.com/post/intermediate-vim/>
    "autocmd FileType markdown inoremap <buffer> ;` ```<CR><CR>```<Up><Up>
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

" We should either do something like this:
"if has('mac') && executable('open')
"  let g:netrw_browsex_viewer = 'open'
"endif
" Or else probably want to give up and do this:
"let g:netrw_nogx=1

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
" TODO: if we actually want this, then move it off to ~/.vim/after/ftplugin/
"augroup wrengrvinegar
"  autocmd!
"  autocmd FileType netrw
"    \  nnoremap <buffer> q :call wrengr#BufferDelete()<CR>
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
  "let g:airline_symbols.crypt      = '🔒︎'  " beware to keep the \uFE0E there!
    " Beware that many programs (e.g., gmail) and processing tools
    " will silently discard the \uFE0E selector, consequently forcing
    " the emoji variant on us.  Also, alas, not all fonts seem to
    " respect the selector either.
  "let g:airline_symbols.colnr              "           default: ' ℅:'
  "let g:airline_symbols.linenr     = '¶' " '␊', '␤'    default: ' ㏑:'
  "let g:airline_symbols.maxlinenr  = ''    "           default: '☰'
  "let g:airline_symbols.branch     = '⎇ '  "           default: 'ᚠ'
  "let g:airline_symbols.paste      = 'ρ' " 'Þ', '∥'    default: 'PASTE'
  "let g:airline_symbols.spell      = 'Ꞩ'   "           default: 'SPELL'
  "let g:airline_symbols.notexists  = '∄'   "           default: 'Ɇ'
  "let g:airline_symbols.space              "           default: ' '
  "let g:airline_symbols.whitespace = 'Ξ'   "           default: '☲'
  "let g:airline_symbols.ellipsis   = '…' " '⋯'         default: '...'
  "let g:airline_symbols.modified           "           default: '+'
  "let g:airline_symbols.dirty              "           default: '!'
  "let g:airline_symbols.readonly           "           default: '⊝'
  "let g:airline_symbols.keymap             "           default: 'Keymap:'
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

" TODO: see <https://github.com/ilms49898723/dotfiles/blob/master/config/.vimrc>
" for various functions to construct your own entries.  Granted
" theirs are for lightline, but the ideas should translate readily.


" ~~~~~ gitgutter configuration (:help *gitgutter-options*)      {{{2
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
  "let g:gitgutter_use_location_list=1  " Have `:GitGutterQuickFix` use loclist instead of quickfix.
  "let g:gitgutter_grep = 'grep --color=never' " gitgutter can't handle ANSI codes
  "let g:gitgutter_max_signs = 500 " default=500 if Vim < 8.1.0614; else -1
  "let g:gitgutter_map_keys  = 0   " don't set up default mappings
  " Defaults:
  "     nmap ]c         <Plug>(GitGutterNextHunk)
  "     nmap [c         <Plug>(GitGutterPrevHunk)
  "     nmap <Leader>hp <Plug>(GitGutterPreviewHunk)
  "     nmap <Leader>hs <Plug>(GitGutterStageHunk)
  "     xmap <Leader>hs <Plug>(GitGutterStageHunk)
  "     nmap <Leader>hu <Plug>(GitGutterUndoHunk)
  "     omap ic         <Plug>(GitGutterTextObjectInnerPending) " all lines in hunk
  "     xmap ic         <Plug>(GitGutterTextObjectInnerVisual)
  "     omap ac         <Plug>(GitGutterTextObjectOuterPending) " also trailing empty lines
  "     xmap ac         <Plug>(GitGutterTextObjectOuterVisual)
  " TODO: at the very least we should rename their <leader>h{p,s,u} to match our <leader>{z,d} idiom.
  " TODO: the readme has all sorts of function suggestions
  " TODO: It looks like I've fixed the SignColumn stuff, but maybe
  "     check out the documentation for g:gitgutter_set_sign_backgrounds.
  " TODO: maybe also check out `:h gitgutter-statusline` for
  "     something to put into airline's section Z. (Though it looks
  "     like we already get that in section B)
  "
  " TODO: figure out a nicer scheme for toggling between gitgutter
  " mappings (as above or whatever we change those to) vs `:h *signify-mappings*`:
  " Defaults:
  "     nmap ]c <Plug>(signify-next-hunk)
  "     nmap [c <Plug>(signify-prev-hunk)
  "     nmap ]C " this gets the last hunk, but :map doesn't list it...
  "     nmap [C " this gets the first hunk, but :map doesn't list it...
  "     omap ic <Plug>(signify-motion-inner-pending)
  "     xmap ic <Plug>(signify-motion-inner-visual)
  "     omap ac <Plug>(signify-motion-outer-pending)
  "     xmap ac <Plug>(signify-motion-outer-visual)
  " HACK: !!
  if !g:gitgutter_enabled && !g:signify_disable_by_default
    " Since gitgutter does the mappings even when !g:gitgutter_enabled
    let g:gitgutter_map_keys = 0
    " TODO: SignifyHunkDiff actually opens a preview-window (to show
    " the changes inline) rather than at the bottom of the screen.
    " That's awesome, but after the last character of each line in this
    " preview-window the background is changed into a nasty grey; so we
    " need to fix our colorscheme to handle popup-windows correctly.
    nnoremap <Leader>zc :SignifyHunkDiff<CR>
    nnoremap <Leader>dc :SignifyHunkUndo<CR>
  endif
endif


" ~~~~~ nerdtree configuration                                   {{{2
"if exists(':NERDTree')
"  nnoremap <leader>t :NERDTreeToggle<CR>
"
"  " Allow vim to close if the only open window is nerdtree
"  autocmd wrengr_vimrc BufEnter *
"    \ if (winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree())
"    \| q | endif
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
fun! s:GoyoEnter()
  let s:goyo_saved_sc = &showcmd
  let s:goyo_saved_so = &scrolloff
  set noshowcmd
  set scrolloff=999
  Limelight
endfun
fun! s:GoyoLeave()
  let &showcmd   = s:goyo_saved_sc
  let &scrolloff = s:goyo_saved_so
  Limelight!
endfun
" Note: The 'User' event means these are not truly auto-commands,
" but rather must be manually invoked via `:doautocmd`.  The `nested`
" was recommended by Goyo's README, but I don't think it's really
" needed, since our functions shouldn't trigger any new auto events
" (unless Limelight uses a similar autocmd-as-callback trick).
" TODO: maybe we should be using the newer `++nested` syntax?
augroup wrengr_vimrc
  autocmd User GoyoEnter nested call s:GoyoEnter()
  autocmd User GoyoLeave nested call s:GoyoLeave()
augroup END

" TODO: consider using something like this (or similar for Goyo):
"nmap     <Leader>l <Plug>(Limelight)
"nnoremap <Leader>ll :Limelight!<CR>


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ 'prabirshrestha/vim-lsp' configuration (:help vim-lsp)   {{{2
" Also see <https://github.com/prabirshrestha/vim-lsp/blob/master/README.md>
"
" TODO: if we run into certain issues with asyncomplete doing too much,
" then take a look at: <https://github.com/prabirshrestha/vim-lsp/issues/328>
"
" Note: even though exists('g:lsp_loaded') is true by the time we
" can ask it on the cmdline, it's not yet true here!
" (N.B., prabirshrestha doesn't follow the `g:loaded_{plugin}` convention.)
" However, we can check has_key(g:plugs, 'vim-lsp') if we really
" want to guard this section.


" TODO: the next three were suggested by CiderLSP; do we actually want them?
" [asyncomplete-lsp]: Send async completion requests.
" WARNING: Might interfere with other completion plugins.
"let g:lsp_async_completion = 1
" Enable diagnostics signs in the gutter.
" TODO: how different from g:lsp_diagnostics_signs_enabled?
"let g:lsp_signs_enabled = 1
" Enable echo under cursor when in normal mode.
"let g:lsp_diagnostics_echo_cursor = 1

"let g:lsp_format_sync_timeout = 1000
"autocmd wrengr_vimrc BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
"
" TODO: if we ever end up usng EasyMotion, then see
"   `:h lsp#disable_diagnostics_for_buffer()` re autocommands to
"   toggle lsp's diagnostics so as not to interfere with EasyMotion.

" Only called for languages that have a registered server.
autocmd wrengr_vimrc User lsp_buffer_enabled call wrengr#lsp#BufferEnabled()


" ~~~~~ Setup Kythe for Google-specific code searching           {{{3
" Kythe is almost entirely open source (just not the stubby wrapping);
" cf., <https://github.com/kythe/kythe/tree/master/kythe/go/languageserver>

" TODO: should probably move this off to wrengr#lsp# as well.
fun! s:lsp_register_Kythe()
  let l:kythe_exe = '/google/bin/releases/grok/tools/kythe_languageserver'
  if executable(l:kythe_exe)
    call lsp#register_server({
      \ 'name': 'Kythe',
      \ 'cmd': {server_info->[l:kythe_exe, '--google3']},
      \ 'allowlist': ['cpp', 'go', 'java', 'proto', 'python'],
      \ })
  endif
endfun
autocmd wrengr_vimrc User lsp_setup call s:lsp_register_Kythe()


" ~~~~~ 'prabirshrestha/asyncomplete.vim' configuration          {{{2
" TODO: move this off to its own autoload file too.
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
command! -nargs=+ -complete=command Page call wrengr#Page(<q-args>)

" TODO: should probably give this a better name/mapping.
nnoremap <leader>s :<C-u>call wrengr#SynStack()<CR>

" Insert blank line, without entering insert-mode.
nnoremap <leader>o o<ESC>
nnoremap <leader>O O<ESC>

" Universal opposite of <J>
" HT: <https://gist.github.com/romainl/3b8cdc6c3748a363da07b1a625cfc666>
" TODO: depending on options, we should get this to detect comments
"   and add the necessary prefix too.
fun! s:BreakHere()
  " TODO: figure a way to use the substitute() function instead;
  "   to avoid depending on user settings for this.
  keeppatterns s/^\(\s*\)\(.\{-}\)\s*\(\%#\)\s*/\1\2\r\1\3
  call histdel('/', -1)
endfun
" This choice of mapping makes sense as a pun on the duality between
" <j>/<Down> vs <k>/<Up>, and it can also be thought of as 'cut' vs
" 'join'.  No, I don't remember why I spelled it <S-k> when unbinding
" it above; I can't imagine why a simple `K` wouldn't do the exact
" same thing.
nnoremap <S-k> :<C-u>call <SID>BreakHere()<CR>


" <https://github.com/jgm/dotvim/blob/master/doc/vimtips.txt> has
" a nice tip about using `<C-R>=expand("%:p:h")` to get the path
" to the directory of the file in the current buffer.  However,
" with wildmode enabled we can also just type the % character
" followed by the &wildcar, and it'll replace the '%' with the
" result of `<C-r>=expand("%:p")`.  So, that's still missing the
" ":h" part, but is pretty close.  We can do the same with `#<WildChar>`
"
" N.B., (:help *`=*) apparently we can use `= as a modern replacement
" for <C-r>= ; the difference being that `= is terminated by ` whereas
" <C-r>= is terminated by <CR>
" Alas, I just got to the end of reading that help section, and
" apparently one can only use `= in places where a filename is expected.

" TODO: <https://github.com/jgm/dotvim/blob/master/doc/vimtips.txt>
" also has a nice trick of doing `:g/^/m0` to reverse all the lines
" in the file.  I seldom need that, but sometimes I do want to reverse
" lines in a certain range.  I'm guessing that `0` is an absolute
" linenr, so we'd need to do some golfing to get a macro that does
" the right thing for regions.  Might be able to use :g/^/m'<   but only after a visual selection.
" There're also some nice examples at
"   `:h *edit-paragraph-join*`  :g/./,/^$/join
"   `:h *collapse*`             GoZ<Esc>:g/^$/.,/./-j<CR>Gdd
"                               GoZ<Esc>:g/^[ <Tab>]*$/.,/[^ <Tab>]/-j<CR>Gdd

" Haskell comment pretty printer (command mode)
" TODO: make this work for indented comments too
nnoremap =hs :.!sed 's/^-- //; s/^/   /' \| fmt \| sed 's/^  /--/'<CR>

" JavaDoc comment pretty printer.
" TODO: make this work for indented comments too
nnoremap =jd :.,+1!~/.vim/macro_jd.pl<CR>

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
