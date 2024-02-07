" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     colors/overmorrow.vim
" Modified: 2024-02-06T17:18:43-08:00
" Version:  2a
" Author:   wren romano
" Summary:  My own personal colorscheme.
" License:  This program is free software; you can redistribute it and/or
"           modify it under the terms of the GNU General Public License
"           as published by the Free Software Foundation; either version
"           2 of the License, or (at your option) any later version.
"           See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt>
"
" The particular palette of colors used here was originally inspired
" by Tomorrow-Night-Bright (hereafter abbreviated TNB); however, we've
" made various changes to that palette, and the actual code (per se)
" is entirely new.
"
" Version 2a: Added italics to the 'Comment' group.
" Version 2: Added preliminary support for &background=light
"   For now, I'm just copying the palette from
"   <https://github.com/NLKNguyen/papercolor-theme>
"   Though since that's not working out so well, might try copying
"   this one instead <https://github.com/sainnhe/everforest>
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" TODO: change this entirely, so as to use colors more like Conor McBride's schema
"   * terms/constants   = red
"   * types             = blue
"   * functions         = green
"   * variables         = magenta (both tyvars and tmvars)
"   * parens, forall, colon, "Type"/"*" = black (on white)
"   ...Maybe not everything exactly as such, but just vaguely along those lines.

" TODO: see <https://github.com/tweekmonster/helpful.vim> for when various features got added.

" TODO: see also <https://github.com/ajvondrak/vondark/wiki/Highlighting> for a guided tour of some various groups.

" TODO: also <https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f> for some nice thoughts on autocmd.


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Warning: cf., <https://stackoverflow.com/q/9967109>
" Apple's Terminal.app does some autoadjustment that can mess things up:
"   <https://apple.stackexchange.com/q/29487>
" You can get around that via:
"   <https://github.com/earwin/TruColor>
" iTerm2 is not susceptible to this particular problem.
" Also, in particular the Terminal.app problem apparently applies
" only to colors set via RGB, whereas HSB colors are left alone:
"   <https://apple.stackexchange.com/a/43679>


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Preamble ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Make things portable by ensuring `nocompatible`
" (Cf., `:h use-cpo-save` and `:h :set-&vim`)
" Note: it appears `:set cpo&vim` doesn't buggily re-enable modelines,
" the way `:set nocompatible` does.
let s:save_cpo = &cpo
set cpo&vim
" TODO: maybe make this finisher into an object, so that we can
"   incrementally add additional things to clean up.
" Warning: we cannot actually call `:finish` from inside a function;
" `:finish` can only be called from the top-level.  Also note that
" the existence of s:Finish() is a complete hack, since the existence
" of s:Die() is also a complete hack, both of which are trying to
" paper over issues of this file not parsing/compiling properly due
" to minor syntactic bugs.
fun! s:Finish()
  " In the event this function somehow gets called more than once,
  " guard against accessing an :unlet variable.
  if exists('s:save_cpo')
    let &cpo = s:save_cpo
    unlet s:save_cpo
  endif
endfun


" ~~~~~ Quick exit if colors aren't supported.
if !(&t_Co == 88 || &t_Co == 256
  \ || (has('termguicolors') && &termguicolors)
  \ || has('gui_running')
  \ || (has('nvim') && $NVIM_TUI_ENABLE_TRUE_COLOR))
  call s:Finish()
  finish
endif
" TODO: since we do a bunch of re-linking of busted syntax, maybe
"   we should aim to actually support non-color terminals too
"   (assuming they still has('syntax') etc).


" ~~~~~ Clear user-defined highlighting, and reload the defaults.
" NOTE: For colorschemes that can only support one &bg setting,
" they must `set bg=foo` *before* calling `:hi clear`.  Because the
" &bg variable is hooked so that changing it automagically reloads
" the color profile; thus, we'd want to get those side-effects out
" of the way prior to resetting things to the default.
"
" NOTE: Which default gets loaded depends on the current &background.
" As for what the default actually *is*... (since the only thing
" /usr/share/vim/vim80/colors/default.vim does is this same
" `:hi clear | syntax reset` dance, not actually setting anything),
" see <https://askubuntu.com/a/24548> and the comments below it.
" For dark backgrounds, the version of Vim in Fink looks to actually
" use 'elflord' not 'ron' (since the default Special has term=bold).
hi clear
if exists('syntax_on')
  syntax reset
endif
let g:colors_name='overmorrow'


" ~~~~~ User-configurable settings.
" When we want italic font, what should cterm do?
let g:overmorrow#cterm_italic = get(g:, 'overmorrow#cterm_italic', 'italic')
" When we want bold font, what should cterm do?
let g:overmorrow#cterm_bold = get(g:, 'overmorrow#cterm_bold', 'bold')

" BUG: Apparently our default xterm settings configure &t_ZH and
"   &t_ZR to send &t_mr and &t_me instead; so we need to reconfigure
"   that to actually send the ANSI codes for italics (since we've
"   set up iTerm2 to support it)

" TODO: also support for underline, undercurl, strike, standout
"
" Note to self: wtf is "standout"?  Apparently it's a totally
" nonstandard thing.  Terminfo will give the codes to start and stop
" it via `tput smso` and `tput rmso`, and Vim will internalize those
" as &t_so and &t_se.  According to the terminfo manpage, "standout"
" mode is supposed to be a configurable thing that you set to be
" whatever you think stands out, for use by errors etc.  GNU Screen
" steals the ANSI escape codes for italics and repurposes them to
" mean standout.  Apparently rxvt treats standout as bold.  Whereas
" for vim, if terminfo doesn't have codes for standout then vim'll
" automatically use reverse/inverse mode instead (&t_mr); and vice
" versa if there's no reverse mode! So, notably, CSApprox doesn't
" even bother trying to support standout mode.
"
" Of related note:
" <https://newbedev.com/make-less-highlight-search-patterns-instead-of-italicizing-them>


" For the standard :hi stylings, here are Vim's termcap variable names:
"
"           Start   Stop    ANSI#
" Bold      t_md    (t_me)  1 (though many interpret as Bright/Intense color)
" Italics   t_ZH    t_ZR    3 (though some(many?) interpret as Reverse)
" Reverse   t_mr    (t_me)  7
" Standout  t_so    t_se    -- (Basically the same as Reverse)
" Underline t_us    t_ue    4
" Undercurl t_Cs    t_Ce    -- (non-standard termcap names)
" Strike    t_Ts    t_Te    9 (ANSI: not widely supported) (non-standard termcap names)
"
" ...And re setting colors beware the three different:
"                   FG      BG      SP/UL
" ANSI              t_AF    t_AB    t_AU
" (???)             t_Sf    t_Sb
" xterm-true-color  t_8f    t_8b    t_8u


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Our Hex (GUI) colors
" Most of the dark color *palette* came from TNB; however, most of
" the color *scheme* in the rest of the file did not.
"
" The cterm values are cached from autoload/naivecolor.  If we
" change the hex codes (or the color-space mapping) then these'll
" have to all be redone.  The "%grey" comments are just for reference,
" and are based on the hexstrings.
" TODO: cache the cterm88 values too.
" TODO: really we ought to just give the hex colors and actually
"   call the autoload functions.  We'd have to pay the cost for
"   computing them the once, but we'd still cache them to avoid the
"   overhead of recomputing them all the time like TNB does.
" FIXME: I've changed autoload/naivecolor, so we need to recache the values.
"   (Or nudge the GUI colors until they agree.)

