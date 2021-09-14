" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     autoload/wrengr.vim
" Modified: 2021-09-13T11:56:16-07:00
" Version:  1
" Author:   wren romano
" Summary:  Assorted functions extracted from my ~/.vimrc
" License:  [0BSD] Permission to use, copy, modify, and/or distribute
"           this software for any purpose with or without fee is
"           hereby granted.  The software is provided "as is" and
"           the author disclaims all warranties with regard to this
"           software including all implied warranties of merchantability
"           and fitness.  In no event shall the author be liable
"           for any special, direct, indirect, or consequential
"           damages or any damages whatsoever resulting from loss
"           of use, data or profits, whether in an action of contract,
"           negligence or other tortious action, arising out of or
"           in connection with the use or performance of this software.
"
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Preamble (See `:h use-cpo-save` and `:h :set-&vim`)
if exists('g:loaded_wrengr')
  finish
endif
let g:loaded_wrengr = 1
" Note: it appears `:set cpo&vim` doesn't buggily re-enable modelines,
" the way `:set nocompatible` does.
let s:saved_cpo = &cpo
set cpo&vim


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" TODO: for more on how this magichash separator works, we should
"   read up on: E746 and `:help autoload` and
"   <https://vi.stackexchange.com/a/13289>
"   <https://vi.stackexchange.com/a/13291>
"   <https://superuser.com/a/147233>
"   <https://github.com/LucHermitte/mu-template>


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Clear out the undo-history.
" HT: <https://superuser.com/a/433998>, <https://superuser.com/a/264067>
" Implementation Notes:
" (1) 'ul' is both global and buffer-local, so we must be sure to
"   handle that correctly when it comes to saving/resoring the
"   users' settings.  Beware that 'ul' uses the unique convention
"   of setting &l:ul=-123456 to mean we should fallback to &g:ul
"   (unlike most options where the local version is unset to indicate
"   fallback (which for numeric options ends up looking like the
"   local is set to the same value as the global)).
" (2) However, we only want this command to clear the undo history
"   of the current buffer, not all buffers!  I'm guessing that if
"   we do `:setg ul=-1` then that'll clear the undo history for
"   *all* buffers.  If so, then we really do only ever want to
"   `:setl ul=-1` (though `:set ul=-1` will be equivalent, due to
"   scope resolution).
"   TODO: verify this understanding!
" (3) When restoring the users' setting, we must use a variant of
"   `:let` in lieu of variants of `:set`, because the latter requires
"   the value to be a literal/constant whereas the former allows
"   expressions.  Also do beware that `:let &ul=` will clear &l:ul
"   and set &g:ul!  To affect only one of the buffer-local or global
"   settings, we must instead use `:let &l:ul=` or `:let &g:ul=`.
" (4) I don't know how the one post's `:exe "normal a \<BS>\<Esc>"`
"   was actually supposed to work (I know what it literally does,
"   just not why that was considered an appropriate solution), but
"   it ends up marking the buffer as dirty which we don't want.
"   Apparently it's the variant mentioned at `:h clear-undo`
" (5) A newer answer <https://superuser.com/a/688962> suggests using
"   `:move-1` as a sideeffect-free way to get the history to drop.
"   Alas, that too marks the buffer as dirty for some inscrutable reason.
" (6) So for now we prefer the `:edit!` solution.  However, do
"   beware of the side effects:
"   (i)   it does <z><z> (i.e., recenters the viewport); which we
"         correct by using winsaveview()/winrestview().
"   (ii)  it reloads the buffer from disk, discarding any unsaved
"         changes.
"   (iii) apparently that reloading also means discarding things
"         like any buffer-local changes to `:syn` etc., and reloading
"         whatever ftplugins.
" TODO: we should fix (6ii) by either:
"   (a) automatically saving before the `:edit!` (not the best idea)
"   (b) detect dirty buffer and bail out (annoying to deal with)
"   (c) have bang and non-bang variants of the command, to
"       pick between those two behaviors.
"   (d) something smarter?
" TODO: is there any point in using `:unlet l:foo`?  I would assume
"   l: variables are automatically cleared, yet the original sources
"   for wrengr#ClearUndoHistory() (e.g. `:h clear-undo`) explicitly
"   used unlet; so, why?  If it actually does something, then we
"   should have other functions do so too...
"
" Note: also see `:h clear-undo` regarding what exactly gets cleared
" vs retained (marks, manual folds, etc)

