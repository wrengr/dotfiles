" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     autoload/airline/themes/overmorrow.vim
" Modified: $$
" Version:  1
" Author:   wren romano
" Summary:  My own personal colorscheme.
" License:  This program is free software; you can redistribute it and/or
"           modify it under the terms of the GNU General Public License
"           as published by the Free Software Foundation; either version
"           2 of the License, or (at your option) any later version.
"           See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt>
"
" Complement to my colors/overmorrow.vim, to update changes in the
" palette compared vs autoload/airline/themes/tomorrow.vim
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" TODO: may want to make the color variables of colors/overmorrow.vim
" public, so we can reuse them here.

" Initialization.
let s:palette = {}
let s:ER = airline#themes#get_highlight2(['ErrorMsg', 'bg'], ['ErrorMsg', 'fg'], 'bold')
let s:modified = { 'airline_c': [...] }
let s:paste    = { 'airline_a': [...] }

let s:sections = ['a', 'b', 'c', 'x', 'y', 'z']
let s:modes = ['normal', 'visual', 'insert', 'replace', 'inactive', 'terminal'?, 'commandline', 'ctrlp']
let s:overrides = ['modified', 'paste']
let s:extra_toplevel = ['accents']
let s:submodes = ['airline_warning', 'airline_error', 'airline_term']
let s:accents = ['none', 'bold', 'italic', 'red', 'green', 'blue', 'yellow', 'orange', 'purple']
    " Actually airline#themes#patch() will override the [none,bold,italic]
    " For accents at least, can use empty string to indicate fallback to the main mode (or override?).
    " red is used for 'readonly'

" airline#themes#generate_color_map()
"   Takes 3 required list arguments
"       Used for 'airline_{a,b,c}' respectively
"   Takes 3 optional list arguments (unless Vim9script!!)
"       Used for 'airline_{x,y,z}' respectively
"       Else will default to 'airline_{c,b,a}'
"   All six lists have
"       3 required elements, +1 optional element
"       [guifg, guibg, ctermfg, ctermbg, opts]
" airline#themes#generate_color_map() also uses the values provided as
" parameters to create intermediary groups such as:
"   airline_a_to_airline_b
"   airline_b_to_airline_c
"   etc...
" Overrides are applied after the main mode, thus don't need to specify all keys.

" TODO: support lists for 'opts' and comma-join them.
" TODO: handle 88-color, and do the right thing re 256-color.
fun! s:Section(fg, bg, opts)
  return
    \ [ get(a:fg, 'hex', '')
    \ , get(a:fg, 'cterm256', '')
    \ , get(a:bg, 'hex', '')
    \ , get(a:bg, 'cterm256', '')
    \ , l:opts
    \ ]
endfun



" Normal-mode.
let s:NA = s:Section(_, _, _)
let s:NB = s:Section(_, _, _)
let s:NC = s:Section(_, _, _)
let s:palette.normal =
  \ airline#themes#generate_color_map(s:NA, s:NB, s:NC)
let s:palette.normal.airline_warning =
  \ [s:ER[1], s:ER[0], s:ER[3], s:ER[2]]
let s:palette.normal.airline_error =
let s:palette.normal_modified = ...
let s:palette.normal_modified.airline_warning = ...
let s:palette.normal_modified.airline_error = ...

" Visual- & Select-modes.
let s:VA = s:Section(_, _, _)
let s:VB = s:Section(_, _, _)
let s:VC = s:Section(_, _, _)
let s:palette.visual =
  \ airline#themes#generate_color_map(s:VA, s:VB, s:VC)
let s:palette.visual.airline_warning = ...
let s:palette.visual.airline_error = ...
let s:palette.visual_modified = ...
let s:palette.visual_modified.airline_warning = ...
let s:palette.visual_modified.airline_error = ...

" Insert-mode.
let s:IA = s:Section(_, _, _)
let s:IB = s:Section(_, _, _)
let s:IC = s:Section(_, _, _)
let s:palette.insert =
  \ airline#themes#generate_color_map(s:IA, s:IB, s:IC)
let s:palette.insert.airline_warning = ...
let s:palette.insert.airline_error = ...
let s:palette.insert_modified = ...
let s:palette.insert_modified.airline_warning = ...
let s:palette.insert_modified.airline_error = ...
let s:palette.insert_paste = ...