" Note To Self: you can use the command `:put a` to insert the
" contents of register @a into the file just below the cursor.  This
" only works with registers, not strings or other expressions like
" `:echo` can handle.

" N.B., the #{} syntax for dicts (to avoid needing to quote the
"   keys) requires some version above the 8.0 I have installed.


" ~~~~~ All the 256-palette greys (for quick reference)
" (More particularly, their level rephrased as a percentage.)
" TODO: move this off to another file. Especially the ones we don't use.
"   255 = #eeeeee (93.33%)
"   254 = #e4e4e4 (89.41%)                          s:fg
"   253 = #dadada (85.49%)
"   252 = #d0d0d0 (81.56%)
"   251 = #c6c6c6 (77.64%)
"   250 = #bcbcbc (73.72%)
"   249 = #b2b2b2 (69.80%)
"   248 = #a8a8a8 (65.88%)
"   247 = #9e9e9e (61.96%)
"   246 = #949494 (58.03%)
"   245 = #8a8a8a (54.11%)                          ~s:comment
"   244 = #808080 (50.19%)
"   243 = #767676 (46.27%)
"   242 = #6c6c6c (42.35%)
"   241 = #626262 (38.43%)
"   240 = #585858 (34.50%)
"   239 = #4e4e4e (30.58%)                          s:AbsoluteLineNr
"   238 = #444444 (26.66%)
"   237 = #3a3a3a (22.75%)                          s:selection
"   236 = #303030 (18.82%)
"   235 = #262626 (14.90%)
"   234 = #1c1c1c (10.98%)  See bug note below.     s:CursorLine
"   233 = #121212 ( 7.05%)
"   232 = #080808 ( 3.13%)


" BUG: (2014) See <https://groups.google.com/forum/#!msg/vim_dev/afPqwAFNdrU/nqh6tOM87QUJ>
"   Apparently to use ctermbg=234 we need to move the `set bg=dark`
"   to the very end of the file??!  Has something to do with the
"   hidden automagical way that setting `hi Normal` can change the
"   &bg out from under you.  If it's specific to 234, then only
"   s:CursorLine seems affected; though from the sound of it it's
"   supposedly anything other than system colors 7 and 8 (and yet it
"   doesn't bite us...)


" ~~~~~ Specific shades of named colors.
"   Note to self, the mnemonics for system colors are (in order): KRGYBMCW
"   NOTE: You cannot use EOL comments in the middle of a multiline command!
"
" FIXME(wrengr): Now that we've adjusted the infrastructure to
" handle &bg='light', we need to actually change the color palate
" to look decent for light backgrounds!
let s:black =
            \ {'dark':  {'hex':'000000', 'cterm256':16}
            \ ,'light': {'hex':'000000', 'cterm256':16}}
let s:white =
            \ {'dark':  {'hex':'ffffff', 'cterm256':231}
            \ ,'light': {'hex':'eeeeee', 'cterm256':255}}
let s:red =
            \ {'dark':  {'hex':'d54e53', 'cterm256':167}
            \ ,'light': {'hex':'af0000', 'cterm256':124}}
            " TODO: d54e53 -> 167; 167 -> d75f5f
let s:orange =
            \ {'dark':  {'hex':'e78c45', 'cterm256':172}
            \ ,'light': {'hex':'d75f00', 'cterm256':166}}
            " TODO: e78c45 -> 173; 172 -> d78700
let s:yellow =
            \ {'dark':  {'hex':'e7c547', 'cterm256':184}
            \ ,'light': {'hex':'e7c547', 'cterm256':184}}
            " TODO: e7c547 -> 185; 184 -> d7d700
            " FIXME: papercolor doesn't have any equivalent of yellow for light!
let s:green =
            \ {'dark':  {'hex':'b9ca4a', 'cterm256':148}
            \ ,'light': {'hex':'008700', 'cterm256':28}}
            " TODO: b9ca4a -> 149; 148 -> afd700
            " FIXME: papercolor's green looks really washed out against the s:bg
" s:cyan was called s:aqua in TNB.
let s:cyan =
            \ {'dark':  {'hex':'70c0b1', 'cterm256':73}
            \ ,'light': {'hex':'0087af', 'cterm256':31}}
            " TODO: 70c0b1 ->  73;  73 -> 5fafaf
let s:blue =
            \ {'dark':  {'hex':'7aa6da', 'cterm256':110}
            \ ,'light': {'hex':'005faf', 'cterm256':25}}
            " TODO: 7aa6da -> 110; 110 -> 87afd7
let s:lavender =
            \ {'dark':  {'hex':'c397d8', 'cterm256':176}
            \ ,'light': {'hex':'d70087', 'cterm256':162}}
            " TODO: c397d8 -> 176; 176 -> d787d7
            " FIXME: this is actually a lot closer to magenta, since papercolor has no lavender.
let s:violet =
            \ {'dark':  {'hex':'870087', 'cterm256':90}
            \ ,'light': {'hex':'8700af', 'cterm256':91}}
" TODO: come up with a decent 'magenta' (system 5,13) color that
" goes with the rest of the above palette; especially such that it
" meshes well with s:lavender without causing it to washout to pink.
" Fwiw, the default elflord colorscheme uses 'ctermfg=DarkMagenta'
" for Special, etc.  According to CSApprox, 'darkmagenta' can be
" either:
" * if relying on (gui_x11.c,gui_gtk_x11.c)    ==> #bb00bb (-> 127 <-> af00af)
" * if using the `showrgb` commandline program ==> #8b008b (->  90 <-> 870087)
"   at least according to the version of `showrgb` I have installed.
" Some other `showrgb` colors that might we worth trying:
"   'DeepPink3' = cd1076 -> 162 -> d70087
"       this is a lot more actual magenta; though probably doesn't
"       mesh well, or causes poor visibility.
let s:sienna =
            \ {'dark':  {'hex': 'a0522d', 'cterm256':130}
            \ ,'light': {'hex': 'a0522d', 'cterm256':130}}
    " 130 <-> af5f00; alas it was the a0522d that really drew me.
    " This is really pretty, but doesn't necessarily mesh well with
    " the other colors.
            " FIXME: papercolor doesn't have any equivalent of sienna

" ~~~~~ Semantically named color choices.
let s:fg =
            \ {'dark':  {'hex':'e4e4e4', 'cterm256':254}
            \ ,'light': {'hex':'005f87', 'cterm256':24}}
            " dark  = 89.41% ; TNB was #eaeaea (91.76%)
            " FIXME: I'm using papercolor's 'cursor_bg' here
let s:bg =
            \ {'dark':  {'hex':'000000', 'cterm256':16}
            \ ,'light': {'hex':'eeeeee', 'cterm256':255}}
            " light = 93.33%
            " FIXME: I'm using papercolor's 'cursor_fg' here; it's certainly better  than using true-white, but it's making everything look really washed out (on my laptop's LED screen that is)
            " TODO: Consider using LemonChiffon3(cdc9a5) a la CarlRJ's comment on <https://www.reddit.com/r/vim/comments/xmag1j/light_mode_color_scheme_recs/>; also consider writing up some scripts to do the random background thing he mentions there.