fun! wrengr#ClearUndoHistory()
  " Explicitly save the buffer-local value.
  " (Because `&ul := (&l:ul==-123456 ? &g:ul : &l:ul)` but we want
  " to make sure to restore &l:ul itself, not copy &g:ul into it.)
  let l:saved_ul = &l:ul
  " Save cursor & window info, to undo the <z><z> of :edit!
  let l:winview = winsaveview()
  try
    " Explicitly set the buffer-local value, so we only clear the
    " current buffer's undo history.
    " (Albeit `:set ul=-1` would do the same implicitly.)
    setl ul=-1
    " See implementation notes above.
    edit!
  finally
    call winrestview(l:winview)
    " Explicitly restore the buffer-local value.
    " (Because `:let &ul=` would clear &l:ul and set &g:ul, which
    " is never correct.)
    let &l:ul = l:saved_ul
  endtry
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Like `:delmarks` but for registers.
" HT: <https://vi.stackexchange.com/a/10528>
" TODO: see also <https://stackoverflow.com/a/26043227>
" BUG: this doesn't seem to remove them from ~/.viminfo thus the
"   clearing of the registers doesn't persist across sessions!
"   Also, from perusing the helppage for viminfo, their phrasing
"   suggests that only nnon-empty registers can be saved; hence
"   there's no way to save the fact of emptiness, afaict.
fun! wrengr#ClearRegisters()
  for i in range(34,122)
    silent! call setreg(nr2char(i), [])
  endfor
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Note: re saving the cursor, be sure to bear in mind the difference
" between buffer-positions, cursor-positions, and screen-positions.
" See ~/.vim/NOTES-cursor-etc.txt for greater detail.
" TODO: regarding the register, is the reg-type actually relevant
"   for @/ though?  And if not, then is there any benefit to using
"   getreg()/setreg() over just using :let and the usual @/ spelling?
" TODO: add handling for taking in a range, rather than always being global.
fun! wrengr#RemoveTrailingSpace()
  let l:winview    = winsaveview()
  let l:fen        = &foldenable    " N.B., window-local only.
  let l:query      = getreg('/')
  let l:query_type = getregtype('/')
  try
    " Per `:h winsaveview()` we disable &fen so we don't accidentally
    " open any folds while moving about.
    set nofoldenable
    " TODO: figure out how to replace this with substitute()
    "   since :s depends quite a lot on user settings.  See `:h
    "   :s_flags` for what exactly the 'e' flag does, to get an idea
    "   of how to emulate it when using substitute() instead.
    silent! %s/[[:space:]]\+$//e
  finally
    let &foldenable = l:fen
    call winrestview(l:winview)
    call setreg('/', l:query, l:query_type)
  endtry
endfun

" TODO: surely it's simpler to just use junegunn's:
"command! Chomp %s/\s\+$// | normal! ``


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Using `:echoerr` prints a stack-trace, which causes double error
" messages: one for the error itself, and another for the function
" exiting in error.  While stack-traces are nice for debugging,
" they're not so good when the error message is more for diagnostic
" reasons.  This function handles that more common diagnostic situation.
"
" HT: Re saving the v:errmsg, <https://github.com/moll/vim-bbye/>
fun! s:error(msg)
  echohl ErrorMsg
  echomsg a:msg
  echohl NONE
  let v:errmsg = a:msg
endfun

