" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     autoload/wrengr/lsp.vim
" Modified: 2021-09-23T12:25:05-07:00
" Version:  1
" Author:   wren romano
" Summary:  Functions for use with vim-lsp.
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

" ~~~~~ Preamble (See `:h use-cpo-save` and `:h :set-&vim`)
if exists('g:loaded_wrengr_lsp') | finish | endif
let g:loaded_wrengr_lsp = 1
let s:saved_cpo = &cpo
set cpo&vim

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" See: `:h vim-lsp-folding` for more details.
" Note: All three options are window-local only.  But since vim-lsp
" is enabled or not on a per-buffer basis, we'll need to be clever
" about stashing and restoring the settings.  We combine the
" buffer-number and window-ID so we can flatten the two dicts into
" one, since in other scripting languages nested dicts are a known
" performance problem.  We do still have two layers (the s:cache and
" each l:fold), but at least we don't have three.  Flattening these
" last two is a lot trickier; if we're really concerned about the
" performance, then we could either make l:fold a list instead, or
" we could try switching to a scripting language (lua?) which offers
" proper structs.
" Note: so far we're respecting the fact that these options are
" window-local; i.e., if the same buffer is in multiple windows,
" we will only enable/disable folding for the window current at the
" time of the function call.  Though we may wish to forego that and
" try simulating the behavior of if these were buffer-local settings
" instead.

let s:cache = {}
fun! wrengr#lsp#EnableFolding()
  if !(has('folding') && has('eval'))
    " Without the right features, can't use the options anyways.
    " Just let the caller know we did nothing.
    return 0
  endif
  let l:key  = win_getid() . '_' . bufnr()
  if !(has_key(s:cache, l:key) && get(g:, 'lsp_fold_enabled', 0))
    " Either it's already enabled, or g:lsp_fold_enabled is disabled;
    " either way is fine.  Just let the caller know we did nothing.
    return 0
  endif
  " Should only enable when we haven't already (else we'd lose the
  " original settings when we write to the s:cache), and when
  " g:lsp_fold_enabled is currently true.
  let s:cache[l:key] =
    \ { 'method': &foldmethod
    \ , 'expr':   &foldexpr
    \ , 'text':   &foldtext
    \ }
  set foldmethod=expr
    \ foldexpr=lsp#ui#vim#folding#foldexpr()
    \ foldtext=lsp#ui#vim#folding#foldtext()
  " Let the caller know we did something.
  return 1
endfun

fun! wrengr#lsp#DisableFolding()
  if !(has('folding') && has('eval'))
    " Without the right features, can't use the options anyways.
    " Just let the caller know we did nothing.
    return 0
  endif
  let l:key  = win_getid() . '_' . bufnr()
  let l:fold = get(s:cache, l:key, {})
  if empty(l:fold)
    " It wasn't enabled, but that's fine.
    " Just let the caller know we did nothing.
    return 0
  endif
  " We can always restore from cache, even if g:lsp_fold_enabled
  " has become false since we cached it.  (Though I guess if the
  " current values aren't the ones we set, then that might be a
  " problem.)
  let &foldmethod = l:fold.method
  let &foldexpr   = l:fold.expr
  let &foldtext   = l:fold.text
  unlet s:cache[l:key]
  " Let the caller know we did something.
  return 1
endfun