let s:selection =
            \ {'dark':  {'hex':'424242', 'cterm256':237}
            \ ,'light': {'hex':'d0d0d0', 'cterm256':252}}
            " dark  = 25.88% ; TODO: 424242 -> 238 == 444444 (26.66%); 237 == 3a3a3a (22.75%)
            " NOTE: I'm  using  papercolor's popupmenu_bg here; though we use  this color in several places not quite matching their scheme.  Also, they have a different popup_fg rather than reusing the usual fg.
let s:comment =
            \ {'dark':  {'hex':'969896', 'cterm256':245}
            \ ,'light': {'hex':'3a3a3a', 'cterm256':237}}
            " dark  ~ 58.82% ; TODO: 969896 -> 246 == 949494 (58.03%); 245 == 8a8a8a (54.11%)
            " FIXME: This doesn't line up to anything in papercolor
let s:window =
            \ {'dark':  {'hex':'4d5057', 'cterm256':59}
            \ ,'light': {'hex':'005f87', 'cterm256':24}}
            " TODO: 4d5057 -> 59; 59 -> 5f5f5f -> 241 == 626262
            " NOTE: We only really use this for VertSplit; which papercolor gives a different fg/bg to...
" TODO: do we want to use the so-called 'SlateGrey'=#708090 anywhere?
" TODO: figure out something better to do with s:preproc.
"   s:violet is too dark for this
"             101 -> 87875f
"   8b6914 ->  94 -> 875f00
"   bcd2ee -> 153 -> afd7ff: no, is too bright.
"   cdc1c5 -> 182 -> d7afd7: also too bright
"   36648b ->  60 -> 5f5f87: that'll work for now
" BUG: this value of s:preproc may be acceptable for SpecialComment
"   (i.e., haskell pragmas); but it's not at all acceptable for other
"   forms of PreProc
let s:preproc =
            \ {'dark':  {'hex':'5f5f87', 'cterm256':60}
            \ ,'light': {'hex':'5f5f87', 'cterm256':60}}

" ~~~~~ Group-specific colors.
let s:CursorLine =
            \ {'dark':  {'hex':'1c1c1c', 'cterm256':234}
            \ ,'light': {'hex':'eeeeee', 'cterm256':255}}
            " dark  = 10.98% ; TNB was #2a2a2a (16.47%)
let s:AbsoluteLineNr =
            \ {'dark':  {'hex':'4e4e4e', 'cterm256':239}
            \ ,'light': {'hex':'4e4e4e', 'cterm256':239}}
            " 30.58% ; TNB was 237 (22.75%)
let s:RelativeLineNr = s:violet
" A pleasant but high-contrast color:
" N.B., the version for &bg=dark is very close to s:orange, but
" definitely not interchangeable.
let s:ColorColumn =
            \ {'dark':  {'hex':'e5786d', 'cterm256':173}
            \ ,'light': {'hex':'e5786d', 'cterm256':173}}
            " TODO: e5786d -> 173; 173 -> d7875f

" TODO: I also rather like airline's (default?) fg/bg pairing:
" 	ctermfg=85 ctermbg=234 guifg=#9cffd3 guibg=#202020
" and their bold counterparts.

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Colors used by Hackage for highlighting code, which seems rather pleasant:
"let s:bg               = 'fdf6e3'  " light background, but not garish white
"let s:identifier       = '073642'
"let s:TypeIdentifier   = '5f5faf'
" Alas, seems to suffer from the same 'identifiers in type-sigs'
" vs 'identifiers in definitions' issue as my current Haskell syntax
" plugin.
"let s:keyword          = 'af005f'
"let s:string           = 'cb4b16'
"let s:char             = s:string
"let s:number           = '268bd2'
"let s:operator         = 'd33682'  " any infix op, including backticks
"let s:glyph            = 'dc322f'  " :: => -> (type-level) =
"let s:special          = s:glyph   " context parens, commas, brackets
"let s:comment          = { hex: '8a8a8a', cterm256: 245, grey: 54.11% }
"let s:pragma           = '2aa198'
"let s:cpp              = '859900'
"
"" They use this for the sp-color of links, or the bg-color when hovering.
"let s:underline        = 'eee8d5'
"" I'm not entirely sure what their 'annot' and 'annottext' spans are for, but...
"" Hmm, I think they're for rollovers at use sites, to show their types
"" only for the background and when hovering, fg=000000
"let s:annot_bg         = 'ffffaa'
"let s:annot_hover_bg   = 'ffff00'
"let s:annot_sp         = 'ffad33' " actually border rather than underline...




" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" If anything goes wrong, we call this function rather than :throw,
" because if we :throw then that'll crash the caller's file with some
" inscrutable syntax error (unlike Vim's internal errors which merely
" abort this file, as expected).
fun! s:Die(where, msg)
  let l:msg = 'ERROR(overmorrow#' . a:where . '): ' . a:msg
  echohl ErrorMsg
  echomsg l:msg
  echohl NONE
  " Cf., wrengr#s:error()
  let v:errmsg = l:msg
  " HACK: we can't actually call :finish from within a function;
  "   Vim won't complain so long as this function is never called,
  "   but that's still a problem.  Of course, we can't really
  "   push this out to the callers either, since they too are
  "   within functions!  So it looks like maybe the only way
  "   really is to :throw.  I suppose we could always wrap the
  "   entire section where we call s:HiLink() with a :try:catch,
  "   but ugh...  And if we can't :finish then we really shouldn't
  "   call s:Finish() yet either.
  call s:Finish()
  finish
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" N.B., On newer versions of vim you can use v:t_list in lieu of
" type([]), and similar for the others.  But even Luc Hermitte
" sticks with type([]) for portability reasons; and so shall we.
" <https://vi.stackexchange.com/a/25106>
let s:t_string = type('')
let s:t_list = type([])
let s:t_dict = type({})


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Map our desired attributes to the actual stylization to use.
" BUG: there are times where having term=bold does bizarre things
"   even though we're on &t_Co=256.  For now I'm just clearing out
"   that style, but we really should figure out what's going on and
"   fix it.
" TODO: need to do some validating of global config variables,
"   before actually using them.
" TODO: see how CSApprox handles their variation on this idea.
"   Apparently some terminals will interpret reverse mode as reversing
"   the default fg/bg rather than reversing the current fg/bg!  So,
"   like them, I'm just going to manually swap the fg/bg wherever I can.
let s:attrStyles =
  \ { 'gui':
  \   { 'bold':      'bold'
  \   , 'italic':    'italic'
  \   , 'reverse':   'reverse'
  \   , 'standout':  'standout'
  \   , 'strike':    'strike'
  \   , 'undercurl': 'undercurl'
  \   , 'underline': 'underline'
  \   }
  \ , 'cterm':
  \   { 'bold':      g:overmorrow#cterm_bold
  \   , 'italic':    g:overmorrow#cterm_italic
  \   , 'reverse':   'reverse'
  \   , 'standout':  'standout'
  \   , 'strike':    'strike'
  \   , 'undercurl': 'undercurl'
  \   , 'underline': 'underline'
  \   }
  \ , 'term':
  \   { 'bold':      ''
  \   , 'italic':    ''
  \   , 'reverse':   'reverse'
  \   , 'standout':  'standout'
  \   , 'strike':    ''
  \   , 'undercurl': 'underline'
  \   , 'underline': 'underline'
  \   }
  \ }