" I hate that {:bun,:bd,:bw} also kill any windows the buffer was in.
" So here's how to close out buffers more nicely.
" TODO: see 'moll/vim-bbye' for a more robust version.
"   N.B., it's GNU Lesser Affero GPL3.
" TODO: should have this function take an argument to specify whether
"   to :bun, :bd, or :bw.  (a~la 'moll/vim-bbye')  Personally I
"   always used :bw before writing this function; but it's a bit
"   hazy what exactly :bd keeps around imo.  The big thing is that
"   it retains the buffer in the jumplist, and therefore using <C-o>
"   or <C-i> can end up causing you to reopen the buffer; which I
"   always considered more as obnoxious rather than as a desirable
"   feature.  But yeah, other than that, what is retained that we
"   might actually want retained?
" TODO: we may want to call things like `:lclose`, `:cclose`, and
"   `:pclose` before we actually call `:bd`.
"   (see faq~4.8 at <https://github.com/vim-syntastic/syntastic>,
"   as well as what vim-plug does)
" TODO: add bang version to allow discarding changes in lieu of failing.
fun! wrengr#BufferDelete()
  if &modified
    " TODO: Or maybe this should be E89, according to 'moll/vim-bbye'.
    "   Both link to the same spot in `:h`, so I'm not sure what the
    "   difference is supposed to be.
    call s:error('E37: No write since last change. Not closing buffer.')
  elseif winnr('$') == 1
    " There's only one window, so there are no splits to lose.
    bdelete
  elseif len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
    " There's only one (listed) buffer, so :bd will create a new
    " buffer after deleting this one.
    bdelete
  else
    " BUG: if the current buffer is open in multiple windows, then
    "   this still destroys the split. Supposedly we should be able
    "   to fix that by `windo b#` or the like, but that doesn't
    "   quite work for me...
    " TODO: see all of the following:
    "   <https://stackoverflow.com/a/44950143/358069>
    "   <https://github.com/qpkorr/vim-bufkill>
    "   <https://stackoverflow.com/a/29236158/358069>
    "   <http://vim.wikia.com/wiki/Deleting_a_buffer_without_closing_the_window>
    bprevious
    " BUG: `:bd #` can throw E516 (no buffers deleted) under some
    "   strange circumstances.  In particular, this happens somewhat
    "   often with the help-window; but not always!
    bdelete #
  endif
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Capture output of a vim command into a split scratch buffer.
"
" This is good for verbose commands that only temporarily show their
" output, like `:version` and `:messages`.  It should also allow
" vim-commandline-special characters like `%`.  (I haven't had a
" chance to check/try that, but I imagine it should work.)
" HT: <https://gist.github.com/ctechols/c6f7c900b09be5a31dc8>
"
" Warning: The source claims it also works for `:!` commands (e.g.,
" `:Page !wc`), however I wasn't able to get that to work.  Instead
" it'd put the `:!` command itself into the scratch buffer, and
" silently put the command's output into the shell (which we only
" see after quitting vim).  So me switching the function to use
" execute() instead isn't what broke `:!` handling.
" BUG: there also seems to be something super glitched about this.
"   Whenever I've been using this function and then close out of
"   vim, all sorts of old pieces of buffer are scrambled all over
"   the terminal and I gotta <C-l> to redraw the screen.  I have
"   no idea why this would do that though...  Unless maybe there's
"   something specific about using `:redir =>>`.  Still need to
"   check whether switching to execute() fixed this.
"
" Note: The execute() function should be portable, since it's been
" available since Vim 7.4.2008 (July 2016); and it's generally
" preferable over the older :redir commands.
" <https://www.arp242.net/effective-vimscript.html>
" Additional notes from the helppage:
" * The command argument may also be a list.
" * It's perfectly fine for the command to use execute() itself.
" * The command must not use :redir however.
" * For `:!` commands, use system() instead lest your screen get messed up.
" TODO: does the `:!` caveat apply recursively, or just for the
"   top-level command?  Like, if we pass a command to call a function,
"   but then that function uses an external command; is that okay or not?

" TODO: I want a version of this that does a :vs instead of a :sp.
"   But that just opens the door for wanting other stuff like being
"   able to :resize the window, etc.  So we should have this function
"   take an extra argument which gives the command to replace :split
"   with; kinda like how g:plug_window works.
" TODO: once we have the :vs version, we should probably open the
"   split before running a:cmd, just in case the command formats
"   thing differently depending on what the winwidth() is.  Like,
"   I'm prety sure :version does that.

fun! wrengr#Page(cmd) abort
  " First run the command and capture the output.
  let l:output = execute(a:cmd, 'silent')
  " Then open a scratch buffer.
  " TODO: it's not a filename, but is that the right escape to use?
  execute 'split Page(' . fnameescape(a:cmd) . ')'
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  " Then add a few judgmental settings.
  setlocal nolist nowrap nospell nocursorcolumn
  if exists('+colorcolumn')
    setlocal colorcolumn=
  endif
  nnoremap <silent> <buffer> q :bdelete<CR>
  nnoremap <silent> <buffer> Q :bdelete<CR>
  " Then clear out any text (from previous calls to this function).
  " The HT link above used `normal gg` but I've added the rest a~la:
  " <https://learnvimscriptthehardway.stevelosh.com/chapters/52.html>
  normal! ggdG
  " Finally paste the output.
  " TODO: there's got to be a better way than splitting on newlines
  "   just to join on newlines again... Maybe setreg() and :put?
  " TODO: is that really the best return value we could give?  Like,
  "   maybe we ought to return the buffer number or something?
  return 1 - append(1, split(l:output, "\n"))
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Re what ReplaceDuplicatePrefix() does and how, see these references:
" <https://vi.stackexchange.com/a/16619>
" <https://stackoverflow.com/a/24832710>
" <https://vi.stackexchange.com/a/5962>
" <https://stackoverflow.com/a/50776668>
" <https://stackoverflow.com/a/52660894>
"
" See E935 / submatch() re getting regex-groups out; since that
" function is kinda hard to find just from looking up matchlist()

