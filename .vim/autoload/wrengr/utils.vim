" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     autoload/wrengr/utils.vim
" Modified: 2024-02-01T18:05:15-08:00
" Version:  6
" Author:   wren romano
" Summary:  Utility functions for writing plugins.
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
" Version 5: added system(), trim()
" Version 5: added shellescape(), moved IncludeSyntax() and
"   MarkdownIncludeCodeblock() off to wrengr#syntax# instead.
" Version 4: Major bugfixing in vlet()
" Version 3: added error(), warn(), ShowIndentOptions(), ShowFoldOptions(),
"   IncludeSyntax(), MarkdownIncludeCodeblock().
"   * Removed the list-type `.=` from vlet()
" Version 2: added vlet()
" Version 1: DisableIndent(), DisableHardWrapping()
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Preamble (see `:h use-cpo-save` and `:h :set-&vim`)
if exists('g:loaded_wrengr_utils') | finish | endif
let g:loaded_wrengr_utils = 1
let s:saved_cpo = &cpo
set cpo&vim


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Using `:echoerr` prints a stack-trace, which causes double error
" messages: one for the error itself, and another for the function
" exiting in error.  While stack-traces are nice for debugging,
" they're not so good when the error message is more for diagnostic
" reasons.  This function handles that more common diagnostic situation.
"
" HT: Re saving the v:errmsg, <https://github.com/moll/vim-bbye/>
fun! wrengr#utils#error(msg)
  echohl ErrorMsg
  echomsg a:msg
  echohl NONE
  let v:errmsg = a:msg
endfun

fun! wrengr#utils#warn(msg)
  echohl WarningMsg
  echomsg a:msg
  echohl NONE
  let v:warningmsg = a:msg
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" We leave &ai alone, because it's always innocuous.
fun! wrengr#utils#DisableIndent()
  if has('lispindent')
    set nolisp
  endif
  if has('cindent')
    if has('eval')
      set indentexpr=
    endif
    set nocindent
  endif
  if has('smartindent')
    set nosmartindent
  endif
  set nosmarttab
endfun

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" TODO: when calling `:setl` with no arguments it'll list all the
" local options which differ from the default; but it'll also use
" prefix "--" for bool options to indicate when they're inheriting
" from the global value.  We might should try to do that too.
" The only case I can see this happening is with &autoread, and for
" that option at least we can detect this state via &l:autoread==-1;
" and indeed for other options like &ai we can cause this state by
" using `let &l:ai = -1`
" TODO: Alternatively, we may consider just using `:setl!` itself
" and then filtering out the options we don't care about?
" TODO: we may also consider writing some function to zip together
" the outputs from `:setl!` and `:setg!` (both of which only show
" those global-local options where the local option differs from the
" global; it's just that one shows the local value whereas the other
" shows the global value.)

" BUG: why did I have this use str2nr() ?
fun! s:showBoolOption(opt)
  exec 'let l:bool = &' . a:opt
  return (str2nr(l:bool) ? '  ' : 'no') . a:opt
endfun

fun! s:showStrOption(opt)
  exec 'let l:str = &' . a:opt
  return '  ' . a:opt . '=' . l:str
endfun

" So far, this isn't any different from showStrOption(); just for documenting
fun! s:showNrOption(opt)
  exec 'let l:str = &' . a:opt
  return '  ' . a:opt . '=' . l:str
endfun