" Replace-mode.
let s:RA = s:Section(_, _, _)
let s:RB = s:Section(_, _, _)
let s:RC = s:Section(_, _, _)
let s:palette.replace =
  \ airline#themes#generate_color_map(s:RA, s:RB, s:RC)
let s:palette.replace.airline_warning = ...
let s:palette.replace.airline_error = ...
let s:palette.replace_modified = ...
let s:palette.replace_modified.airline_warning = ...
let s:palette.replace_modified.airline_error = ...

" Cmdline-mode.
let s:CA = s:Section(_, _, _)
let s:CB = s:Section(_, _, _)
let s:CC = s:Section(_, _, _)
let s:palette.command =
  \ airline#themes#generate_color_map(s:CA, s:CB, s:CC)

" Inactive window.
let s:ZA = s:Section(_, _, _)
let s:ZB = s:Section(_, _, _)
let s:ZC = s:Section(_, _, _)
let s:palette.inactive =
  \ airline#themes#generate_color_map(s:ZA, s:ZB, s:ZC)

" Terminal window.
let s:TA = s:Section(_, _, _)
let s:TB = s:Section(_, _, _)
let s:TC = s:Section(_, _, _)
let s:palette.{...}.airline_term =
  \ airline#themes#generate_color_map(s:TA, s:TB, s:TC)

" CtrlP
" Not sure why everyone uses get() here instead of just exists().
if get(g:, 'loaded_ctrlp', 0)
  let s:PA = s:Section(_, _, _)
  let s:PB = s:Section(_, _, _)
  let s:PC = s:Section(_, _, _)
  let s:palette.ctrlp =
    \ airline#extensions#ctrlp#generate_color_map(s:PA, s:PB, s:PC)
endif

" See also:
"   * g:airline_mode_map
"   * g:airline_symbols
"   * call airline#themes#atomic#refresh()
"   * themes: transparent, solarized_flood, solarized, badwolf, onedark
"   * Beware <https://github.com/vim-airline/vim-airline/issues/2298>, see lessnoise theme for the workaround.


let g:airline#themes#sol#palette.tabline = {
      \ 'airline_tab':      ['#343434', '#b3b3b3',  237, 250, ''],
      \ 'airline_tabsel':   ['#ffffff', '#004b9a',  231, 31 , ''],
      \ 'airline_tabtype':  ['#343434', '#a0a0a0',  237, 248, ''],
      \ 'airline_tabfill':  ['#343434', '#c7c7c7',  237, 251, ''],
      \ 'airline_tabmod':   ['#343434', '#ffdbc7',  237, 216, ''],
      \ }
let g:airline#themes#lessnoise#palette.tabline = {
      \ 'airline_tablabel'          : s:atl,
      \ 'airline_tab'               : s:at,
      \ 'airline_tabsel'            : s:ats,
      \ 'airline_tabfill'           : s:atf,
      \ 'airline_tabmod'            : s:atm,
      \ 'airline_tabhid'            : s:at,
      \ 'airline_tabmod_unsel'      : s:atu,
      \ 'airline_tab_right'         : s:at,
      \ 'airline_tabsel_right'      : s:ats,
      \ 'airline_tabfill_right'     : s:atf,
      \ 'airline_tabmod_right'      : s:atm,
      \ 'airline_tabhid_right'      : s:at,
      \ 'airline_tabmod_unsel_right': s:atu
      \ }

" vim-lsp
if get(g:, 'lsp_loaded', 0)
  " In case we want to change any of these defaults.
  " I guess really that's outside the purview of a colorscheme/theme,
  " and should really be left up to the user's $MYVIMRC...
  "let g:airline#extensions#lsp#open_lnum_symbol    = '(L'
  "let g:airline#extensions#lsp#close_lnum_symbol   = ')'
  "let g:airline#extensions#lsp#error_symbol        = 'E:'
  "let g:airline#extensions#lsp#warning_symbol      = 'W:'
  "let g:airline#extensions#lsp#show_line_numbers   = 1
  "let g:airline#extensions#lsp#progress_skip_time  = 0.3
endif