" TODO: re passing arguments to user-defined commands, try using
"   `:h :command-nargs` to get more info.
"   Or cf., <https://stackoverflow.com/a/5651751>
"   and also <https://superuser.com/a/1399163>
" BUG: all this is assuming single-byte-per-char text. For unicode
"   handling, see byteidx(), strcharpart(), strchars(), etc.
" TODO: pass in the line range as arguments, or somehow setup that
"   thing where we say the range first and then the function name
"   (i.e., automagically pass the range in, rather than as actual
"   function arguments).
"   Cf., <https://learnvimscriptthehardway.stevelosh.com/chapters/33.html>
"   Also the helpfiles for |function-range| and |command-range|.
" TODO: if we can't figure out how to do that, then need some way
"   to ensure this is only called immediately after doing a visual
"   selection; else it'll do some unintended thing.
" TODO: is there a way to prompt for confirmation re each replacement
"   (a~la :s///c)?
fun! wrengr#ReplaceDuplicatePrefix(pattern, replace)
  let l:match = ''
  " '< and '> mark begin and end lines of most recent visually
  " selected text.  Using those we get text from visual selection
  " and iterate over the lines.
  "
  " N.B., if we didn't need the line-numbers themselves (for
  " setline()), then we could just loop over getline(start,stop)
  for l:lno in range(line("'<"), line("'>"))
    let l:line = getline(l:lno)
    " Do we have a current l:match to work with?
    if !empty(l:match)
      " Does the l:line start with the l:match?
      let l:endpos = matchend(l:line, l:match, 0)
      if l:endpos >= 0
        " l:line duplicates the l:match, so replace it.
        call setline(l:lno, a:replace . l:line[(l:endpos):])
        continue
      endif
    endif
    " Either we had no l:match to work with, or the l:match failed,
    " so we need to find a new one.
    let l:match = matchstr(l:line, a:pattern, 0)
    if !empty(l:match)
      " Escape any regex chars in the matching string.
      " <https://vi.stackexchange.com/a/17474>
      let l:match = '\V' . escape(l:match, '\')
    endif
  endfor
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Show all syntax highlighting groups for word under cursor.
" HT: <https://stackoverflow.com/a/5825964>
" and <https://vi.stackexchange.com/a/11877>
" TODO: also print out the :hi for each group in the stack; and if it's
"   a link, then keep traversing links to the end (showing the whole
"   chain along the way).  For doing so, see:
"   <https://github.com/dylnmc/synstack.vim>
"   <https://github.com/gerw/vim-HiLinkTrace>
" TODO: for colorizing the output, also see:
"   <https://stackoverflow.com/a/14596678>
" TODO: maybe use a lambda in lieu of the string 'function';
"   lambdas are available since Vim 7.4.2044 (July 2016)
"   <https://www.arp242.net/effective-vimscript.html>
"   Or maybe just explicitly build the string up via for loop.
" TODO: Really ought to provide a <Plug> for this...
fun! wrengr#SynStack()
  " Vim 7.0 is required for synID(), synIDattr(), and synIDtrans().
  " (Or at least it's sufficient...)
  " TODO: give an error message rather than nop?
  if v:version < 700 | return | endif
  " Vim 7.1.215 is required for synstack()
  if exists('*synstack')
    let l:syns = synstack(line('.'), col('.'))
  else
    " The third argument to synID() is for whether to return
    " transparent items, vs looking through them and returning the
    " first item actually affecting the color/stylization of the text.
    " If we have to pick just one, then we might as well pick the
    " one we can see.
    let l:syns = [synID(line('.'), col('.'), 1)]
  endif
  echo join(reverse(map(l:syns, 'synIDattr(v:val,"name")')), ' ')
endfun

" TODO: may also consider using
" <https://www.vim.org/scripts/script.php?script_id=2716> and in
" particular `viy` to visually select the current syn-highlighted object.
" See also `:h text-objects`


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" TODO: generalize this to take a regex for which mappings to keep.
" HT: <https://stackoverflow.com/a/35582907>
" and <https://stackoverflow.com/a/38735392>
" Alas, this will not show builtins like <C-a>, because they're not made
" via :map.  See `:h index` for those builtins.
" TODO: see also <https://vi.stackexchange.com/a/7723> for a lot of
"   really useful info on debugging mappings.
fun! wrengr#CtrlMap()
  let l:contents = getreg('a')
  let l:type = getregtype('a')
  try
    " TODO: we can use execute() to get rid of the :redir, but
    " execute() only returns a string whereas the :put below requires
    " a register.  I guess we could use setreg()? seems like such
    " a hack though...
    redir @a
      silent map | call feedkeys("\<CR>")
    redir END
    " TODO: replace :vnew by wrengr#Page() instead!  Since that'll
    "   mark the buffer as boring, so vim doesn't complain when you
    "   try to close it.
    vnew
    put a
    " BUG: need to improve this regex to anchor things at the
    "   beginning of the mapping.  Try using `:filter` (as suggested
    "   by `:h map-listing`)  Also, should use built-in functions
    "   rather than Ex-commands, since the latter often have more
    "   side-effects and are more dependent on user settings.
    v/<C-/d
    %!sort -k1.4,1.4
  finally
    call setreg('a', l:contents, l:type)
  endtry
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" TODO: Check out <https://github.com/inkarkat/vim-mark> for a more
"   powerful variant of this idea (albeit, solving a somewhat
"   different problem).
" TODO: Really ought to provide a <Plug> for this...
" TODO: should we be using echomsg in lieu of plain echo?
" HT: <https://stackoverflow.com/a/26088438>
"
" Note: According to the helpfiles, both &ut and &hls are global-only
" options; thus we need only cache one copy of them, rather than one
" per tab/window/buffer.
let s:saved_ut  = &ut
let s:saved_hls = &hls
fun! wrengr#AutoHighlightToggle()
  let @/ = ''
  if exists('#auto_highlight')
    au! auto_highlight
    augroup! auto_highlight
    let &updatetime = s:saved_ut
    let &hlsearch   = s:saved_hls
    " N.B., the `:noh` command doesn't change &hls it just suspends
    " highlighting the most recent search.  (Magically somehow, since
    " it doesn't clear the Search highlighting nor the @/ register.)
    " We do this in case s:saved_hls is on, since we want highlighting off.
    nohlsearch
    echo 'Highlight current word: off'
  else
    augroup auto_highlight
      au!
      au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
    augroup END
    let s:saved_ut  = &ut
    let s:saved_hls = &hls
    set updatetime=500
    set hlsearch
    echo 'Highlight current word: ON'
  endif
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fun! wrengr#OpenPlugURL()
  let l:winview  = winsaveview()
  let l:contents = getreg('a')
  let l:type = getregtype('a')
  try
    normal! T'"ayt'
    " TODO: validate that that selection is well-formed.
    let l:url = 'https://github.com/' . @a
    " BUG: has('mac') is *false* for the Vim 8.0 that ships with OSX 10.14.6!!
    "   (2016 Sep 12; patches: 1-503, 505-680, 682-1283, 1365)
    "   For now we'll just buggily assume `open` does what we mean.
    " BUG: For Safari, this sometimes chooses a random window other
    "   than the one it chose the previous few calls!
    if executable('open')
      " TODO: escape the l:url as needed
      silent execute '!open ' . l:url
      " HACK: the above leaves the screen blank afterwards and
      " requires a manual <C-l>
      redraw!
    else
      echo l:url
    endif
  finally
    call winrestview(l:winview)
    call setreg('a', l:contents, l:type)
  endtry
endfun

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Misc Haskell Functions
" Add type signatures to top-level functions
" From Sebastiaan Visser
"fun! wrengr#HaskellType()
"   w
"   execute "normal {j^YP"
"   execute (".!ghc -XNoMonomorphismRestriction -w % -e \":t " . expand("<cword>") . "\"")
"   redraw!
"endfun
"
"" Compare vs the following Cabal integration hack (to be called via `autocmd BufEnter`).
"fun! wrengr#SetToCabalBuild()
"  if glob("*.cabal") != ''
"    let a = system( 'grep "/\* package .* \*/"  dist/build/autogen/cabal_macros.h' )
"    let b = system( 'sed -e "s/\/\* /-/" -e "s/\*\///"', a )
"    let pkgs = '-hide-all-packages ' .  system( 'xargs echo -n', b )
"    let hs = "import Distribution.Dev.Interactive\n"
"    let hs .= "import Data.List\n"
"    let hs .= 'main = withOpts [""] error return >>= putStr . intercalate " "'
"    let opts = system( 'runhaskell', hs )
"    let b:ghc_staticoptions = opts . ' ' . pkgs
"  else
"    let b:ghc_staticoptions = '-XNoMonomorphismRestriction -Wall -fno-warn-name-shadowing'
"  endif
"  execute 'setlocal makeprg=' . g:ghc . '\ ' . escape(b:ghc_staticoptions,' ') .'\ -e\ :q\ %'
"  let b:my_changedtick -=1
"endfun

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Clean Up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let &cpo = s:saved_cpo
unlet s:saved_cpo
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.