" Note: The :echo command will happily interpret "\n"
" (even though :echomsg and :echoerr won't).
" Note: all these options are buffer-local only, except &smarttab
" and &shiftround which are global-only.
fun! wrengr#utils#ShowIndentOptions()
  let l:lines = []
  call add(l:lines, s:showBoolOption('autoindent'))
  " TODO: &copyindent, &preserveindent (which only apply if not &expandtab)
  if has('lispindent')
    call add(l:lines, s:showBoolOption('lisp'))
  endif
  if has('cindent')
    if has('eval')
      call add(l:lines, s:showStrOption('indentexpr'))
    endif
    call add(l:lines, s:showBoolOption('cindent'))
  endif
  if has('smartindent')
    call add(l:lines, s:showBoolOption('smartindent'))
  endif
  if has('vartabs')
    call add(l:lines, s:showStrOption('vartabstop'))
  endif
  call add(l:lines, s:showNrOption('tabstop'))
  if has('vartabs')
    call add(l:lines, s:showStrOption('varsofttabstop'))
  endif
  call add(l:lines, s:showNrOption('softtabstop'))
  call add(l:lines, s:showBoolOption('smarttab'))
  call add(l:lines, s:showBoolOption('expandtab'))
  call add(l:lines, s:showNrOption('shiftwidth'))
  call add(l:lines, s:showBoolOption('shiftround'))
  echo join(l:lines, "\n")
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fun! wrengr#utils#ShowFoldOptions()
  if !has('folding') | return | endif
  let l:lines = []
  call add(l:lines, s:showBoolOption('foldenable')) " 'fen'
  call add(l:lines, s:showStrOption('foldmethod'))  " 'fdm'
  if has('eval')
    call add(l:lines, s:showStrOption('foldexpr'))  " 'fde'
  endif
  call add(l:lines, s:showStrOption('foldignore'))  " 'fdi'
  call add(l:lines, s:showStrOption('foldmarker'))  " 'fmr'
  call add(l:lines, s:showNrOption('foldnestmax'))  " 'fdn'
  call add(l:lines, s:showStrOption('foldtext'))    " 'fdt'
  call add(l:lines, s:showStrOption('foldopen'))    " 'fdo: Which kinds of commands open closed folds. Use `zv` for mappings'
  call add(l:lines, s:showStrOption('foldclose'))   " 'fcl: When the folds not under the cursor are closed.'
  call add(l:lines, s:showNrOption('foldlevel'))    " 'fdl'
  call add(l:lines, s:showNrOption('foldlevelstart')) " 'fdls'
  call add(l:lines, s:showNrOption('foldminlines')) " 'fml'
  call add(l:lines, s:showNrOption('foldcolumn'))   " 'fdc'
  call add(l:lines, s:showStrOption('fillchars'))   " 'fcs'
  if has('mksession')
    call add(l:lines, s:showStrOption('viewdir'))   " 'vdir'
  endif
  echo join(l:lines, "\n")
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Try really hard to turn off hard-wrapping.
" Also get rid of other similar &fo options I hate.
"
" We break this out as a function, because we need to invoke it
" manually or in a bunch of different .vim/after/ftplugin/*.vim
" files. Some sources for what we're doing are:
"     <http://vim.wikia.com/wiki/Word_wrap_without_line_breaks>
"     <http://vimdoc.sourceforge.net/htmldoc/change.html#fo-table>
"     <http://vi.stackexchange.com/a/1985>
"     <http://stackoverflow.com/a/2312888/358069>
"     <http://stackoverflow.com/a/23326474/358069>

fun! wrengr#utils#DisableHardWrapping()
  " Can't hard-wrap at column zero, ha!
  " (Alas, `gq` relies on &tw, if we ever wanted to use that.)
  set textwidth=0 wrapmargin=0
  " Note: Must remove each one individually, because -= is string-based.
  set formatoptions-=t " Don't autowrap text using &textwidth
  set formatoptions-=c " Don't autowrap comments using &textwidth
  set formatoptions-=r " Don't autoinsert the comment leader on <Enter>
  set formatoptions-=o " Don't autoinsert the comment leader on <o> or <O>
  set formatoptions-=a " Disable 'auto-format' of paragraphs.
  set formatoptions+=l " Don't break already-long lines on InsertEnter.
  set formatoptions+=1 " Break before one-letter words, not after.
  " TODO: should also remove 'v', 'b', and ']' in case someone tries to
  " put those in there next. (Fwiw, they're not in the fo&vim default
  " (=='tcq'), but they are in the fo&vi default (=='vt'))
  " TODO: We may consider adding 'j', though it should probably be
  " guarded via `if has('patch-7.3.541')`
  " TODO: Maybe also consider adding 'p', especially for LaTeX.
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ A smarter shellescape()
" HT: <https://github.com/mhinz/vim-signify/issues/15>
" Note: &shellslash is global-only.
fun! wrengr#utils#shellescape(path)
  try
    " TODO: inform syngan/vim-vimlint that we don't care about
    "   EVL108 for this, since this feature is only ever for
    "   MS-Windows and that's precisely what we're checking for.
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
" ~~~~~ A backwards-compatible trim()
" HT: <https://stackoverflow.com/a/4479072>
fun! wrengr#utils#trim(str)
  if has('patch-8.0.1630')
    return trim(a:str)
  else
    " The leading `\m` is for hardening this regex, to ensure that
    " it is robust against thanges to the user's &magic setting.
    return substitute(a:str, '\m^\s*\(.\{-}\)\s*$', '\1', '')
  endif
