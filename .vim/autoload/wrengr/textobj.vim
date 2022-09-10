" WIP, HT: junegunn's dotfiles.  He has a whole lot more of them, but most wouldn't be at all useful to me I don't think.

" TODO: see also <https://gist.github.com/romainl/c0a8b57a36aec71a986f1120e1931f20> which looks to be where junegunn got a bunch of them (or vice versa?)

" inner-line text object.
" TODO: also, why would we ever want the :xmap ?
xnoremap <silent> il <Esc>^vg_
onoremap <silent> il :<C-u>normal! ^vg_<CR>
" TODO: those suggest mapping `al` to `|v$` as well...
" TODO: though I'm thinking both would be better off using `_` instead of `l`



" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ junegunn's idiom for certain text-objects
" TODO: I really don't understand what's going on here.  Like, I can parse that it literally does, but how the idiom actually works is what I'm missing.
fun! s:textobj_cancel()
  " Why not also 's'? (does that desugar to 'c' by the time we get here?)
  " TODO: should that be ==# or ==?
  if v:operator == 'c'
    augroup textobj_undo_empty_change
      " Why do we have to wrap these in :exec ?  Is it because of the <Bar> vs the autocmd?
      autocmd InsertLeave <buffer>
        \  execute 'normal! u'
        \| execute 'autocmd! textobj_undo_empty_change'
        \| execute 'augroup! textobj_undo_empty_change'
    augroup END
  endif
endfun

noremap         <Plug>(TOC) <Nop>
inoremap <expr> <Plug>(TOC) exists('#textobj_undo_empty_change')?"\<ESC>":''
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ inner-comment
" Note: this does a linewise selection, so it only really works as
" intended for line-comments (and those that aren't preceded by code
" no less).
xmap <silent> i# :<C-U>call <SID>inner_comment(1)<CR><Plug>(TOC)
omap <silent> i# :<C-U>call <SID>inner_comment(0)<CR><Plug>(TOC)

function! s:inner_comment(vis)
  if synIDattr(synID(line('.'), col('.'), 0), 'name') !~? 'comment'
    call s:textobj_cancel()
    if a:vis
      normal! gv
    endif
    return
  endif
  " Okay, we're in some comment.
  let origin = line('.')
  let lines = []
  for dir in [-1, 1]
    let line = origin
    let line += dir
    while line >= 1 && line <= line('$')
      " <G> is a jump; would we prefer to use <gg>/<C-Home> or <C-End> (which are not listed among the noted jumps); or simply use <:>{count} which is explicitly noted to be a nonjump. Or simply compute the position directly and pass that to synID(), ne?
      execute 'normal!' line.'G^'
      if synIDattr(synID(line('.'), col('.'), 0), 'name') !~? 'comment'
        break
      endif
      let line += dir
    endwhile
    let line -= dir
    call add(lines, line)
  endfor
  execute 'normal!' lines[0].'GV'.lines[1].'G'
endfun
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