" Note: in order to call the above two functions automatically (as
" was originally intended), we'll need to do some augroup stuff.
" However, that gets very very tricky for things like this.  The
" following function was based on the long but extremely detailed
" description at <https://vi.stackexchange.com/a/13456>.
fun! wrengr#lsp#RegisterFolding()
  augroup lsp_folding
    autocmd! * <buffer>
    autocmd BufWinEnter <buffer> call wrengr#lsp#EnableFolding()
    autocmd BufWinLeave <buffer> call wrengr#lsp#DisableFolding()
  augroup END
  let l:cont = get(b:, 'undo_ftplugin', '')
  let b:undo_ftplugin = l:cont . (empty(l:cont) ? '' : ' | ')
    \ . ' call wrengr#lsp#DisableFolding()'
    \ . ' | execute ''autocmd! lsp_folding * <buffer>'''
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" WIP:
fun! wrengr#lsp#BufferEnabled() abort
  " Note: these two options are buffer-local only.
  " TODO: Do we actually want these two? (see `:h vim-lsp-omnifunc`)
  "setlocal omnifunc=lsp#complete
  " Specifies the function to be used to perform tag searches.
  " also see `:h vim-lsp-tagfunc` and g:lsp_tagfunc_source_methods
  "if has('patch-8.1.1228') && exists('+tagfunc')
  "  setlocal tagfunc=lsp#tagfunc
  "endif
  "
  " TODO: how exactly does the :LspDefinition<CR> version differ from
  "   the <plug>(lsp-definition) version?  See `:h vim-lsp-mappings`
  "   vs `:h vim-lsp-commands`; though that still doesn't explain really.
  "   Though for us at least, the <plug> versions aren't working (i.e.,
  "   they don't do anything afaict)
  "   TODO: remember that mapping to <plug> things are one of the
  "   few cases where we want recursive mapping; so was that the issue?
  " BUG: all too often we get "No definition found" even when it's
  "   defined in the same file!  Does it need to be fully-qualified
  "   at the use site or not type-dependent or something?
  " TODO: consider also/instead :LspPeekDefinition
  nnoremap <buffer> gd :LspDefinition<CR>
  " BUG: "Retrieving declaration not supported for filetype 'cpp'";
  "   despite this command existing precisely for languages like C/C++
  "   which distinguish declarations from definitions.
  " TODO: consider also/instead :LspPeekDeclaration
  nnoremap <buffer> gD :LspDeclaration<CR>
  " N.B., Vim has default mappings for `gd` (goto decl of local variable)
  " and `gD` (goto decl of global variable).  So our mappings above
  " are similar in spirit, though rather different in the details.
  " We may want to also take over the default mappings for `[i [I [d [D` etc
  nnoremap <buffer> gr :LspReferences<CR>
  " Other mappings suggested in the readme
  " TODO: decide which of these I'd like
  " Warning: mapping clashes; normally:
  "   `gs` => :sleep
  "   `gi` => a variant of `^i
  "   `gt` => :tabnext
  "map  <buffer> gs <plug>(lsp-document-symbol-search)    " :LspDocumentSymbol (shows not searches)
  "nmap <buffer> gS <plug>(lsp-workspace-symbol-search)   " :LspWorkspaceSymbol, :LspWorkspaceSymbolSearch
  "nmap <buffer> gi <plug>(lsp-implementation)            " :LspImplementation, :LspPeekImplementation; this is for 'implementations of interfaces' whatever that means...
  "nmap <buffer> gt <plug>(lsp-type-definition)           " :LspTypeDefinition, :LspPeekTypeDefinition
  "nmap <buffer> <leader>rn <plug>(lsp-rename)            " :LspRename
  "nmap <buffer> [g <plug>(lsp-previous-diagnostic)       " :LspPreviousDiagnostic
  "nmap <buffer> ]g <plug>(lsp-next-diagnostic)           " :LspNextDiagnostic
  "nmap <buffer> K  <plug>(lsp-hover)                     " :LspHover
  "
  " Scrolls the current displayed floating/popup window.
  "inoremap <buffer><expr> <C-f> lsp#scroll(+4)
  "inoremap <buffer><expr> <C-d> lsp#scroll(-4)
  "
  " BUG: since this function is only ever called depending on the
  " filetype, we really should be setting b:undo_ftplugin to revert
  " any options set above and unmap all the mappings above!  See
  " <https://vi.stackexchange.com/a/13456> for a bit more information
  " than the helppages offer about this.

  " See `:h vim-lsp-folding`.
  " TODO: add here some code to decide whether we want LSP-folding
  " for this buffer or not.  If so, then we should be able to just
  " call wrengr#lsp#RegisterFolding() and have it handle all the
  " difficult work of setting that up.

  " TODO: also see `:h vim-lsp-semantic`
endfun

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Clean Up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let &cpo = s:saved_cpo
unlet s:saved_cpo
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
