" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" wren romano's ~/.vim/after/ftplugin/qf.vim        ~ 2021.10.03
"
" &ft=qf is for Vim's quickfix and loclist windows.
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Then what are you doing reading this file?
if !has('quickfix') | finish | endif

" I don't like using the `<` syntax cuz that'll revert to Vim's
" default rather than to whatever was there before (which may be
" non-default!)
let b:undo_ftplugin =
  \ (exists('b:undo_ftplugin') ? b:undo_ftplugin . ' | ' : '')
  \ . 'setlocal '
  \ . (&buflisted       ? '' : 'no') . 'buflisted '
  \ . (&wrap            ? '' : 'no') . 'wrap '
  \ . (&number          ? '' : 'no') . 'number '
  \ . (&relativenumber  ? '' : 'no') . 'relativenumber '

" Is already buftype=quickfix bufhidden=hide noswapfile (on Mayari at least).
" Also, apparently I really like/need &wrap here; at least for Google
setlocal nobuflisted wrap number norelativenumber

" Unmap our vimrc#s:LineNrToggle()
nnoremap <buffer> <C-n> <Nop>
let b:undo_ftplugin .= ' | silent! nunmap <buffer> <C-n>'
" TODO: why does wrap all his b:undo_ftplugin unmaps in `:exec`?

" Quit the tabpage if the last window is this qf-window (and exit
" vim if this is the last tabpage).
" HT: 'romainl/vim-qf'
" Note: We cannot use `:cclose` if this is the last window, because
"   that'll throw E444 ("Cannot close last window").
" BUG: need to augroup this; but should we reuse wrengr_qf or what?
autocmd BufEnter <buffer> nested if winnr('$') < 2 | quit | endif
" Not the best approach, but it'll have to do for now...
let b:undo_ftplugin .= ' | autocmd! BufEnter <buffer>'

" TODO: consider this other bit from 'romainl/vim-qf' as well; which
" amends *every* window to have an autocmd to close the loclist-window
" associated with that window's buffer.  We really can't have this
" in this ftplugin file though, it has to be moved to a proper plugin
" or to vimrc; else there's no good way to augroup it.
"if exists('##QuitPre')
"  autocmd QuitPre * nested if &filetype != 'qf' | silent! lclose | endif
"endif
"
" Note: 'romainl/vim-qf' has a *lot* of autocmds for opening/closing
" the qf/loc windows, some of which are rather tricksy.  So we may
" want to use/fork that repo rather than completely rolling our own.


" HT: <https://vonheikemen.github.io/devlog/tools/vim-and-the-quickfix-list/>
" TODO: may want a buffer-local mapping to toggle &modifiable,
"   else the `<leader>w` isn't going to be so useful.
"   TODO: see also 'stefandtw/quickfix-reflector.vim'
"   and cf., <https://github.com/stefandtw/quickfix-reflector.vim/issues/9>
" TODO: maybe just maybe, add the mapping to pretype out the
"   :cdo s/// command and leave the cursor in a good spot.
"   Though again, needs a better name.
" BUG: need to escape the &l:efm appropriately!
"let b:undo_ftplugin .= ' | setlocal errorformat=' . &l:errorformat
setlocal errorformat+=%f\|%l\ col\ %c\|%m
nnoremap <buffer><expr> <leader>w
  \ join([':<C-u>', 'getbuffer<Bar>', 'close<Bar>', 'open<CR>'], wrengr#qf#CL())

" TODO: we might should cache the value of wrengr#qf#CL() in a
"   buffer-local variable, to avoid needing to recompute it all the
"   time.  Of course, if we're going to do that then we might should
"   have the function do so itself so that it can check its own cache.

nnoremap <buffer><expr> q ':<C-u>' . wrengr#qf#CL() . 'close<CR>'
nnoremap <buffer><expr> Q ':<C-u>' . wrengr#qf#CL() . 'close<CR>'

let b:undo_ftplugin .= ' | silent! nunmap <buffer> ' . (exists('mapleader') && !empty(mapleader) ? mapleader : '\') . 'w'
let b:undo_ftplugin .= ' | silent! nunmap <buffer> q'
let b:undo_ftplugin .= ' | silent! nunmap <buffer> Q'

" TODO: would we want to adjust the 'q' bracketoids to append `<C-w>p` ?

" TODO: see <https://vimways.org/2018/colder-quickfix-lists/>

" HT: <https://github.com/JesseLeite/dotfiles/blob/54fbd7c5109eb4a8e8a9d5d3aa67affe5c18efae/.vimrc#L444-L456>
" When using `dd` in the quickfix list, remove the item from the quickfix list.
" <https://stackoverflow.com/q/42905008>
"nnoremap <buffer> dd :call wrengr#qf#RemoveQuickfixItemUnderCursor(v:count1)<CR>
" TODO: properly handle v:count (how can we even allow things like `d5d` ??)  N.B., `0dd` is the same as `dd` but `d0d` is a no-op.  Hmm, it seems like we can't say `d#d` anymore, since we're left in operator-pending mode after that second `d`...  Well that simplifies things.

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