" ~~~~~ Omg, there's a lot of extensions to tweak if we want
"       How many of these are on our list?
"autoload/airline/extensions.vim
"autoload/airline/extensions/lsp.vim            " yes
"autoload/airline/extensions/neomake.vim
"autoload/airline/extensions/tmuxline.vim
"autoload/airline/extensions/poetv.vim
"autoload/airline/extensions/denite.vim
"autoload/airline/extensions/obsession.vim
"autoload/airline/extensions/zoomwintab.vim
"autoload/airline/extensions/hunks.vim
"autoload/airline/extensions/gen_tags.vim
"autoload/airline/extensions/gutentags.vim      " yes
"autoload/airline/extensions/term.vim
"autoload/airline/extensions/po.vim
"autoload/airline/extensions/cursormode.vim
"autoload/airline/extensions/wordcount/formatters/default.vim
"autoload/airline/extensions/wordcount/formatters/readingtime.vim
"autoload/airline/extensions/coc.vim
"autoload/airline/extensions/virtualenv.vim     " yes, iirc
"autoload/airline/extensions/promptline.vim
"autoload/airline/extensions/keymap.vim
"autoload/airline/extensions/languageclient.vim
"autoload/airline/extensions/tagbar.vim         " yes
"autoload/airline/extensions/syntastic.vim      " yes
"autoload/airline/extensions/unicode.vim        " yes, iirc
"autoload/airline/extensions/vista.vim
"autoload/airline/extensions/gina.vim
"autoload/airline/extensions/ctrlspace.vim
"autoload/airline/extensions/fern.vim
"autoload/airline/extensions/fzf.vim            " yes
"autoload/airline/extensions/vimtex.vim         " yes
"autoload/airline/extensions/tabline.vim        " yes, iirc
"autoload/airline/extensions/localsearch.vim
"autoload/airline/extensions/battery.vim
"autoload/airline/extensions/nvimlsp.vim
"autoload/airline/extensions/nrrwrgn.vim
"autoload/airline/extensions/example.vim
"autoload/airline/extensions/undotree.vim       " yes
"autoload/airline/extensions/capslock.vim
"autoload/airline/extensions/scrollbar.vim
"autoload/airline/extensions/wordcount.vim
"autoload/airline/extensions/csv.vim
"autoload/airline/extensions/grepper.vim
"autoload/airline/extensions/dirvish.vim        " yes
"autoload/airline/extensions/windowswap.vim
"autoload/airline/extensions/bufferline.vim     " yes, iirc
"autoload/airline/extensions/ycm.vim            " yes, though unlikely
"autoload/airline/extensions/default.vim
"autoload/airline/extensions/netrw.vim          " Yes
"autoload/airline/extensions/tabline/builder.vim
"autoload/airline/extensions/tabline/autoshow.vim
"autoload/airline/extensions/tabline/tabws.vim
"autoload/airline/extensions/tabline/ctrlspace.vim
"autoload/airline/extensions/tabline/buffers.vim
"autoload/airline/extensions/tabline/formatters/unique_tail_improved.vim
"autoload/airline/extensions/tabline/formatters/tabnr.vim
"autoload/airline/extensions/tabline/formatters/short_path.vim
"autoload/airline/extensions/tabline/formatters/jsformatter.vim
"autoload/airline/extensions/tabline/formatters/default.vim
"autoload/airline/extensions/tabline/formatters/unique_tail.vim
"autoload/airline/extensions/tabline/xtabline.vim
"autoload/airline/extensions/tabline/tabs.vim
"autoload/airline/extensions/tabline/buflist.vim
"autoload/airline/extensions/unite.vim
"autoload/airline/extensions/whitespace.vim
"autoload/airline/extensions/searchcount.vim
"autoload/airline/extensions/vimcmake.vim
"autoload/airline/extensions/xkblayout.vim
"autoload/airline/extensions/commandt.vim
"autoload/airline/extensions/bookmark.vim
"autoload/airline/extensions/omnisharp.vim
"autoload/airline/extensions/quickfix.vim
"autoload/airline/extensions/branch.vim
"autoload/airline/extensions/eclim.vim
"autoload/airline/extensions/ale.vim
"autoload/airline/extensions/ctrlp.vim

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Finalization
let g:airline#themes#overmorrow#palette = s:palette
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
