" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     autoload/wrengr/utils.vim
" Modified: 2021-09-22T22:39:28-07:00
" Version:  3
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
fun! wrengr#utils#ShowIndentOptions()
  let l:lines = []
  call add(l:lines, s:showBoolOption('autoindent'))
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
" ~~~~~ Autovivification for `:let`

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
      call wrengr#utils#error('ERROR(wrengr#utils#vlet): unsupported string operation: ' . a:op)
      return 0
    endif
  elseif l:t_val == s:t_list
    if !exists(a:var)
      exec 'let' a:var '= []'
    endif
    if a:op ==# '+='
      " BUG: how to requote a:val if/as necessary?
      " TODO: supposedly `+` and `:let+=` work on lists, but istr that
      "   not working for me in the past...
      exec 'call append(' a:var ',' a:val ')'
      return 1
    elseif a:op ==# '^='
      exec 'call extend(' a:var ',' a:val ', 0)'
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
" HT: <https://github.com/junegunn/dotfiles/blob/master/vimrc#L748>
" This is something I've always wanted from syntax highlighting,
" that no other editor seems able to give!! :) :) :)

" ~~~~~ Syntax highlighting in code snippets.
fun! wrengr#utils#IncludeSyntax(lang, start, end, inclusive)
  " First, find an appropriate syntax file.
  let l:syns = split(globpath(&runtimepath, 'syntax/'.a:lang.'.vim'), "\n")
  if empty(l:syns) | return | endif
  " Stash away the knowledge of this buffer's syntax, so that the
  " included file doesn't see it and finish immediately.
  if exists('b:current_syntax')
    let l:csyn = b:current_syntax
    unlet b:current_syntax
  endif
  " Search for a suitable pattern delimiter.  So long as it's not
  " in the pattern itself, the choice doesn't matter (:help :syn-pattern).
  let l:q = "'"
  if a:start =~ l:q || a:end =~ l:q
    for l:nr in range(char2nr('a'), char2nr('z'))
      let l:char = nr2char(l:nr)
      " Pretty sure :syn-pattern doesn't depend on &ignorecase and
      " isn't case sensitive either, but play it safe anyways.
      if a:start !~? l:char && a:end !~? l:char
        let l:q = l:char
        break
      endif
    endfor
  endif
  " Now, import the syntax file...
  silent! exec printf('syntax include @%s %s', a:lang, l:syns[0])
  " ...And declare the region it occurs in:
  if a:inclusive
    exec printf('syntax region %sSnip '
      \ . 'start=%s\(%s\)\@=%s end=%s\(%s\)\@<=\(\)%s '
      \ . 'contains=@%s containedin=ALL'
      \ , a:lang, l:q, a:start, l:q, l:q, a:end, l:q, a:lang)
  else
    exec printf('syntax region %sSnip matchgroup=Snip '
      \ . 'start=%s%s%s end=%s%s%s '
      \ . 'contains=@%s containedin=ALL',
      \ a:lang, l:q, a:start, l:q, l:q, a:end, l:q, a:lang)
  endif
  " Now, restore knowledge of this buffer's syntax.
  if exists('l:csyn')
    let b:current_syntax = l:csyn
  endif
endfun

" ~~~~~ Have Markdown files support fenced code-blocks.
" TODO: see also 'Shougo/context_filetype.vim'
fun! wrengr#utils#MarkdownIncludeCodeblock()
  " junegunn also had 'mkd\|' added to this; but I don't think any
  " of our plugins use that...
  if &filetype !~? 'markdown' | return | endif
  " junegunn had 'bash=sh' and 'json=javascript'; but we do indeed
  " have syntax files for those; at least under vim-8.2.  Maybe
  " we should add additional code to search for them and if they're
  " not found then to fallback?
  "
  " TODO: see also g:markdown_fenced_languages from 'vim-markdown'
  for l:lang in ['bash', 'c', 'clojure', 'clj=clojure', 'gnuplot', 'java',
      \ 'json', 'python', 'ruby', 'scala', 'sh', 'sql', 'vim', 'yaml']
    let l:langs = split(l:lang, '=')
    call wrengr#utils#IncludeSyntax(l:langs[-1], '```'.l:langs[0], '```', 0)
  endfor
  highlight default link Snip Folded
endfun

" TODO: additional stuff junegunn had that we haven't needed yet:
" elseif &ft =~ 'jinja' && &ft != 'jinja'
"   call wrengr#utils#IncludeSyntax('jinja', '{{', '}}', 1)
"   call wrengr#utils#IncludeSyntax('jinja', '{%', '%}', 1)
" elseif &ft == 'sh'
"   call wrengr#utils#IncludeSyntax('ruby', '#!ruby', '/\%$', 1)

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Clean Up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let &cpo = s:saved_cpo
unlet s:saved_cpo
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
