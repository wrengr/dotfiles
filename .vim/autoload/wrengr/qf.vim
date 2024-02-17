" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     autoload/wrengr/qf.vim
" Modified: 2024-02-17T12:49:55-08:00
" Version:  1
" Author:   wren romano
" Summary:  Enhancing quickfix/loclist stuff.
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
" Re separating concerns, this file is largely intended to reduce
" the amount of code in the after/ftplugin/qf.vim file; whereas
" unrelated enhancements like extending/overriding the builtin
" ex-commands for make/grep is better handled elsewhere (since it'll
" we used less often and so we don't want to load it too soon).
"
" Version 1:
"   * Fixed the bug about BracketExpr() not evaluating things.
" Version 0:
"   * CL()                              moved here from after/ftplugin/qf.vim
"   * BracketExpr()                     factored out from ~/.vimrc
"   * getexpr()                         moved here from wrengr#qf#grepmake
"   * RemoveQuickfixItemUnderCursor()   moved here from after/ftplugin/qf.vim
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Preamble (See `:h use-cpo-save` and `:h :set-&vim`)
if exists('g:loaded_wrengr_qf') || !has('quickfix') | finish | endif
let g:loaded_wrengr_qf = 1
let s:saved_cpo = &cpo
set cpo&vim


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Detect quickfix vs loclist windows, and return 'c' or 'l' accordingly.
" This is designed for use with `:map<expr>` to automatically choose
" the correct :{c,l}foo command.  (Hence why we don't return a boolean.)
" TODO: may also want boolean version for scripting purposes.
"   Especially since there are a number of commands (:make, :grep,
"   :cscope,...) which alternate between '' and 'l' rather than 'c'
"   and 'l'.
" Note: both quickfix and loclist windows share &ft=qf and &bt=quickfix.
" Afaict, the only ways to distinguish them are win_gettype() and
" since 7.4.2215 getwininfo().
" TODO: would it be faster/more-efficient to use getwininfo()? i.e.,
"   the dict lookup vs the string equality used below.
" TODO: see also <https://github.com/LucHermitte/lh-vim-lib/blob/master/autoload/lh/qf.vim>,
"   referenced via <https://vi.stackexchange.com/a/16586>
fun! wrengr#qf#CL()
  let l:type = win_gettype()
  if l:type ==# 'quickfix'
    return 'c'
  elseif l:type ==# 'loclist'
    return 'l'
  else
    call wrengr#utils#error('Not a quickfix/loclist window')
    " Note: functions will return the Number 0 whenever there is
    " no return statement or when the `:return` has no arguments.
    " While nothing good can come after this error, we nevertheless
    " return the empty string just to make things hopefully less
    " likely to explode further.  Since the string result can only
    " really be used in conjunction with other stuff, it doesn't make
    " sense to return "\<Ignore>" (Also N.B., that magic character
    " is *not* equivalent to the emptystring at all.)
    " TODO: maybe we really do want to throw an exception here?
    " Will that be sufficient to kill the rest of whatever expression
    " the mapping uses?
    return ''
  endif
endfun

