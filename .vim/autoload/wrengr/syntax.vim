" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     autoload/wrengr/syntax.vim
" Modified: 2021-09-26T20:37:31-07:00
" Version:  1
" Author:   wren romano
" Summary:  Utility functions for syntax.
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
" Version 1: broke out from wrengr#utils#
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Preamble (see `:h use-cpo-save` and `:h :set-&vim`)
if exists('g:loaded_wrengr_syntax') | finish | endif
let g:loaded_wrengr_syntax = 1
let s:saved_cpo = &cpo
set cpo&vim

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Embed one syntax file as a subsyntax of another.
" HT: <https://github.com/junegunn/dotfiles/blob/master/vimrc#L748>
" This is something I've always wanted from syntax highlighting,
" that no other editor seems able to give!! :) :) :)
fun! wrengr#syntax#Include(lang, start, end, inclusive)
  " First, find an appropriate syntax file.
  let l:syns = split(globpath(&runtimepath, 'syntax/'.a:lang.'.vim'), "\n")
  if empty(l:syns) | return 0 | endif
  " Stash away the knowledge of this buffer's syntax, so that the
  " included file doesn't see it and finish immediately.
  if exists('b:current_syntax')
    let l:csyn = b:current_syntax
    unlet b:current_syntax
  endif
  " Search for a suitable pattern delimiter.  So long as it's not
  " in the pattern itself, the choice doesn't matter (:help :syn-pattern).
  let l:q = "'"
  if a:start =~? l:q || a:end =~? l:q
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
  return 1
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Have Markdown files support fenced code-blocks.
" TODO: see also 'Shougo/context_filetype.vim'
fun! wrengr#syntax#MarkdownIncludeCodeblock()
  " junegunn also had 'mkd\|' added to this; but I don't think any
  " of our plugins use that...
  if &filetype !~? 'markdown' | return | endif
  " junegunn had 'bash=sh' and 'json=javascript'; but we do indeed
  " have syntax files for those; at least under vim-8.2.
  " TODO: Maybe we should add additional code to search for them
  " and if they're not found then to fallback?
  "
  " TODO: see also g:markdown_fenced_languages from 'vim-markdown'
  for l:lang in ['bash', 'c', 'clojure', 'clj=clojure', 'gnuplot', 'java',
      \ 'json', 'python', 'ruby', 'scala', 'sh', 'sql', 'vim', 'yaml']
    let l:langs = split(l:lang, '=')
    call wrengr#syntax#Include(l:langs[-1], '```'.l:langs[0], '```', 0)
  endfor
  highlight default link Snip Folded
endfun

" TODO: additional stuff junegunn had that we haven't needed yet:
" elseif &ft =~ 'jinja' && &ft != 'jinja'
"   call wrengr#syntax#Include('jinja', '{{', '}}', 1)
"   call wrengr#syntax#Include('jinja', '{%', '%}', 1)
" elseif &ft == 'sh'
"   call wrengr#syntax#Include('ruby', '#!ruby', '/\%$', 1)

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Clean Up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let &cpo = s:saved_cpo
unlet s:saved_cpo
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