let s:validAttrs =
  \ { 'bold':      1
  \ , 'italic':    1
  \ , 'reverse':   1
  \ , 'standout':  1
  \ , 'strike':    1
  \ , 'undercurl': 1
  \ , 'underline': 1
  \ }

" TODO: support inheriting as well as overriding.
fun! s:getAttrs(attrs, tg) abort
  let l:t_attrs = type(a:attrs)
  if l:t_attrs == s:t_string
    " Note: vim-8.2 has that strings are lists of characters, whereas
    " vim-8.0 does not.  Thus, without this automatic promotion we
    " would get different errors on the different versions (either
    " 'expected list' or 'unknown attr').
    let l:attrs = [a:attrs]
  elseif l:t_attrs == s:t_list
    let l:attrs = a:attrs
  else
    call s:Die('s:getAttrs', 'Expected list but got: ' . l:t_attrs)
  endif
  unlet l:t_attrs
  "
  let l:strings = []
  let l:styles  = s:attrStyles[a:tg]
  for l:attr in l:attrs
    if !has_key(s:validAttrs, l:attr)
      call s:Die('s:getAttrs', 'Unknown attr: ' . l:attr)
    endif
    let l:str = l:styles[l:attr]
    if !empty(l:str)
      call add(l:strings, l:str)
    endif
    unlet l:str
  endfor
  return join(uniq(sort(l:strings)), ',')
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Auto-promote the type of the last argument of s:Hi() to
" what it expects.  In principle I'm against this sort of thing,
" but in this case I'll bend because errors in this file can be
" catastrophic for the user's ~/.vimrc.  Type errors generated
" by Vim itself are fine for ~/.vimrc, but they give too little
" location information to track down the problem.  Whereas if we
" do our own type checking and then :throw, we'll get good location
" info but it'll crash the parsing of ~/.vimrc which is unacceptable.
fun! s:TypecastAttrs(attrs)
  " We're only wrapping not mutating, so don't deepcopy().
  let l:new = a:attrs
  if type(l:new) == s:t_string
    " N.B., empty string is handled fine by s:getAttrs().
    let l:new = [l:new]
  endif
  if type(l:new) == s:t_list
    let l:new = {'gui': l:new,  'cterm': l:new, 'term': l:new}
  endif
  if type(l:new) == s:t_dict
    return l:new
  else
    call s:Die('s:TypecastAttrs', 'cannot typecast: ' . type(a:attrs))
  endif
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" TODO: If :hi doesn't show any attrs, does that mean it'll inherit
"   from synstack (or links), or that it'll clear anything inherited
"   from synstack (or links)?
"
" TODO: also mentioned from
" <https://www.reddit.com/r/neovim/comments/50ymp4/does_anybody_else_think_that_usingwriting_neovim/>,
" see <https://gist.github.com/anonymous/8e77d052b35ecb569d80b01a977123dd>
" for papering over vim vs neovim differences.
"
" N.B., we do not allow Vim's magical color names 'fg' and 'bg';
" however do beware that they behave differently for gui{fg,bg}
" vs cterm{fg,bg}.
" ~~~~~


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Cache the choice of which cterm key to use for ColorDicts.
if &t_Co == 88
  let s:ctermColor = 'cterm88'
elseif &t_Co == 256
  let s:ctermColor = 'cterm256'
else
  " BUG: really shouldn't die if &termguicolors
  call s:Die('s:ctermColor', 'unsupported cterm palette: t_Co=' . &t_Co)
endif

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Set highlight colorization.
" TODO: see 'dtinth/vim-colors-dtinth256' for some inspiration on
"   alternative ways to call this function via :command shenanigans.
"   (also lots of other clever hackery.)
" TODO: make the last two (or even three!) arguments optional.
fun! s:Hi(group, fg, bg, sp, attrs) abort
  " HACK: assume all the necessary keys exist, and crash if
  " they don't.  Since we're not explicitly throwing any
  " exceptions, then any type errors should just cause this
  " file to crash, rather than causing the user's ~/.vimrc to
  " crash too.
  let l:hi = ''
  if !empty(a:fg)
    let l:hi .= ' guifg=#'  . a:fg[&bg]['hex']
    let l:hi .= ' ctermfg=' . a:fg[&bg][s:ctermColor]
  endif
  if !empty(a:bg)
    " TODO: support NONE for gvim & neovim's transparent
    "   backgrounds.  But cf., <https://vi.stackexchange.com/a/3061>
    "   (according to `:h highlight-guibg`, Vim supports NONE for transparency too)
    let l:hi .= ' guibg=#'  . a:bg[&bg]['hex']
    let l:hi .= ' ctermbg=' . a:bg[&bg][s:ctermColor]
  endif
  " TODO: might should check that we actually have undercurl etc
  "   after rewriting a:attrs.
  if !empty(a:sp)
    " GVim uses guisp as the color for undercurl and strikethrough;
    " though I think it should also apply to underline.
    "
    " Neovim also interprets guisp to apply to color terminals,
    " if they support setting the underline/undercurl color:
    " <https://stackoverflow.com/a/66816085>.
    " (I'm unsure if that requires &termguicolors or not)
    let l:hi .= ' guisp=#' . a:sp[&bg]['hex']
    " Very new versions of Vim add ctermul for color terminals
    " that support setting the underline/undercurl color:
    " <https://stackoverflow.com/a/27859297>
    " For older Vim, cf: <https://github.com/vim/vim/issues/819>
    if has('patch-8.2.0863')
      " Per `:h has-patch` that new version+patch syntax was
      " added in 7.4.237 so we're fine to use it here.
      " TODO: should we add an additional has() for ctermul itself?
      let l:hi .= ' ctermul=' . a:sp[&bg][s:ctermColor]
    endif
  endif
  "
  " FIXME: beware of the discrepancies between vim proper and
  "   neovim when using &termguicolors; namely that one uses
  "   cterm= for styling whereas the other uses gui=
  "   <https://www.reddit.com/r/neovim/comments/50ymp4/does_anybody_else_think_that_usingwriting_neovim/>
  let l:attrs = s:TypecastAttrs(a:attrs)
  for l:tg in ['gui', 'cterm', 'term']
    if has_key(l:attrs, l:tg)
      let l:str = s:getAttrs(l:attrs[l:tg], l:tg)
      if !empty(l:str)
        let l:hi .= ' ' . l:tg . '=' . l:str
      endif
      unlet l:str
    endif
  endfor
  " Explicitly remove any previous links.
  execute 'hi! link ' . a:group . ' NONE'
  " Explicitly remove all styling (i.e., inherited from default).
  execute 'hi ' . a:group . ' NONE'
  " Finally, set our own styling (if any).
  if !empty(l:hi)
    execute 'hi ' . a:group . ' ' . l:hi
  endif
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" The full syntax for linking is `hi[!] [default] link SRC DEST`.
" Afaict, the meaning of this is:
" Without !,            if SRC has non-default styling, then do nothing.
" With    !,            always link; overriding SRC styling.
" Without 'default',    subsequent `hi SRC` must use ! to override.
" With    'default',    subsequent `hi SRC` doesn't need ! to override.
" Though the situation with 'default' is rather unclear.  For
" more info, see the helpfiles for `:hi-link` and `:hi-default`
" Also <https://vi.stackexchange.com/a/28363> re patches 8.2.1693 8.2.1703
fun! s:HiLink(src, dst)
  " First remove any previous `:hi Src ...` settings.
  " We use the `:hi Src NONE` form rather than the equivalent
  " `:hi clear Src` form to make it clearer that this removes
  " prior styling rather than resetting it back to default
  " (unlike argument-less `:hi clear`). N.B., this does not
  " remove any previous `:hi link Src ...` setting however.
  " Also, n.b., there is no bang version of this command.
  " Also, n.b., newer versions of Vim keep the old styling
  " around in a hidden way so that it can be recovered if
  " desired; so we may need to explicitly set it to something
  " to avoid that.
  execute 'hi ' . a:src . ' NONE'
  " Now set up the actual link.  N.B., this alone does not
  " remove any prior `:hi Src ...` settings.  Also, n.b., if
  " a:dst happens to be NONE then that will delete any previous
  " link (which is fine because we trust ourselves about that).
  execute 'hi! link ' . a:src . ' ' . a:dst