" ~~~~~ ''-vs-'l' commands that update things.
"  mak[e]
"  gr[ep]
"  grepa[dd]
"  vim[grep]    lv[imgrep]      because :vi[sual], :v[global]
"  vimgrepa[dd]
"  cs[cope]
"  helpg[rep]   lh[elpgrep]
" ~~~~~ 'c'-vs-'l' commands that update things. (Idiosyncratic abbrevs noted)
" cf[ile]
" cg[etfile]
" caddf[ile]
" cex[pr]
" cgete[xpr]
" cadde[xpr]    lad[dexpr]
" cb[uffer]
" cgetb[uffer]
" cad[dbuffer]  laddb[uffer]
" ~~~~~ 'c'-vs-'l' commands that don't update. (idiosyncratic abbreviations noted)
" cc            ll
" cfir[st]                  because :{c,l}f[ile]
" cr[ewind]
" cla[st]                   because :{c,l}l[ist], :ll
" cp[revious]
" cN[ext]
" cn[ext]       lne[xt]     because :ln[oremap]
" cpf[ile]
" cNf[ile]
" cnf[ile]
" cabo[ve]      lab[ove]    because :ca[bbrev], :la[st]
" cbel[ow]                  because :{c,l}b[uffer], :{c,l}be[fore]
" cbe[fore]                 because :{c,l}b[uffer]
" caf[ter]                  because :ca[bbrev], :la[st]
" col[der]                  because :co[py], :lo[adview]
" cnew[er]                  because :{c,l}n[ext]
" cq[uit]       -- No loclist version, because this isn't a quickfix command!
" cl[ist]       lli[st]     because :ll


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Helper function for defining quickfix bracketoids
" This function returns a string, so that (a) if/when it gets echoed
" back it shows the final command that's actually executed, and (b)
" so you can easily add other things before or after.
"
" TODO: See <https://github.com/romainl/vim-qf/blob/master/autoload/qf/wrap.vim>
"   re making this wrap around the ends.  Albeit they do it by
"   catching the appropriate exception, rather than checking
"   preemptively; also that means it won't handle wrap-around counts
"   like the `:b{prev,last}` commands do, only one-shot like the
"   no-count `:tab{p,n}` commands.
"   Fwiw, the is already first/last error pattern is: /^Vim\%((\a\+)\)\=:E553/
"   Whereas they just discard errors: /^Vim\%((\a\+)\)\=:E\%(325\|776\|42\):/
"   (E42: there is no qflist; E776: there is no loclist; E325:
"   trying to open a file which already has a swapfile)
"   "
"   Whereas, we can always use getqflist()/getloclist(), and from
"   there take the length and do some modular arithmetic.  Even
"   better, we can get it directly as explained at `:h *quickfix-size*`.
"   "
"   Though, I suppose I can see benefits to doing saturating
"   arithmetic too.  Sounds like it might should be an adjustable
"   setting...
" TODO: When foldclosed(line('.'))==-1 then the `zv` should be a
"   no-op anyways (afaict); so why does
"   <https://github.com/romainl/vim-qf/blob/master/autoload/qf/wrap.vim>
"   check for that?  Also, the foldclosed() function already
"   understands '.' so why wrap it with line()?
" TODO: how would we write an analogous thing for &foldclose when
"   leaving?  It's a string option, but the help only says what
"   happens when &fcl='all'.  And calling `zx` may be too aggressive
"   (N.B., `zx` == `zXzv`)
" Note: ideally we'd precompute as much of this as possible given
" only the args and then use that result to define a mapping that
" dynamically computes what remains (using v:count and &foldopen);
" but (a) that'd be a lot more code, and (b) there's not that much
" compute we'd save by doing so: just (1 + 2*a:wantcount) string
" appends is all.  Though I suppose we could set up an autocommand
" to redefine the mappings whenever &foldopen is changed; that would
" enable precomputing a lot more...
" Note: We must use the "\<>" syntax for special characters (i.e., not '<>')
" in order for `:nnoremap <expr>` to actually interpret them as
" special characters (rather than as a sequence of normal characters).
fun! wrengr#qf#BracketExpr(wantcount, cmd)
  return join(
    \ [ ":\<C-u>"
    \ , ((a:wantcount && v:count) ? v:count : '')
    \ , a:cmd
    \ , "\<CR>"
    \ , (&foldopen =~# 'quickfix' ? 'zv' : '')
    \ , 'zz'
    \ ], '')
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" BUGFIX: because :[cl]getexpr only use &g:efm for some reason.
" HT: <https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3>
" In particular see <#gistcomment-3245556> <#gistcomment-3246562>
" TODO: inform 'syngan/vim-vimlint' that we do in fact use a:expr
fun! wrengr#qf#getexpr(k, expr) abort
  if a:k !=# 'c' && a:k !=# 'l'
    call wrengr#utils#error('E492: Not an editor command: :' . a:k . 'getexpr')
    return
  endif
  let l:saved_efm = &g:errorformat
  try
    if !empty(&l:errorformat)
      let &g:errorformat = &l:errorformat
    endif
    " Note: the leading ':' isn't strictly required, since `:exec`
    " will always evaluate its argument in an Ex-cmdline mode.
    execute a:k . 'getexpr a:expr'
  finally
    let &g:errorformat = l:saved_efm
  endtry
endfun

" TODO: any decent way to unify these despite the arity differences?
" getqflist(           [  {what}])  -> List(Dict(...))
" getloclist({winNRID} [, {what}])  -> List(Dict(...))
"
" setqflist(            {list} [, {action} [, {what}]])
" setloclist({winNRID}, {list} [, {action} [, {what}]])


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" HT: <https://github.com/JesseLeite/dotfiles/blob/54fbd7c5109eb4a8e8a9d5d3aa67affe5c18efae/.vimrc#L444-L456>
" and <https://github.com/TamaMcGlinn/quickfixdd/commit/cc1adb7e7e9f4827cd655f6b1c05fadedaa87f45>
" or for a golfed version: <https://stackoverflow.com/a/56122471>
"
" When using `dd` in the quickfix list, remove the item from the quickfix list.
" <https://stackoverflow.com/q/42905008>
" TODO: see also `:h *quickfix-index*` re other ways of getting the
"   currently selected 'idx' as well as other ways to updating the
"   'idx' afterwards.
fun! wrengr#qf#RemoveQuickfixItemUnderCursor()
  let l:list = getqflist()
  if len(l:list) > 0 " Avoid warnings when the list is empty.
    let l:idx = line('.') - 1
    call remove(l:list, l:idx)
    call setqflist(l:list, 'r')
  endif
  if len(l:list) > 0
    execute l:idx + 1 . 'cfirst'
    copen
  else " Close the window if we just deleted the last one.
    cclose
  endif
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Clean Up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let &cpo = s:saved_cpo
unlet s:saved_cpo
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
