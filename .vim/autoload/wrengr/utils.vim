" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     autoload/wrengr/utils.vim
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

" ~~~~~ Preamble (see `:h use-cpo-save` and `:h :set-&vim`)
if exists('g:loaded_wrengr_utils')
  finish
endif
let g:loaded_wrengr_utils = 1
" Note: it appears `:set cpo&vim` doesn't buggily re-enable modelines,
" the way `:set nocompatible` does.
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
" ~~~~~ Clean Up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let &cpo = s:saved_cpo
unlet s:saved_cpo
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