endfun

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Only introduce the link if the a:src group already exists.
" N.B., that doesn't mean it has *highlight* stylization; it
" may just exist because it was defined by `:syntax keyword` or
" similar.  (See `:h syn-keyword`)
" TODO: verify this works as expected in the handful of callsites.
fun! s:HiLinkIfExists(src, dst)
  if hlexists(a:src)
    call s:HiLink(a:src, a:dst)
  endif
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Core editor usage
"
" Note: to look up what any specific group is used for, see `:h hl-Group`.
"   That particular help tag is typically more informative than
"   others.  Though you may also want to see `:h 'highlight'`.
" TODO: See if there are any term= settings we would like to recover
"   from the defaults.

" ~~~~~ Maintext region (except lines/columns) ~~~~~~~~~~~~~~~~~
" N.B., for buggy reasons, one must set Normal before anything else
" (cf., `:h hi-normal-cterm`)
call s:Hi('Normal',     s:fg,       s:bg,       s:fg, {})
" TODO: despite the name, we may want to set these to use s:AbsoluteLineNr
"   to make them a little more visible than they are now.
call s:Hi('NonText',    s:selection,{},         {}, {}) " for &showbreak etc
call s:Hi('SpecialKey', s:selection,{},         {}, {}) " for &listchars
" HACK: While this is cleared by default on mayari's default
" colorscheme, it's not cleared on my ciruela's default colorscheme.
" Thus, we explicitly clear it out.
" BUG: on ciruela, someone is setting Conceal to ctermfg=7 ctermbg=242 guifg=LightGrey guibg=DarkGrey, but :verbose blames us!!
call s:HiLink('Conceal', 'NONE')
" Note: for the original intended purpose of concealment, we may
" be inclined to treat it like 'Ignore'; but that is incorrect.
" Moreover, it is extremely common for folks to use the conceal
" feature in order to display unicode renditions of ASCII symbols
" stored in the file; and for that purpose, if we have any stylization
" here then that'll only expose the lie (since this group applies to
" all the characters displayed via the conceal feature/mechanism);
" cf., <https://vi.stackexchange.com/q/25956>.  Of course, we may
" need to try explicitly using 'none' for the fg and bg colors, as
" per the accepted answer there.
" TODO: see also <https://vi.stackexchange.com/q/5533>

" ~~~~~ Searching, Selecting, Matching.
" TODO: the reverse is rather jarring when the fg is s:fg.
call s:Hi('Search',     {},         {},         {}, 'reverse')  " for &hlsearch
call s:HiLink('IncSearch', 'Search')                            " for &incsearch
call s:Hi('Visual',     {},         s:selection,{}, {}) " the visual-mode selection
" VisualNOS only for |gui-x11| and |xterm-clipboard|
" HACK: this'll have to do for now.  Whenever the paren has color,
" using 'reverse' looks quite nice; but whenever the paren is s:fg
" then the reverse is too jarring.  I tried a few other things but
" none of them seemed to be sufficiently noticable and yet also
" sufficiently subtle.  Another issue I kept running into with
" (s:fg,s:bg) is that it was all too easy to loose track of which
" paren was the one I was on.
call s:Hi('MatchParen', s:selection, s:ColorColumn, {}, 'bold')

" ~~~~~ Insert-completion (`:h popupmenu-completion`)
if v:version >= 700
  call s:Hi('PMenu',    s:fg,       s:selection,{}, {})
  call s:Hi('PMenuSel', s:selection,s:fg,       {}, {})
  " PmenuSbar      xxx ctermbg=248 guibg=Grey
  " PmenuThumb     xxx ctermbg=15  guibg=White
endif


" ~~~~~ Cmdline region ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
call s:Hi('ModeMsg',    s:green,    {},         {}, {}) " for &showmode
call s:Hi('MoreMsg',    s:green,    {},         {}, {}) " for *more-prompt*
call s:Hi('Question',   s:green,    {},         {}, {}) " for *hit-enter* prompt
" QuickFixLine -> Search                                " current *quickfix* item
call s:Hi('WarningMsg', s:red,      {},         {}, {})
call s:Hi('ErrorMsg',   s:white,    s:red,      {}, {'term': ['standout']})

" ~~~~~ Cmdline-completion (`:h cmdline-completion`)
" N.B., WildMenu is used for the current/selected menu item; and
" though it's not mentioned anywhere anywhere in the helppages,
" StatusLine is used for the rest of the menu: <https://superuser.com/a/495546>
" (maybe also check out: <https://vi.stackexchange.com/q/2590>)
call s:Hi('WildMenu',   s:bg,       s:orange,   {}, 'bold')
" Directory only applies to directories via &wildmode=list, not to
" directories via &wildmode=full.  (Though netrwDir also links to it.)
call s:Hi('Directory',  s:blue,     {},         {}, {})


" ~~~~~ Lines and columns ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
call s:Hi('VertSplit',  s:window,   s:window,   {}, {})
" ~~~~~ StatusLine (cf., &laststatus, &statusline, *status-line*)
" StatusLine has two uses:
" * the current/active window's statusline
"     (but only if not using airline &c.)
" * non-selected items in the wildmenu
" Since we use airline, we set this based on the needs of wildmenu.
call s:Hi('StatusLine', s:comment,  s:selection,{}, {})
" This is only used for non-current windows' statuslines; again,
" only if not using airline &c.  Nevertheless, we set this to the
" same thing we('ll) have airline use for non-current windows too.
call s:Hi('StatusLineNC', s:selection, s:CursorLine, {}, {})
" StatusLineTerm/StatusLineTermNC like above but for terminal windows
" (cf., `:h hl-...`).  Don't know if I need to bother setting them
" since I'm using airline.
" TODO: see also 'Terminal', mentioned at `:h hl-Terminal` though
" the group hasn't been created for us yet.
" N.B., statusline also has User1, User2,...User9
" ~~~~~ TabLine
" TODO: could use tweaking, but okay for now.  Matches airline_{b,c}
call s:Hi('TabLine',    s:fg,       s:CursorLine,   {}, {})     " inactive tabs
call s:Hi('TabLineSel', s:fg,       s:selection,    {}, 'bold') " the active tab
cal s:HiLink('TabLineFill', 'TabLine')                          " empty filler
" ~~~~~ Toolbar (GUI-only afaict)
" TODO: where did I hear about these from?
" ToolbarLine    xxx term=underline ctermbg=242 guibg=Grey50
" ToolbarButton  xxx cterm=bold ctermfg=0 ctermbg=7 gui=bold guifg=Black guibg=LightGrey
" ~~~~~
if has('signs')
  " N.B., some users were forced to use `au VimEnter *` to fix
  " the ugliness of gitgutter's new SignColumn; which'll override
  " these settings as well (which themselves fix gitgutter too).
  "   <https://news.ycombinator.com/item?id=5326353>
  " Looking at the code (githash=549fb96; 6 Aug 2021): when loaded,
  " gitgutter will read the then-current ctermbg/guibg of SignColumn
  " and copypasta it when defining their own highlighting.  Alas,
  " because of the copypasta, there's no way to easily fix this
  " after the fact.
  "
  " TODO: or prolly better is to link to LineNr?
  call s:HiLink('SignColumn', 'Normal')