endfun

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ A system() with verbose error messages.
"
" On success, returns the result of the `:silent system()` call;
" on failure, returns `v:null`.  Note that you can distinguish the
" empty string from `v:null` by using the `is#` or `==#` operators.
"
" NOTE: The command is run in `:silent` mode, which is the correct
" thing to do for non-interactive commands.  If you need to run an
" interactive command, then you prolly need a different solution
" anyways.
"
" NOTE: `system()` captures both stdout and stderr together!
" If you want to try disentangling them, see 'shellredir'.
"
" As far as Vim error-codes go, I couldn't immediately find anything
" that seemed right in <https://github.com/vim/vim/blob/master/src/errors.h>.
fun! wrengr#utils#system(cmd)
  if !executable(a:cmd)
    call wrengr#utils#error(
      \ 'ERROR(wrengr#utils#system): Is not executable(' . a:cmd . ')')
    return v:null
  endif
  silent let l:output = system(a:cmd)
  if v:shell_error != 0
    if v:shell_error == -1
      call wrengr#utils#error(
        \ 'ERROR(wrengr#utils#system): system(' . a:cmd
        \ . ') could not be executed')
    else
      call wrengr#utils#error(
        \ 'ERROR(wrengr#utils#system): system(' . a:cmd
        \ . ') failed with exit code: ' . v:shell_error)
    endif
    return v:null
  endif
  return l:output
endfun

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Autovivification for `:let`

let s:t_string = type('')
let s:t_list   = type([])
let s:t_dict   = type({})

fun! wrengr#utils#vlet(var, op, val) abort
  let l:t_val = type(a:val)
  if l:t_val == s:t_string
    if a:op ==# '.='
      " We use `.=` syntax with semantics like `:let $e .=` and `:let @r .=`
      " and `:let &o .=`; rather than using `:let v ..=` of `:scriptversion 2`
      if !exists(a:var)
        exec 'let ' . a:var . ' = ""'
      endif
      " TODO: we can use string() to quote/escape things; but I'm going
      " to try relying on the evaluation context instead for now.
      exec 'let ' . a:var . ' .= a:val'
      return 1
    elseif a:op ==# '+='
      " Like `:h :set+=` (albeit only for comma-lists, not pure/true
      " strings); but unlike `:let &o +=` (which doesn't support strings).
      " Also fwiw, neither `:let $e +=` nor `:let @r +=` exist.
      if !exists(a:var)
        exec 'let ' . a:var . ' = a:val'
        return 1
      else
        exec 'let ' . a:var . ' .= "," . a:val'
        return 1
      endif
    else
      " TODO: `^=` (cf `:h :set^=`); but should our version do the comma
      " or no?  I suppose we could invent `^+=` for the comma version and
      " let `^=` be the string version; or conversely `^=` vs `^.=`
      call wrengr#utils#error('ERROR(wrengr#utils#vlet): unsupported string operation: ' . a:op)
      return 0
    endif
  elseif l:t_val == s:t_list
    if !exists(a:var)
      exec 'let ' . a:var . ' = []'
    endif
    if a:op ==# '+='
      " BUGFIX: Vim 8.1.2269 doesn't have the list-function append(), it
      "   only has the append() function which is like the `:append` command.
      " TODO: supposedly `+` and `:let+=` work on lists, but istr that
      "   not working for me in the past...
      " Note: see <https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3>
      "   re `+` being faster than extend() at times.
      exec 'call extend(' . a:var . ', a:val)'
      return 1
    elseif a:op ==# '^='
      exec 'call extend(' . a:var . ', a:val, 0)'
      return 1
    else
      " TODO: we'd like to have `.=` do add(), but to do that would
      "   require knowing that the variable is of list type (rather
      "   than that the value is).
      call wrengr#utils#error('ERROR(wrengr#utils#vlet): unsupported list operation: ' . a:op)
      return 0
    endif
  elseif l:t_val == s:t_dict
    if !exists(a:var)
      exec 'let ' . a:var . ' = {}'
    endif
    if a:op ==# '.=' || a:op ==# '+='
      " BUG: how to requote a:val if/as necessary?
      exec 'call extend(' . a:var . ', a:val, "force")'
      return 1
    elseif a:op ==# '^='
      exec 'call extend(' . a:var . ', a:val , "keep")'
      return 1
    else
      call wrengr#utils#error('ERROR(wrengr#utils#vlet): unsupported list operation: ' . a:op)
      return 0
    endif
  elseif l:t_val == type(0)
    call wrengr#utils#error('ERROR(wrengr#utils#vlet): number type is unsupported, because the default value is unclear')
    return 0
  else
    call wrengr#utils#error('ERROR(wrengr#utils#vlet): unknown type: ' . l:t_val)
    return 0
  endif
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Clean Up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let &cpo = s:saved_cpo
unlet s:saved_cpo
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
