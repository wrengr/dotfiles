" I don't fully understand what the vim-default ftplugin does, but I do know
" I hate that three-part comment style.
setlocal comments&
setlocal comments=:--

" I also hate adding an indentation level every time I start a new
" line from within a comment. This function will ``set formatoptions-=c``,
" which disables that terrible "feature", in addition to disabling
" various other things I don't like.
DisableHardWrapping