endif
if v:version >= 703 && exists('+colorcolumn')
  " fg is brighter than s:fg, because of the bright s:ColorColumn
  " TODO: is this case of term=bold okay/safe?
  call s:Hi('ColorColumn',  s:white, s:ColorColumn, {}, 'bold')
endif
if has('folding')
  call s:Hi('Folded',       s:comment,  s:bg,       {}, {})
  " TODO: guard has('foldcolumn') ??
  call s:HiLink('FoldColumn', 'Normal') " TNB had fg unset here.
endif
if v:version >= 700 && exists('+cursorline') && exists('+cursorcolumn')
  " HACK: like '+colorcolumn' we need to use exists('+') rather than has(); weird.
  call s:Hi('CursorLine',   {},         s:CursorLine,{}, {})
  call s:HiLink('CursorColumn', 'CursorLine')
  "
  " For `:h popupmenu-completion`
  call s:Hi('PMenu',        s:fg,       s:selection,{}, {})
  call s:Hi('PMenuSel',     s:selection,s:fg,       {}, {})
  " PmenuSbar      xxx ctermbg=248 guibg=Grey
  " PmenuThumb     xxx ctermbg=15  guibg=White
endif


" ~~~~~ Misc. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" GUI only: Menu, Scrollbar, Tooltip.


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Line Numbers
" TODO: what are the appropriate guards?
" TODO: should we move our ~/.vimrc's toggling function here too?
"
" CursorLineNr is same as TNB.
" BUG(2021.08.08): on Mayari (OSX 10.14.6; iTerm2 Build 3.4.9beta1)
"   this needs to use cterm=bold rather than term=bold.  Presumably
"   due to the idiosyncracies of using bold font per se vs the
"   historic trick of using the bright colors to simulate bold.
"   (2021.09.01): though setting them both seems to be okay, now
"   that I've disabled iTerm's make-bright-if-bold feature.
call s:Hi('CursorLineNr', s:yellow, s:bg, {}, 'bold')

" We introduce our own groups so that users can script changing
" the real LineNr to link to whichever.
"
" N.B., we've changed OvermorrowAbsoluteLineNr relative to TNB's
" LineNr, because ctermfg=237 is a bit too dark on my machine.
call s:Hi('AbsoluteLineNr', s:AbsoluteLineNr, s:bg, {}, {})
call s:Hi('RelativeLineNr', s:RelativeLineNr, s:bg, {}, {})
" N.B., we don't use the s:HiLink functions because they cause
" some sort of function-not-found errors.  I'm not quite sure if
" that's because of the <SID> stuff, or if it's because of the former
" :delf at the end of the file; but either way, it's simple enough
" to just inline that function here.
fun! OvermorrowRelinkLineNr()
  if &relativenumber
    hi LineNr NONE
    hi! link LineNr RelativeLineNr
  else
    hi LineNr NONE
    hi! link LineNr AbsoluteLineNr
  endif
endfun
call OvermorrowRelinkLineNr()


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Spelling
if v:version > 700 && has('spell')
  " BUGFIX: need to change these from their defaults and from
  "   what TNB uses, because while they look tolerable enough on
  "   my personal machine, they look terrible on my work machines.
  " TODO: apparently the bug has to do with `cterm=bold` being
  "   interpreted to turn the text grey rather than keeping the
  "   black... i.e., to use the "bright" 4-bit system colors,
  "   rather than using a true bold font.
  let s:GuiUC = {'gui': ['undercurl']}
  " TODO: really we should probably have the GUI be entirely different...
  call s:Hi('SpellBad',  s:black, s:red,     s:black, s:GuiUC)
  call s:Hi('SpellCap',  s:black, s:blue,    s:black, s:GuiUC)
  call s:Hi('SpellLocal',s:black, s:cyan,    s:black, s:GuiUC)
  call s:Hi('SpellRare', s:black, s:violet,  s:black, s:GuiUC)
  unlet s:GuiUC
endif


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Diff Highlighting (both builtin, and Plug 'airblade/vim-gitgutter')
" TODO: should we guard for has('signs')?
" BUG: our usual colors really don't work for this!  The green is
"   too pale/yellow, the orange or lavender is too close to the
"   red, the red is too dull, etc.  So what looks good?  Should
"   we just go with system colors?
call s:Hi('DiffAdd',    s:green,   s:bg, {}, {})
call s:Hi('DiffChange', s:cyan,    s:bg, {}, {})
call s:Hi('DiffDelete', s:red,     s:bg, {}, {})
" DiffText is used for 'Changed text within a changed line'; cf., `:h diff.txt`
call s:HiLink('DiffText', 'Normal')

" Note: If undefined at the time it's loaded, gitgutter will manually
" copy(!!) things from the GitGutter* variants into these diff*
" variants.  (Whereas the GitGutter* variants properly link to vim's
" builtin Diff* variants.)  So, it's better we set them now just to
" avoid dealing with even more copypasta.
call s:HiLink('diffAdded',   'DiffAdd')
call s:HiLink('diffChanged', 'DiffChange')
call s:HiLink('diffRemoved', 'DiffDelete')


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~ Help (/usr/share/vim/vim80/syntax/help.vim)
" TODO: change anything from the defaults?
" Type       <- helpOption          : anything in singlequotes.
" Todo       <- helpNote            : any "Note:" at the beginning of a paragraph
" Identifier <- helpHyperTextJump   : anything in (invisible)pipes.
" Ignore     <- helpBar             : the invisible pipes themselves.
" PreProc    <- helpHeader          : Header for inline tabulars.
" Statement  <- helpHeadline        : The left justified labels for sections.
" String     <- helpHyperTextEntry  : The right justified labels for entries.
" Comment    <- helpCommand         : anything in (invisible)backticks. [Rare]
" Ignore     <- helpBacktick        : the invisible backticks themselves.
" Comment    <- helpExample         : all the indented code examples.
" Special    <- helpSpecial         : Character/key codes, either "CTRL-" or in <>; also things in curly braces, as generic arguments.
" SpecialChar <- helpSpecialChar    : ???
" SpecialComment <- helpSpecialComment : ???


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Builtin netrw
" (Set by /opt/sw/share/vim/vim82/syntax/netrw.vim)
" TODO: Many of the default links make no sense, so we should fix that.
"   NONE        <- netrwSortBy, netrwSortSeq, netrwQuickHelp, netrwCopyTgt,
"                   netrwPlain, netrwSpecial, netrwTime, netrwSizeDate,
"                   netrwTreeBarSpace, netrwSlash, netrwCmdNote,
"                   (netrwPlain <- netrwHdr, netrwLex, netrwYacc).
"   Comment     <- (netrwComment <- netrwComma, netrwHide, netrwHideSep).
"   Delimiter   <- netrwCmdSep, (netrwDateSep <- netrwTimeSep).
"   DiffChange  <- netrwLib, netrwMakefile.
"   Directory   <- netrwDir.
"   Folded      <- netrwData, (netrwGray <- netrwBak, netrwCompress, netrwObj,
"                   netrwSpecFile, netrwTags, netrwTilde, netrwTmp).
"   Function    <- netrwClassify, netrwHelpCmd.
"   Identifier  <- netrwVersion.
"   Number      <- netrwQHTopic.
"   PreProc     <- netrwExe.
"   Question    <- netrwSymLink.
"   Special     <- netrwLink, netrwPix, netrwTreeBar.
"   Statement   <- netrwHidePat, netrwList.
"   TabLineSel  <- netrwMarkFile.
"   WarningMsg  <- netrwCoreDump.


