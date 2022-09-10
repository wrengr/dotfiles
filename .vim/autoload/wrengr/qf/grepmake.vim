" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     autoload/wrengr/qf/grepmake.vim
" Modified: $$
" Version:  0
" Author:   wren romano
" Summary:  Enhancing the builtin grep/make commands.
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
" See <https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3>
" for the vast majority of these ideas; though some also come from
" 'romainl/vim-qf' itself.
" BUG: licensing restrictions of that gist?
"
" TODO: see also 'alejandrogallo/vim-ripgrep' for a different way
" of doing s:grep(); albeit more verbose and probably less
" efficient/maintainable since it doesn't use &grepformat.
"
" BUG: because of the :commands and :cabbrevs, this can't actually
" be an autoload; those parts at least must be an always-loaded plugin.
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Preamble (See `:h use-cpo-save` and `:h :set-&vim`)
if exists('g:loaded_wrengr_qf_grepmake') || !has('quickfix') | finish | endif
let g:loaded_wrengr_qf_grepmake = 1
let s:saved_cpo = &cpo
set cpo&vim

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Warning: if you want spaces in your pattern then you'll have to
" backslash escape them; quoting doesn't help.
" Warning: Just like builtin :grep, this will expandcmd() the first
" argument; so if your search pattern contains % or # or $ etc,
" then you'll have to backslash escape them too.
" TODO: shall I diverge from @romainl and side with @jssee on that
"   hill?  I think I can't side with @gpanders, much as I'd like
"   to, just because that does go so at odds with Vim (wrongheaded
"   as Vim is on this topic). At the very least, maybe do fnameescape()
"   before expandcmd()?  Maybe add a <bang> variant to distinguish?
"   Or maybe we should just follow more after `:vimgrep` rather than `:grep`
" TODO: automatically use % when a:000[1:-1] is empty?
fun! s:grep(...) abort
  return s:system(&grepprg .' '. expandcmd(join(a:000, ' ')))
endfun

fun! s:make(...) abort
  if empty(a:000)
    " TODO: we may want to expand to the full path, but then we'd
    " need to be smarter about figuring out the VCS root etc.
    let l:args = expand('%:S')
  else
    let l:args = expandcmd(join(a:000, ' '))
  endif
  return s:system(&makeprg .' '. l:args)
endfun

" Save the command, for setting the qf/loc window's title.
" TODO: may want to :silent this? or whatever the equivalent would be for system()
fun! s:system(cmd) abort
  let s:command = a:cmd
  return system(a:cmd)
endfun

" TODO: `:grepadd` and `:lgrepadd`
" TODO: add bang support (for grep stuff at least)
command! -nargs=+ -complete=file_in_path -bar Grep
  \ call wrengr#qf#getexpr('c', s:grep(<f-args>))
command! -nargs=+ -complete=file_in_path -bar LGrep
  \ call wrengr#qf#getexpr('l', s:grep(<f-args>))
command! -nargs=* -complete=file_in_path -bar Make
  \ call wrengr#qf#getexpr('c', s:make(<args>))
command! -nargs=* -complete=file_in_path -bar LMake
  \ call wrengr#qf#getexpr('l', s:make(<args>))
" TODO: why just <args> for :Make instead of <f-args> like for :Grep?

" Shorten the :cabbrev idiom
fun! s:overrideBuiltinCmd(builtin, ours)
  " TODO: are there ever any <mods> or ranges that might precede the
  " main command for these? cuz if so, then that'll break the abbrev.
  if getcmdtype() ==# ':' && getcmdline() ==# a:builtin
    return a:ours
  else
    return a:builtin
  endif
endfun

cnoreabbrev <expr>  grep <SID>overrideBuiltinCmd( 'grep',  'Grep')
cnoreabbrev <expr> lgrep <SID>overrideBuiltinCmd('lgrep', 'LGrep')
cnoreabbrev <expr>  make <SID>overrideBuiltinCmd( 'make',  'Make')
cnoreabbrev <expr> lmake <SID>overrideBuiltinCmd('lmake', 'LMake')

" HT: 'romainl/vim-qf' re setting w:quickfix_title
" TODO: @romainl uses :noautocmd for the calls; should we too?
" TODO: this function should surely be incorporated into wrengr#qf#getexpr()
"   so that it always runs even without the autocmds.
fun! s:SetQFTitle(title) abort
  let w:quickfix_title = a:title
  " Note: using these functions to set the title requires patch 7.4.2200
  if wrengr#qf#CL() ==# 'c'
    call setqflist([], 'a', {'title': a:title})
  else
    call setloclist(0, [], 'a', {'title': a:title})
  endif
endfun

" TODO: While we may always want the :[cl]window part of this for
" all the qf commands, the part for setting the title is specific
" to our commands above, so we may actually want to move that into
" the wrengr#qf#getexpr() function itself, instead of leaving it here.
" TODO: we may need to debug the title setting a bit.  The helppages
" say that (1) when the ultimate/what-dict argument is passed then
" the antepenultimate/list argument is ignored, (2) when the
" penultimate/action-string is 'a' then it'll create a new qf/loc
" list if one doesn't exist.  But it's hard to reconcile those two.
" Does the ultimate argument mean ignoring the penult too, or will
" the penult still create an initial qf/loc list despite not pushing
" the antepenult items onto that list?
" TODO: Since we're calling the setqflist()/setloclist() functions
" anyways, why not handle &efm and the :[cl]getexpr part all together
" in a single call to those functions?
" TODO: <https://www.reddit.com/r/vim/comments/6znnpf/comment/dmxqhbr/?utm_source=reddit&utm_medium=web2x&context=3>
" suggests doing :redraw! after the :[cl]window
augroup wrengr_qf_grepmake
  autocmd!
  autocmd QuickFixCmdPost [^l]* cwindow | call <SID>SetQFTitle(':' . s:command)
  autocmd QuickFixCmdPost l*    lwindow | call <SID>SetQFTitle(':' . s:command)
augroup END


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Clean Up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let &cpo = s:saved_cpo
unlet s:saved_cpo
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
