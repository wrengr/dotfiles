" Vim syntax file
" Language:    PROLOG
" Maintainers: Ralph Becket <rwab1@cam.sri.co.uk>,
"              Thomas Koehler <jean-luc@picard.franken.de>
" Last Change: 2002 September 30
" URL:         http://jeanluc-picard.de/vim/syntax/prolog.vim
"
" TODO: There's a newer version of this (2016-09-06) by Thomas Koehler, at:
" <https://github.com/vim/vim/commit/64d8e25bf6efe5f18b032563521c3ce278c316ab>
" After that it was taken over by Anton Kochkov (2019-08-29):
" <https://github.com/vim/vim/commit/06fe74aef72606ac34c9f494186e52614b8fb59a>
" With another update in 2021-01-05:
" <https://github.com/vim/vim/commit/82be4849eed0b8fbee45bc8da99b685ec89af59a>
" Was this/my version because it didn't used to be distributed with
" vim itself?  Or did I not like some of those changes for some reason?


" There are two sets of highlighting in here:
" If the "prolog_highlighting_clean" variable exists, it is rather sparse.
" Otherwise you get more highlighting.

" Quit when a syntax file was already loaded
if version < 600
   syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Prolog is case sensitive.
syn case match

" Very simple highlighting for comments, clause heads and
" character codes.  It respects prolog strings and atoms.

syn region   prologCComment     start=+/\*+ end=+\*/+
syn match    prologComment      +%.*+

syn keyword  prologKeyword      module meta_predicate multifile dynamic
syn match    prologCharCode     +0'\\\=.+
syn region   prologString       start=+"+ skip=+\\"+ end=+"+
syn region   prologAtom         start=+'+ skip=+\\'+ end=+'+
syn region   prologClauseHead   start=+^[a-z][^(]*(+ skip=+\.[^ 	]+ end=+:-\|\.$\|\.[ 	]\|-->+

if !exists("prolog_highlighting_clean")

  " some keywords
  " some common predicates are also highlighted as keywords
  " is there a better solution?
  syn keyword prologKeyword   abolish current_output  peek_code
  syn keyword prologKeyword   append  current_predicate       put_byte
  syn keyword prologKeyword   arg     current_prolog_flag     put_char
  syn keyword prologKeyword   asserta fail    put_code
  syn keyword prologKeyword   assertz findall read
  syn keyword prologKeyword   at_end_of_stream        float   read_term
  syn keyword prologKeyword   atom    flush_output    repeat
  syn keyword prologKeyword   atom_chars      functor retract
  syn keyword prologKeyword   atom_codes      get_byte        set_input
  syn keyword prologKeyword   atom_concat     get_char        set_output
  syn keyword prologKeyword   atom_length     get_code        set_prolog_flag
  syn keyword prologKeyword   atomic  halt    set_stream_position
  syn keyword prologKeyword   bagof   integer setof
  syn keyword prologKeyword   call    is      stream_property
  syn keyword prologKeyword   catch   nl      sub_atom
  syn keyword prologKeyword   char_code       nonvar  throw
  syn keyword prologKeyword   char_conversion number  true
  syn keyword prologKeyword   clause  number_chars    unify_with_occurs_check
  syn keyword prologKeyword   close   number_codes    var
  syn keyword prologKeyword   compound        once    write
  syn keyword prologKeyword   copy_term       op      write_canonical
  syn keyword prologKeyword   current_char_conversion open    write_term
  syn keyword prologKeyword   current_input   peek_byte       writeq
  syn keyword prologKeyword   current_op      peek_char

  syn match   prologOperator "=\\=\|=:=\|\\==\|=<\|==\|>=\|\\=\|\\+\|<\|>\|="
  syn match   prologAsIs     "===\|\\===\|<=\|=>"

  syn match   prologNumber            "\<[0123456789]*\>"
  syn match   prologCommentError      "\*/"
  syn match   prologSpecialCharacter  ";"
  syn match   prologSpecialCharacter  "!"
  syn match   prologQuestion          "?-.*\."  contains=prologNumber


endif

syn sync ccomment maxlines=50


" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_prolog_syn_inits")
  if version < 508
    let did_prolog_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default highlighting.
  HiLink prologComment            Comment
  HiLink prologCComment           Comment
  HiLink prologCharCode           Special

  if exists ("prolog_highlighting_clean")

    HiLink prologKeyword          Statement
    HiLink prologClauseHead       Statement

  else

    HiLink prologKeyword          Keyword
    HiLink prologClauseHead       Constant
    HiLink prologQuestion         PreProc
    HiLink prologSpecialCharacter Special
    HiLink prologNumber           Number
    HiLink prologAsIs             Normal
    HiLink prologCommentError     Error
    HiLink prologAtom             String
    HiLink prologString           String
    HiLink prologOperator         Operator

  endif

  delcommand HiLink
endif

let b:current_syntax = "prolog"

" vim: ts=28