" ~~~~~ Plug 'jamessan/vim-gnupg' (set by ~/.vim/plugin/gnupg.vim)
" TODO: change anything from the defaults?

" ~~~~~ Plug 'mhinz/vim-startify'
" TODO:


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Generic Syntax Highlighting
" (/usr/share/vim/vim80/syntax/syncolor.vim)
"
" See `:h group-name` for what these groups are supposed to mean.
" In particular, what Structure is supposed to mean, since most
" syntax files seem to use Structure where they should be using
" Statement (or similar).

" ~~~ Comment-like
call s:Hi('Comment',   s:comment,  s:bg,   {}, 'italic')
call s:Hi('Title',     s:lavender, s:bg,   {}, {})
call s:Hi('Todo',      s:yellow,   s:bg,   {}, {})
" N.B., for vimscript, first the whole line gets vimLineComment
" (->vimComment->Comment), then the word before the ":" and the
" ":" itself get vimCommentTitle(->PreProc), and then if the word
" happens to be "TODO" or "FIXME" then it gets vimTodo(->Todo).
" Also, if you have something double-quoted inside a comment,
" then it gets vimCommentString(->vimString).
call s:Hi('Ignore',    s:bg, s:bg, {}, {})
" ~~~ Special<-
" TODO: What the heck is Special *really* for?  All sorts of random
"   things get linked to this group.
call s:Hi('Special',   s:violet, {}, {}, 'bold')
call s:HiLink('SpecialComment', 'PreProc')
" TODO: what's a good color for Delimiter?  Is s:sienna good for the longterm?
call s:Hi('Delimiter', s:sienna, s:bg, {}, {})
" SpecialChar Tag Debug
" ~~~ Statement<-
call s:Hi('Statement', s:lavender, {}, {}, {})
" Keyword Conditional Repeat Label Exception
call s:Hi('Operator',  s:cyan,     {}, {}, {})
" ~~~ Identifier<-
call s:Hi('Identifier',s:red,      {}, {}, {})
call s:Hi('Function',  s:blue,     {}, {}, {})
" ~~~ Constant<-
call s:Hi('Constant',  s:orange,   {}, {}, {}) " <-Number(<-Float), Boolean
call s:Hi('String',    s:green,    {}, {}, {})
call s:HiLink('Character', 'String')
" ~~~ PreProc <- Macro, PreCondit, Define, Include
call s:Hi('PreProc',   s:preproc, s:bg, {}, {})
" TODO: something special for PreCondit (aka Conditional for PreProc)
" ~~~ Type<-
" TODO: don't use the same color as Function!
" TODO: StorageClass shouldn't be the same as Type, nor Structure,...
call s:Hi('Type',      s:blue,     {}, {}, {}) " <-StorageClass, Typedef
call s:Hi('Structure', s:yellow,   {}, {}, {}) " using s:yellow for now just to make it very clear when it shows up.
" N.B., per `:h group-name` the Structure group is supposed to be
" for type-level keywords like 'struct', 'enum', 'union', etc.
" Whereas a lot of syntax files tend to interpret it as what Statement
" is actually for.
" ~~~ miscellaneous
" TODO: change these defaults? (Last set from /usr/share/vim/vim80/syntax/syncolor.vim)
" Underlined     xxx term=underline cterm=underline ctermfg=81 gui=underline guifg=#80a0ff
" Error          xxx term=reverse ctermfg=15 ctermbg=9 guifg=White guibg=Red


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Vimscript Syntax (/usr/share/vim/vim80/syntax/vim.vim)
" N.B., for all it's apparent complexity, this default parser
" for vimscript is actually quite fragile and unsophisticated.
" So there're lots of things which aren't marked with the groups
" you would think they should.
"
" TODO: vimIsCommand seems to be used for options-used-as-variables.
" N.B., the ampersand itself doesn't seem to be highlighted as any group :(
"
call s:HiLink('vimCommentTitle',    'Title')        " Default: ->PreProc
" N.B., vimCommentString parsing can be buggy and sometimes
" 'ends' the comment after the closing double-quotes!
call s:HiLink('vimCommentString',   'vimComment')   " Default: ->vimString
" The name of functions on the line where being defined via :fun
call s:HiLink('vimFunction',        'Function')     " Default: CLEARED
" The s: qualifier on the name of functions being defined via :fun
" But since it's only *ever* highlighted in that context, we'll
" just link to 'vimFunction' for consistency.
call s:HiLink('vimFuncSID',         'vimFunction')  " Default: ->Special
" TODO: I'm not entirely sure what this is.  For builtin
" functions, callsites get both this and also vimFuncName (which
" already links to Function); for user-defined functions (or at
" least s: qualified ones), they get this and vimUserFunc.
call s:HiLink('vimFunc',            'Function')     " Default: ->vimError
call s:HiLink('vimUserFunc',        'vimFunc')      " Default: ->Normal
" *Everything* inside parens it seems. Commas and variables both.
" And for both function-call parens as well as grouping parens! Only
" vimNumber and vimOper and vimString seem to be parsed inside parens :(
"call s:HiLink('vimOperParen', __) " Default: CLEARED
" The parentheses for function calls.
call s:Hi('vimParenSep', s:blue, {}, {}, {}) " Default: ->Delimiter ->Special
" The pipe for joining multiple commands together
" BUG: not working inside vimFuncBody
call s:HiLink('vimCmdSep', 'Special') " Default: CLEARED
" So that the equals sign in :set matches the one for :let
" BUG: this also highlights all but the last character of the RHS of the :set !!!
call s:HiLink('vimSetEqual', 'vimOper')
" BUG: the division operator doesn't seem to be being parsed as a
"   vimOper; certainly not within vimFuncBody.  Also the modulus
"   operator is being parsed as vimSpecFile within vimFuncBody!!
"   Try running `:syntax list vimOper` to get a better idea of
"   what's included there; and cf `:h expression-syntax`.  And
"   indeed, nothing in expr6 (* / %) is being included in vimOper :(
"   Nor is the ! of expr8 (the unary + and - are included only by
"   accident)


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" let the comment ==Foo mean that this setting is equivalent to
" Foo's settings, though it's unclear if they're semantically equivalent.
"
" let the comment TNB=Foo mean that TNB used to have things set
" equivalently to Foo, but that we've changed it to something else
" for semantic consistency.

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ C Syntax
" TODO: which plugin is this for?
call s:HiLink('cType',          'Type')
call s:HiLink('cStorageClass',  'StorageClass')
call s:HiLink('cConditional',   'Conditional')
call s:HiLink('cRepeat',        'Repeat')

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ PHP Syntax
" TODO: which plugin is this for?
call s:Hi('phpVarSelector',    s:red, {}, {}, {}) " Almost Identifier, but not quite.
call s:Hi('phpMemberSelector', s:fg, {}, {}, {}) " could be Statement, Conditional, Repeat, Special
call s:HiLink('phpKeyword',     'Keyword')
call s:HiLink('phpRepeat',      'Repeat')
call s:HiLink('phpConditional', 'Conditional')
call s:HiLink('phpStatement',   'Statement')

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Ruby Syntax (/usr/share/vim/vim80/syntax/ruby.vim)
call s:HiLink('rubyConstant',   'Constant') " Default: ->Type
" TODO: given that rubyConstant default links to Type, can we trust
"   that rubyConditional and rubyRepeat will in future versions
"   stay linked to Conditional/Repeat like they should?
" TODO: do we actually want any of these following ones? Can we clean them up?
call s:HiLink('rubySymbol',     'String') " Default: ->Constant
call s:Hi('rubyAttribute',             s:blue,  {},  {}, {})  " ==Function,Includes,Type; Default: ->Statement
call s:Hi('rubyLocalVariableOrMethod', s:orange, {}, {}, {})  " ==Constant; Default: CLEARED
call s:Hi('rubyCurlyBlock',            s:orange, {}, {}, {})  " ==Constant; Default: CLEARED
call s:Hi('rubyStringDelimiter',       s:green,  {}, {}, {})  " ==String; Default: ->Delimiter
call s:Hi('rubyInterpolationDelimiter', s:orange, {}, {}, {}) " ==Constant; Default: ->Delimiter

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Python Syntax (/usr/share/vim/vim80/syntax/python.vim)
" All the default links seem to make sense.

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Markdown Syntax (/usr/share/vim/vim80/syntax/markdown.vim)
" Not the best thing, but it'll do for now
call s:HiLink('markdownCode', 'Special') " Default: CLEARED
" TODO: the markdownUrl->Float link makes no sense, though the
"   colors seem fine enough for now.
" TODO: consider wrengr#utils#MarkdownIncludeCodeblock()
"   Not that we ought to call it here, just something to remember.

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ JavaScript Syntax
" TODO: which plugin is this for?
call s:Hi('javaScriptBraces', s:fg, {}, {}, {}) " could be Statement, Conditional, Repeat, Special
call s:HiLink('javaScriptFunction',     'Function')
call s:HiLink('javaScriptConditional',  'Conditional')
call s:HiLink('javaScriptRepeat',       'Repeat')
call s:HiLink('javaScriptNumber',       'Number')
call s:HiLink('javaScriptMember',       'Constant') " TODO: That doesn't seem right...

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Haskell Syntax
" (~/.vim/bundle/haskell-vim/syntax/haskell.vim)
" This plugin uses an interesting style: generally you'll have a
" group haskellFooKeywords which lists a bunch of keywords, but marks
" them as only being matched whenever 'contained' by some other group;
" and then there'll be the haskellFoo group wich actually does the
" regexing to match the keywords ...to ensure that it only matches
" when the keywords are used in the right order or the right context.
" It's actually quite clever, though it makes it hard to learn anything
" from looking at the synstack.
"
" Alas, for all its cleverness, it seems to fail to parse a bunch
" of stuff.  Of particular annoyance, it'll parse haskellIdentifier
" whenever it occurs within a haskellTypeSig, but not in the actual
" definition.  Thus, all variables end up looking Normal.  This is
" because haskellIdentifier too is guarded to only be highlighted
" whenever it's 'contained'.
" TODO: Luckily, most all the regex stuff is for contextualizing
"   keywords; which means we should be free to add a few rules of
"   our own for applying haskellIdentifier to things elsewhere.

