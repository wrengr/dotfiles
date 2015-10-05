" From <http://urchin.earth.li/~ian/style/vim.html>
" This will highlight all tab characters and trailing spaces
" For additional ideas, cf:
" <http://vim.wikia.com/wiki/Highlight_unwanted_spaces>

syn cluster hsRegions add=hsImport,hsLineComment,hsBlockComment,hsPragma
syn cluster hsRegions add=cPreCondit,cCppOut,cCppOut2,cCppSkip
syn cluster hsRegions add=cIncluded,cDefine,cPreProc,cComment,cCppString

syn match tab display "\t" containedin=@hsRegions
hi link tab Error
syn match trailingWhite display "[[:space:]]\+$" containedin=@hsRegions
hi link trailingWhite Error
