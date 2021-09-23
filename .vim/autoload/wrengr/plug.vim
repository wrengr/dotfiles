" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     autoload/wrengr/plug.vim
" Modified: 2021-09-22T22:15:51-07:00
" Version:  2
" Author:   wren romano
" Summary:  vim-plug functions extracted from my ~/.vimrc
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
" To abbreviate the very long urls below, pretend we have:
"   let $VIMPLUG_URL='https://github.com/junegunn/vim-plug'
"
" Version 2: added UseGitUrls(), UseHttpsUrls(), and WIP: OpenURL().
"
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Preamble (See `:h use-cpo-save` and `:h :set-&vim`)
if exists('g:loaded_wrengr_plug') | finish | endif
let g:loaded_wrengr_plug = 1
let s:saved_cpo = &cpo
set cpo&vim


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Automagically get (equivalent of) the ~/.vim directory
"
" $MYVIMRC is magically set to point to the user's ~/.vimrc file.
" Alas, Vim doesn't have any equivalent for the ~/.vim directory.
" And while NeoVim does, they make distinctions that plain Vim
" doesn't; and so there are disputes about what exactly to use:
"   <$VIMPLUG_URL/issues/739>
" In general, stdpath('config') is a closer equivalent to ~/.vim,
" but since the plug.vim file and all our plugins are automatically
" downloaded, some vim-plug developers feel that using stdpath('data')
" is more appropriate.  For comparison, see:
"   <https://vi.stackexchange.com/q/23160#comment42036_23160>
"   <https://neovim.io/doc/user/eval.html#stdpath()>
" And finally, we use expand() just to be safe; though plug#begin()
" is smart enough to expand the tilde too.
let s:MYVIMDIR =
  \   has('nvim')                  ? stdpath('data')
  \ : has('win32') || has('win64') ? expand('~/vimfiles')
  \ :                                expand('~/.vim')


" The default is just cuz that's what vim-plug's documentation uses.
fun! wrengr#plug#DataDir(...)
  return s:MYVIMDIR . '/' . get(a:, 1, 'plugged')
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ A smarter shellescape()
" HT: <https://github.com/mhinz/vim-signify/issues/15>
" Note: &shellslash is global-only.
" TODO: move to ~/.vim/autoload/wrengr.vim and public/exported?

fun! s:shellescape(path)
  try
    if has('+shellslash')
      let l:old_ssl = &shellslash
      set noshellslash
    endif
    let l:path = shellescape(a:path)
  finally
    if exists('l:old_ssl')
      let &shellslash = l:old_ssl
    endif
  endtry
  return l:path
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Bootstrap vim-plug

" Autodownload vim-plug itself, if it's not already installed.
" That way we don't need to store a copy in our dotfiles git repo.
" Of course auto-installing opens us up to potential security issues.
" In lieu of auto-installing, we could just store this single file
" in the dotfiles repo (after verifying its trustworthiness), and
" then re-verify it before committing the new version gotten by
" calling :PlugUpgrade.  Then again, auto-updating the other plugins
" also poses potential security issues; so how paranoid should we be?
"
" junegunn himself encourages committing plug.vim to dotfiles repos:
"   <$VIMPLUG_URL/issues/69#issuecomment-54735487>
"   <$VIMPLUG_URL/pull/240#issuecomment-110538613>
" And in fact, recently that's what we've done.  But we keep this
" function nevertheless, since it could still come in handy.