call s:HiLink('haskellChar',    'Character')    " Default: ->String
call s:HiLink('haskellTH',      'Macro')        " Default: ->Boolean
" TODO: figure out a good thing to link haskellBottom to; technically they're just functions, but it is good to single them out...
" TODO: add keyword 'otherwise' and highlight as Label (a~la C's 'default')
" TODO: also should split up haskellKeyword so that 'case' 'of' can be Conditional (a~la C's 'switch')
" TODO: add some stuff for pattern matching; maybe link it to Label (a~la C's 'case')

" ~~~~~ Default `:highlight def link`
" PreProc     <-haskellPreProc              == proper CPP shenanigans
"             | Macro     <-haskellBottom         = undefined error
"             | Include   <-haskellImportKeywords = import qualified safe as hiding
" Constant    <-Boolean   <-haskellTH
"             | Number    <-haskellNumber
"                         | Float       <-haskellFloat
" Identifier  <-haskellIdentifier
" Structure   <-haskellForeignKeywords    = foreign export import ccall safe unsafe interruptible capi prim
" Keyword     <-haskellKeyword            = do case of
"             | haskellDefault            = default
"             | haskellInfix              = infix infixl infixr
" Conditional <-haskellConditional        = if then else
" Delimiter   <-haskellSeparator
"             | haskellDelimiter
" Operator    <-haskellOperators
"             | haskellQuote
"             | haskellBacktick
" Comment     <-haskellShebang
"             | haskellLineComment
"             | haskellBlockComment
" SpecialComment  <-haskellPragma
"                 | haskellLiquid
" String      <-haskellString
"             | haskellChar
"             | haskellQuasiQuoted
" Todo        <-haskellTodo
" Type        <-haskellAssocType
"             | haskellQuotedType
"             | haskellType
"
" ~~~~~ Configurable `:highlight def link`
" {g:haskell_classic_highlighting ? Keyword : Structure}
"   <-haskellDeclKeyword    = instance class newtype in module
"   | haskellDeriveKeyword  = deriving instance anyclass newtype via stock
"   | haskellDecl           = data type family
"   | haskellWhere          = where
"   | haskellLet            = let
"   {g:haskell_enable_pattern_synonyms?}
"   | haskellPatternKeyword = pattern
"   {g:haskell_enable_typeroles?}
"   | haskellTypeRoles      = 'type role', phantom representational nominal
"
" {g:haskell_enable_quantification?} Operator <-haskellForall       = forall
" {g:haskell_enable_recursivedo?}    Keyword  <-haskellRecursiveDo  = mdo rec
" {g:haskell_enable_arrowsyntax?}    Keyword  <-haskellArrowSyntax  = proc
" {g:haskell_enable_static_pointers} Keyword  <-haskellStatic       = static
" {g:haskell_backpack?}
"   Structure   <-haskellBackpackStructure  = unit signature
"   Include     <-haskellBackpackDependency = dependency


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Clean Up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" TODO: should we :delf any functions, or :unlet any variables?

call s:Finish()
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
