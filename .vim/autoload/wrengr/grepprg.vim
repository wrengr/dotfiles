" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     autoload/wrengr/grepprg.vim
" Modified: $$
" Version:  0
" Author:   wren romano
" Summary:  Smarter setting of &grepprg and &grepformat
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
" TODO: cf., <https://robots.thoughtbot.com/faster-grepping-in-vim>,
"   the comment to <https://stackoverflow.com/a/4889864/358069>
" TODO: see also <https://github.com/cypher/dotfiles/blob/master/vim/extensions.vim#L177>
" TODO: Compare <https://github.com/chrisjohnson/vim-grep>
" TODO: in lieu of all this, should see `:h *write-compiler-plugin*`
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Preamble (See `:h use-cpo-save` and `:h :set-&vim`)
if exists('g:loaded_wrengr_grepprg') | finish | endif
let g:loaded_wrengr_grepprg = 1
let s:saved_cpo = &cpo
set cpo&vim

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" N.B., &grepprg is global or buffer-local
" but   &grepformat is global only!
" TODO: We may want these functions to take an argument to specify
"   whether to set the global vs local value of &grepprg
" TODO: shouldn't we lift the ctrlp stuff out and do it for all of these?
" TODO: how can we (cleanly) dynamically adjust the grepprg based
"   on the value of &ignorecase at the time the :grep command is
"   called, rather than when these functions are called?
" Note: the default &grepformat seems to be '%f:%l:%m,%f:%l%m,%f  %l%m' at least on Mayari
"
" Note: the use of `$*` is telling Vim where to substitute in the
" arguments to the `:grep` command.  I'm guessing that's mainly for
" when you want to append something after those arguments, and that
" Vim'll just append things if it doesn't see `$*` ?


" linenumbers; filenameheaders; recursive.
"set grepprg=grep\ -nHr\ $*\ /dev/null

" HT: <https://www.reddit.com/r/vim/comments/6znnpf/comment/dmx0eg7/?utm_source=reddit&utm_medium=web2x&context=3>
" TODO: see also <https://gist.github.com/patrickriordan/ca9dc37d9183e9924880f2ec05e9dfae>
fun! wrengr#grepprg#gitgrep()
  if !executable('git') | return 0 | endif
  " TODO: consider --is-inside-work-tree or --show-cdup instead of --git-dir
  if system('git rev-parse --git-dir 2> /dev/null') =~# '\.git'
    " TODO: consider --no-pager
    let &grepprg = 'git grep -n' . (&ignorecase ? 'i' : '')
  endif
endfun

" <https://beyondgrep.com>
" Latest: 2021-03-12 (v3.5.0)
fun! wrengr#grepprg#ack()
  if !executable('ack') | return 1 | endif
  let &grepprg = 'ack --nogroup --nocolor --column' (&ignorecase ? '--ignore-case' : '')
  set grepformat=%f:%l:%c:%m,%f:%l:%m
  return 1
endfun

" <https://github.com/ggreer/the_silver_searcher> <https://geoff.greer.fm/ag/>
" Last Modified: 2020-12-16 (never tagged/released in github)
" N.B., <https://geoff.greer.fm/2014/10/13/help-me-get-to-ag-10/>
fun! wrengr#grepprg#ag()
  if !executable('ag') | return 0 | endif
  " According to <#editor-integration> the --vimgrep flag is
  " equivalent to `--nogroup --nocolor --column` plus also reporting
  " every match on a line.
  " TODO: consider adding --hidden ?
  let &grepprg = 'ag --vimgrep' (&ignorecase ? '--ignore-case' : '')
  set grepformat=%f:%l:%c:%m,%f:%l:%m
  return 1
endfun

" <https://github.com/svent/sift> <https://sift-tool.org>
" Warning: Last modified 2016-10-23 (v0.9.0)
fun! wrengr#grepprg#sift()
  if !executable('sift') | return 0 | endif
  " TODO: does this one have --hidden ?
  set grepprg=sift\ -nMs\ --no-color\ --no-group\ --column\ --binary-skip\ --git\ --follow
  set grepformat=%f:%l:%c:%m
  return 1
endfun

" <https://github.com/monochromegane/the_platinum_searcher>
" Warning: Last modified 2018-09-05 (v2.2.0)

" <https://github.com/BurntSushi/ripgrep>
" Latest: 2021-06-12 (v13.0.0)
" TODO: see also <https://medium.com/@crashybang/supercharge-vim-with-fzf-and-ripgrep-d4661fc853d2>
fun! wrengr#grepprg#ripgrep()
  if !executable('rg') | return 0 | endif
  " TODO: consider adding --color=never --hidden
  let &grepprg = 'rg --vimgrep --no-heading' (&ignorecase ? '--ignore-case' : '')
  " Apparently the --vimgrep argument above causes to use the '%f:%l:%c:%m' format, which isn't in &gfm by default.
  set grepformat=%f:%l:%c:%m,%f:%l:%m
  return 1
endfun

" <https://github.com/Genivia/ugrep>
" Latest: 2021-08-06 (v3.3.7)
fun! wrengr#grepprg#ugrep()
  if !executable('ugrep') | return 0 | endif
  " TODO: should also have an option (or by default) use `ug` rather
  " than `ugrep`, so that we load the configfile.
  let &grepprg = 'ugrep -RInk ' . (&ignorecase ? '-j' : '') . ' -u --tabs=1 --ignore-files'
  set grepformat=%f:%l:%c:%m,%f+%l+%c+%m,%-G%f\\\|%l\\\|%c\\\|%m
  " BUG: should only do this the once, and should really do it at VimEnter or such
  "if has_key(g:plugs, 'ctrlp.vim')
  "  set runtimepath^=~/.vim/bundle/ctrlp.vim
  "  let g:ctrlp_match_window='bottom,order:ttb'
  "  let g:ctrlp_user_command='ugrep "" %s -Rl -I --ignore-files -3'
  "endif
  return 1
endfun

" <https://www.gnu.org/software/idutils/>
" This was mentioned/suggested in section 5.4 of quickfix.txt
fun! wrengr#grepprg#idutils()
  if !executable('lid') | return 0 | endif
  set grepprg=lid\ -Rgrep\ -s
  set grepformat=%f:%l:%m
  return 1
endfun

" TODO: see also `:h current_compiler`
" `:h compiler-gcc`     let g:compiler_gcc_ignore_unmatched_lines =
" `:h compiler-perl`    let g:perl_compiler_force_warnings =
" `:h compiler-pyunit`
" `:h compiler-tex`


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Clean Up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let &cpo = s:saved_cpo
unlet s:saved_cpo
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