let s:vimplug_file = s:MYVIMDIR . '/autoload/plug.vim'
fun! wrengr#plug#Bootstrap() abort
  if empty(glob(s:vimplug_file))
    " TODO: detect if we're behind an HTTP proxy and fail with
    "   a message. (Because no way am I going to pass --insecure
    "   to curl, nor set GIT_SSL_NO_VERIFY to true).
    " TODO: should we double-escape, using fnameescape() for :exe ?
    silent execute
      \ '!curl -fLo ' . s:shellescape(s:vimplug_file) . ' --create-dirs'
      \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    " TODO: really ought to check for errors here, rather than
    "   relying on `abort`.
    if has('autocmd')
      augroup vimplug_bootstrap
        autocmd!
        " N.B., --sync flag is used to block the execution until
        " the installer finishes.
        autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
      augroup END
    endif
    " The only time it makes sense to call this function is from
    " $MYVIMRC; but since the augroup will just re-source $MYVIMRC
    " anyways, it makes sense to `:finish` right away rather than
    " going through the rest of the $VIMRC the first time (since it
    " might throw errors etc).  So we give a return value to indicate
    " whether we did indeed have to bootstrap vs not.
    return 1
  endif
  return 0
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" BUGFIX: For some reason the default g:plug_window started being
" way too wide recently; so we're resizing it to something more
" reasonable.
"
" So far, 50 columns is wide enough to show `:PlugStatus` without
" wrapping; and I'd always like to reserve 80 columns for the main
" text.  If there's not enough room for that, then I'm scaling the
" plug window's width down quadratically (because linear scaling,
" er, scales poorly).  Fwiw, on mayari: when in fullscreen-mode we
" get &columns=143 (which doesn't sound right, but whatevs); and
" when not, we usually have &columns=100.
" TODO: Should make those magic numbers more configurable.  Also
" should generalize this to work for other windows, cuz `:h` too
" started being way too big recently.  When generalizing for other
" windows, it's probably best to just have a function that returns
" the computed width (or height); rather than taking in arguments
" for the `:vertical topleft new` and `:setl` parts.  Though if we
" end up adding a hook to adjust the width whenever the terminal-screen's
" size changes, then we will want to ensure that that boilerplate
" stays together with the width computation itself.
" BUG: Below when we're reserving 80 columns for the maintext, that
"   doesn't account for the columns eaten up by &number, &signs,
"   &foldcolumn, etc (i.e., eaten up in the main window; since we
"   disable them in the plug window.)


" TODO: If we ever care about aspect-ratio, see:
"   <https://vi.stackexchange.com/a/13337>
fun! wrengr#plug#Window()
  " Compute the desired width before opening the split.
  let l:current = winwidth('%')
  if l:current > 130
    let l:width = 50
  else
    " The Idea: In the edge case for here vs above, the new window
    " will take up `l:percent=50/130` of `l:current=130`.  To change
    " sizes gracefully, we scale the percentage itself: linearly
    " from (l:current=0, l:percent=0) to (l:current=130, l:percent=50/130).
    " Mathematically this gives:
    "   `let l:percent = (l:current/130) * (50/130)`
    "   `let l:width   = l:current * l:percent`
    " But we can't do that directly, when using integers; so we
    " rearrange things.  (For now we want to avoid requiring '+float'.)
    " Warning: for some reason when we were using `(c*c*5)/1690`
    " we were getting l:width >50 for l:current >127; and more
    " generally getting numbers that disagreed with Haskell (also
    " using Int).  Reducing the fraction seems to have fixed that,
    " but I have no idea what was going wrong and can't seem to
    " reproduce it now.  Fwiw, some correct values are:
    " l:current >=130   l:percent~0.38461538461538464   l:width=50
    " l:current ==100   l:percent~0.29585798816568047   l:width=29
    let l:width = (l:current * l:current) / 338
  endif
  let l:width = max([&winwidth, l:width])
  " Now open the split.
  " (`:vert to new` is the default g:plug_window command.  Replace
  " `topleft` with `botright` if you prefer to open on the far-right
  " instead.)
  vertical topleft new
  " Now resize.
  execute 'vertical resize ' . l:width
  " We don't need linenumbers here, so save a bit of space.
  setlocal norelativenumber nonumber
  if exists('&signcolumn')
    setlocal signcolumn=no
  endif
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" From <$VIMPLUG_URL/wiki/tips#conditional-activation>
"      <$VIMPLUG_URL/wiki/faq>
" Note: This function is only required when the conditional is flaky.
" Notably, has() conditions will only change when switching between
" different vim/neovim/etc executables and reusing the same MYVIMDIR;
" so if you're not alternating back and forth like that, then this
" function isn't required.  Whereas executable() conditions and the
" like will change more frequently, when files or their permissions
" are changed or when your $PATH changes; though hopefully the plugins
" you install won't require files that are changing all the time.
" Nevertheless, I'm using it everywhere; because the cost of doing
" so is small.

