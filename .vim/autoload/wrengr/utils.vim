" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     autoload/wrengr/utils.vim
" Modified: 2021-09-22T16:12:41-07:00
" Version:  2
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
" Version 2: added vlet()
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Preamble (see `:h use-cpo-save` and `:h :set-&vim`)
if exists('g:loaded_wrengr_utils') | finish | endif
let g:loaded_wrengr_utils = 1
let s:saved_cpo = &cpo
set cpo&vim

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
" Try really hard to turn off hard-wrapping.
" Also get rid of &fo options I hate.
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
" ~~~~~ Autovivification for `:let`

" TODO: make this public from autoload/wrengr.vim (or public from this file).
fun! s:error(msg)
  echohl ErrorMsg
  echomsg a:msg
  echohl NONE
  let v:errmsg = a:msg
endfun

let s:t_string = type('')
let s:t_list   = type([])
let s:t_dict   = type({})

fun! wrengr#utils#vlet(var, op, val)
  let l:t_val = type(a:val)
  if l:t_val == s:t_string
    if a:op ==# '.='
      " We use `.=` syntax with semantics like `:let $e .=` and `:let @r .=`
      " and `:let &o .=`; rather than using `:let v ..=` of `:scriptversion 2`
      if !exists(a:var)
        exec 'let' a:var '= ""'
      endif
      " TODO: I think that'll do the right thing to double-quote/escape
      " the string so that :exec doesn't unwrap it.  But needs verification.
      exec 'let' a:var '.=' string(string(a:val))
      return 1
    elseif a:op ==# '+='
      " Like `:h :set+=` (albeit only for comma-lists, not pure/true
      " strings); but unlike `:let &o +=` (which doesn't support strings).
      " Also fwiw, neither `:let $e +=` nor `:let @r +=` exist.
      if !exists(a:var)
        exec 'let' a:var '=' string(string(a:val))
        return 1
      else
        exec 'let' a:var '.= '','' . ' string(string(a:val))
        return 1
      endif
    else
      " TODO: `^=` (cf `:h :set^=`); but should our version do the comma
      " or no?  I suppose we could invent `^+=` for the comma version and
      " let `^=` be the string version; or conversely `^=` vs `^.=`
      call s:error('ERROR(wrengr#utils#vlet): unsupported string operation: ' . a:op)
      return 0
    endif
  elseif l:t_val == s:t_list
    if !exists(a:var)
      exec 'let' a:var '= []'
    endif
    if a:op ==# '.=' || a:op ==# '+='
      " BUG: how to requote a:val if/as necessary?
      " TODO: supposedly `+` and `:let+=` work on lists, but istr that
      "   not working for me in the past...
      exec 'call append(' a:var ',' a:val ')'
      return 1
    elseif a:op ==# '^='
      exec 'call extend(' a:var ',' a:val ', 0)'
      return 1
    else
      call s:error('ERROR(wrengr#utils#vlet): unsupported list operation: ' . a:op)
      return 0
    endif
  elseif l:t_val == s:t_dict
    if !exists(a:var)
      exec 'let' a:var '= {}'
    endif
    if a:op ==# '.=' || a:op ==# '+='
      " BUG: how to requote a:val if/as necessary?
      exec 'call extend(' a:var ',' a:val ', "force")'
      return 1
    elseif a:op ==# '^='
      exec 'call extend(' a:var ',' a:val ', "keep")'
      return 1
    else
      call s:error('ERROR(wrengr#utils#vlet): unsupported list operation: ' . a:op)
      return 0
    endif
  elseif l:t_val == type(0)
    call s:error('ERROR(wrengr#utils#vlet): number type is unsupported, because the default value is unclear')
    return 0
  else
    call s:error('ERROR(wrengr#utils#vlet): unknown type: ' . l:t_val)
    return 0
  endif
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Clean Up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let &cpo = s:saved_cpo
unlet s:saved_cpo
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