fun! wrengr#plug#Cond(cond, ...)
  let l:opts = get(a:000, 0, {})
  return a:cond ? l:opts : extend(l:opts, { 'on': [], 'for': [] })
endfun

" Note: Outside of the above function's usage, one should rarely
" need to specify 'on'/'for'.  If you need 'for', that means their
" ftdetect is broken.  If you need 'on', that means they don't use
" autoload correctly.  (Thus, needing 'on' is far more common than
" needing 'for'.)  If you think some plugin may be a bad-actor and
" need this special handholding, use `vim --startuptime /tmp/log`
" to detect which one it is.
"   <$VIMPLUG_URL#on-demand-loading-of-plugins>
"   <$VIMPLUG_URL/wiki/faq#when-should-i-use-on-or-for-option>
"   <$VIMPLUG_URL/wiki/tips#loading-plugins-manually>


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" <$VIMPLUG_URL/wiki/faq#whats-the-deal-with-git-in-the-url>
" N.B., we can mess with g:plug_url_format all we want along the
" way through the vim-plug section; each call to the `:Plug` command
" will just use whatever value g:plug_url_format has at that time.
"
" Note: since git-1.6.6 (2010) plain ssh is equivalent to https:
"   <https://stackoverflow.com/a/3248848>.
" For other reasons to prefer one over the other:
"   <https://stackoverflow.com/a/11041782>.
" For more on what the heck the plain git-protocol even is/does:
"   <https://stackoverflow.com/a/33846897>.

" ~~~~~ Set `:Plug` to use ssh+git_protocol urls.
" Necessary if you want to push from the repos stored in
" wrengr#plug#DataDir()
fun! wrengr#plug#UseGitUrls()
  let g:plug_url_format = 'git@github.com:%s.git'
endfun

" ~~~~~ Set `:Plug` to use the default (https) urls.
" Allows to avoid authenticating just for pulling.
fun! wrengr#plug#UseHttpsUrls()
  unlet! g:plug_url_format
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" TODO: see the various vim-plug functions at
"   <https://github.com/junegunn/dotfiles/blob/master/vimrc#L1283>
"   namely s:plug_gx(), s:plug_doc(), and their mappings

" WIP:
fun! wrengr#plug#OpenURL()
  let l:winview  = winsaveview()
  let l:contents = getreg('a')
  let l:type = getregtype('a')
  try
    " TODO: should be able to use the textobject i' rather than T't'
    " (N.B., the textobject is listed as for n_ and v_ modes; it's
    " not phrased as being o_ mode)
    normal! T'"ayt'
    " TODO: validate that that selection is well-formed before continuing!!
    let l:url = 'https://github.com/' . @a
    " BUG: has('mac') is *false* for the Vim 8.0 that ships with OSX 10.14.6!!
    "   (2016 Sep 12; patches: 1-503, 505-680, 682-1283, 1365)
    "   For now we'll just buggily assume `open` does what we mean.
    " BUG: For Safari, this sometimes chooses a random window other
    "   than the one it chose the previous few calls!
    if executable('open')
      " TODO: escape the l:url as needed
      " TODO: see also `:h *netrw-gx*` in case that's easier or more portable.
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
" ~~~~~ Clean Up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let &cpo = s:saved_cpo
unlet s:saved_cpo
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
