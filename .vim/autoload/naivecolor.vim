" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Name:     autoload/naivecolor.vim
" Modified: 2021-09-08T10:53:45-07:00
" Version:  1
" Author:   wren romano
" Summary:  Standardly errant mapping from GUI hexstrings to cterm codepoints.
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
" These functions seem to be a widely copied idiom.[1]  I, myself,
" originally copied (most of) them from the Tomorrow-Night-Bright
" colorscheme <https://github.com/chriskempson/tomorrow-theme>
" (hereafter abbreviated 'TNB'), which in turn credits the Desert256
" colorscheme <https://github.com/brafales/vim-desert256>, which
" in turn claims to have calibrated things for xterm itself (ver.200)
" <http://dickey.his.com/xterm/xterm.html>, and "gives a wink" to the
" inkpot colorscheme <https://github.com/ciaranm/inkpot> (which has
" substantially different functions).  Neither Desert256 nor (this
" portion of TNB) are entirely clear about what license they're under.
" So given the unclear licensing, the relative simplicity of the
" original code, its widely copied nature, and the substantial
" differences between it and my own code, it's not entirely clear
" whether my work counts as a derivative work and if so then what
" licensing obligations I have.  That said, for my own work I am happy
" to license it under the "Zero-clause BSD" license written above.
"
" I have significantly rewritten these functions from the version
" in TNB/Desert256, and corrected some major bugs that go back at
" least as far as Desert256.  I've also added a novel function
" naivecolor#code2hex() for inverting naivecolor#hex2code().  And
" I've added substantial commentary explaining the code (and its
" flaws).
"
" [1]: For example, they are also found in
"   <https://github.com/vim-scripts/guicolorscheme.vim>
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
"
"
" == Nomenclature ==
" * Level ('lvl')
"       Meaning:    the full 1-byte scale as used by GUI colors.
"       Variables:  r, g, b, n
"       Range:      [0..255]
" * Ordinal ('ord')
"       Meaning: the ordinal index for those levels which are coded
"           by the given palette.
"       Variables: x, y, z
"       Range: varies by palette and dimension:
"           * 256color greyscale [0..23] (but see [note #1])
"           * 256color R/G/B     [0..5]
"           * 88color  greyscale [0..7] (but see [note #1])
"           * 88color  R/G/B     [0..3]
" * Codepoint ('code')
"       Meaning: the actual codepoint in the given palette.
"       Range: varies by palette.
"           256color [0..255] aka [0x00..0xFF]
"           88color  [0..87]  aka [0x00..0x57]
" * Color
"       Meaning: the actual aesthetic realization according to human
"           perception.  I use this term specifically to make certain
"           distinctions in the commentary; it's not something that
"           actually occurs in code.
"
" Ordinals and codepoints are different concrete numbers for
" the same thing, so mapping one to the other is always
" exact/invertible.
"
" Whereas, mapping between levels and ordinals introduces error,
" for several reasons: their range can span different regions of
" color-space, their differing precision means they must take
" different size steps through color-space, and the curvature of
" color space means that those steps are actually (differently)
" varying sizes.
"
" The functions below try to minimize the error by: assuming the
" level-space is the same thing as color-space, assuming R/G/B
" forms an orthogonal basis of color-space, assuming 'grey' is
" a ray that's equidistant from all three R/G/B axes, assuming
" that both level-space and ordinal/code-space are uniform as
" color spaces (except for boundary cases), and assuming that
" level-space has the same gamut as ordinal/code-space.
" Warning: These are common assumptions and they greatly simplify
" the code, but basically every one of those assumptions is false.
" Really we should be using CIEDE2000 (or similar) to compute
" distances in a more accurate model of color-space.  Alas CIEDE2000
" is computationally expensive, but that just means we should
" precompute it offline and cache the results in our colorscheme
" files.
"
"
" [Note #1]: Regarding the range of greyscale ordinals: the 256-palette
" does not include "white" and "black" in the greyscale ramp, rather
" they are placed at the corners of the color cube.  Thus, for the
" functions below we actually use the range [0..25] where 0 and 25
" get mapped to codepoints in the color cube, and [1..24] get mapped
" to codepoints in the greyscale ramp.  (N.B., this is not entirely
" uniform, since the level-space distance from the color-cube codepoints
" to the nearest greyscale-ramp codepoints doesn't equal to the
" level-space distance between adjacent greyscale-ramp codepoints.)
" I assume the 88-palette is arranged similarly, given that the
" functions below handle it similarly.
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


" TODO: see if there's anything more to be gained from:
"   <https://github.com/vim-scripts/CSApprox>
"   <https://github.com/vim-scripts/guicolorscheme.vim>
"   <https://vim.fandom.com/wiki/Using_GUI_color_settings_in_a_terminal>
"   <http://vim.wikia.com/wiki/Xterm256_color_names_for_console_Vim>
"   <https://github.com/chrisbra/Colorizer>
"
" N.B., apparently eterm and konsole have their own palettes different
" from xterm's 256-palette and urxvt's 88-palette.  For more details, see:
" <https://github.com/vim-scripts/CSApprox/blob/master/autoload/csapprox/common.vim>


" TODO: I haven't had a chance to validate/bugfix the code for the
" 88-palette.  So, need to find such a terminal so we can test/fix
" them in all the functions below.


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Preamble ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" ~~~~~ Load only once.
" Cf., the untagged section just after `:h use-cpo-save`.
if exists('g:loaded_naivecolor') | finish | endif
let g:loaded_naivecolor='1'

" ~~~~~ Ensure nocompatible
" See `:h use-cpo-save` and `:h :set-&vim`.
let s:save_cpo = &cpo
set cpo&vim


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Helper functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" N.B., this implementation introduces an extra division (compared
" to TNB) to calculate l:mid from a:mod; but we may wish to avoid
" that by passing l:mid in as an argument instead.
"
" AFAICT, Vim has quotRem ("round toward zero") semantics rather
" than divMod ("round toward negative infinity") semantics, as
" demonstrated by considering the case of `(-14) / 5`.  However,
" when it comes to porting this code to other languages, luckily
" for us both callsites already need guards for when to return
" ordinal 0 (since we do not allow negative ordinals!), and those
" guards subsume the levels where divMod and quotRem would give
" different answers.  If the distinction doesn't make sense (or
" even if it does), you may be interested in the discussion at:
" <https://stackoverflow.com/q/18917717>
fun! s:divRound(x, mod)
  let l:quot = a:x / a:mod
  let l:rem  = a:x % a:mod
  let l:mid  = a:mod / 2
  " Warning: As per TNB we always round-up, not round-to-even.
  return l:quot + (l:rem < l:mid ? 0 : 1)
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Grey functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" The 256-palette uses codepoints:
"                               Black-ish       White-ish
"   3-bit 'standard'            0x00 (0)        0x07 (7)
"   4-bit 'bright'/'intense'    0x08 (8)        0x0F (15)
"   ends of the color cube      0x10 (16)       0xE7 (231)
"   the greyscale ramp          0xE8 (232) ...  0xFF (255)
"
" However, (a) we can't use any of the 3-/4-bit system colors,
" because the user can configure their terminal to map those to
" whatever arbitrary thing they want; (b) the color-cube and
" greyscale-ramp do not coincide on their endpoints:
"
"   color-cube  0x10 == rgb(0,0,0)  0xE7 == rgb(255,255,255)
"   grey-ramp   0xE8 == rgb(8,8,8)  0xFF == rgb(238,238,238)
"
" At least according to my setup (see [Note #2]) and to the original
" TNB code for s:grey_ord2code().  Thus, as explained in [Note #1]
" we actually use ordinal range [0..25] where:
"
"   ord 0       == code 0x10            == level 0
"   ord [1..24] == code [0xE8..0xFF]    == level [8,18..238]
"   ord 25      == code 0xE7            == level 255
"
" While I can't seem to find a copy of any official standards report
" indicating that that's the *required* mapping from codepoints to
" levels, my own setup (see [Note #2]) does validate it.
"
" [Note #2]: on terminal iTerm2 (build 3.4.9beta1) and verified by
" the DigitalColorMeter.app (version 5.13, shipping with OSX 10.14.6).


" Alas, while the TNB code for s:grey_ord2code() follows the above
" story for using an ordinal range [0..25], the TNB code for
" s:grey_lvl2ord() and s:grey_ord2lvl() don't seem to agree.  I've
" made changes to correct them to agree with the above story, but
" it's not clear to me whether they were just buggy or whether
" there's something I'm missing.

fun! s:grey_lvl2ord(n)
  if &t_Co == 88
    " 88-palette has 8 steps along the greyscale ramp (apparently),
    " plus two extra ordinals as discussed in [Note #1].
    if     a:n < 23  | return 0
    elseif a:n < 69  | return 1
    elseif a:n < 103 | return 2
    elseif a:n < 127 | return 3
    elseif a:n < 150 | return 4
    elseif a:n < 173 | return 5
    elseif a:n < 196 | return 6
    elseif a:n < 219 | return 7
    elseif a:n < 243 | return 8
    else             | return 9
    endif
  elseif &t_Co == 256
    " 256-palette has 24 steps along the greyscale ramp, plus
    " two extra ordinals as discussed in [Note #1].
    " BUGFIX: The TNB code had faulty handling of the endpoints,
    " as well as off-by-one errors.
    "
    " There are 8 levels between 0x10 and 0xE8.
    "   [0..2]      If quotRem, then standard == 1, but should be 0.
    "               If divMod,  then standard == 0, which is correct
    "   [3]         the standard case would give 1, but should be 0.
    "   [4..12]     the standard case would give 1, which is correct.
    if     a:n < 4   | return 0
    " There are 17 levels between 0xFF and 0xE7.
    "   [233..242]  the standard case would give 24, which is correct.
    "   [243..246]  the standard case would give 25, but should be 24.
    "   [247..252]  the standard case would give 25, which is correct.
    "   [253..255]  the standard case would give 26, but should be 25.
    elseif a:n > 246 | return 25
    elseif a:n > 242 | return 24
    " There are 10 levels between any adjacent pairs in 0xE8..0xFF.
    else             | return 1 + s:divRound(a:n - 8, 10)
    endif
  else
    throw 'Error(naivecolor): unknown color palette: ' . &t_Co
  endif
endfun


fun! s:grey_ord2lvl(x)
  if &t_Co == 88
    if     a:x == 0 | return 0
    elseif a:x == 1 | return 46
    elseif a:x == 2 | return 92
    elseif a:x == 3 | return 115
    elseif a:x == 4 | return 139
    elseif a:x == 5 | return 162
    elseif a:x == 6 | return 185
    elseif a:x == 7 | return 208
    elseif a:x == 8 | return 231
    else            | return 255
    endif
  elseif &t_Co == 256
    " BUGFIX: TNB's code left out the special case for ordinal 25.
    " BUGFIX: TNB's code had off-by-one error in the standard case.
    if     a:x == 0  | return 0
    elseif a:x == 25 | return 255
    else             | return (a:x * 10) - 2
    endif
  else
    throw 'Error(naivecolor): unknown color palette: ' . &t_Co
  endif
endfun


fun! s:grey_ord2code(x)
  if &t_Co == 88
    if     a:x == 0 | return 16
    elseif a:x == 9 | return 79
    else            | return 79 + a:x
    endif
  elseif &t_Co == 256
    if     a:x == 0  | return 16
    elseif a:x == 25 | return 231
    else             | return 231 + a:x
    endif
  else
    throw 'Error(naivecolor): unknown color palette: ' . &t_Co
  endif
endfun


" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ RGB functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Again, I don't have any official standards report to know if these
" levels are required or where they actually come from, but at least
" on my system (see [Note #2]) the 256-palette does indeed have the
" mapping given by the original s:rgb_ord2lvl():
"
"   ord:    0   1   2   3   4   5
"   lvl:    0   95  135 175 215 255

fun! s:rgb_lvl2ord(n)
  if &t_Co == 88
    " 88-palette has 4 steps along each R/G/B axis.
    if     a:n < 69  | return 0
    elseif a:n < 172 | return 1
    elseif a:n < 230 | return 2
    else             | return 3
    endif
  elseif &t_Co == 256
    " 256-palette has 6 steps along each R/G/B axis.
    " N.B., even though we're not adjoining any extra ordinals
    " like in the greyscale ramp, we still have a non-uniform
    " color space here!  (Because ordinals 0 and 1 are further
    " apart in level-space than are any other pair of adjacent
    " ordinals.)
    "
    " BUGFIX: corrected the thresholds for ordinal 0 vs 1.
    "
    " Special regions:
    "   [0..15]     the standard case would give -1, but should be 0.
    "   [16..34]    If quotRem, then standard == 0, which is correct.
    "               If divMod, then standard == -1, but should be 0.
    "   [35..47]    the standard case would give 0, which is correct.
    "   [48..74]    the standard case would give 0, but should be 1.
    "   [75..114]   the standard case would give 1, which is correct.
    if     a:n < 48 | return 0
    elseif a:n < 75 | return 1
    else            | return s:divRound(a:n - 55, 40)
    endif
  else
    throw 'Error(naivecolor): unknown color palette: ' . &t_Co
  endif
endfun

fun! s:rgb_ord2lvl(x)
  if &t_Co == 88
    if     a:x == 0 | return 0
    elseif a:x == 1 | return 139
    elseif a:x == 2 | return 205
    else            | return 255
    endif
  elseif &t_Co == 256
    if a:x == 0 | return 0
    else        | return 55 + (a:x * 40)
    endif
  else
    throw 'Error(naivecolor): unknown color palette: ' . &t_Co
  endif
endfun

fun! s:rgb_ord2code(x, y, z)
  if &t_Co == 88
    " 88 palette codes a 4×4×4 cube of colors.
    return 16 + (a:x * 16) + (a:y * 4) + a:z
  elseif &t_Co == 256
    " 256 palette uses codepoints 0x10..0xE7 (16..231) to code
    " a 6×6×6 cube of colors: 16 + 36*r + 6*g + b (0 ≤ r, g, b ≤ 5)
    return 16 + (a:x * 36) + (a:y * 6) + a:z
  else
    throw 'Error(naivecolor): unknown color palette: ' . &t_Co
  endif
endfun

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Final coding functions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" Map 'rrggbb' hex string to the closest palette codepoint (according
" to the errant assumptions mentioned in the opening discussion).
fun! naivecolor#hex2code(rgb) abort
  let l:rgb = substitute(a:rgb, '^#', '', '')
  " TODO: add checks for a:rgb being the right length, valid hex chars, etc.

  " Extract R/G/B levels from the hex string.
  " This conversion idiom taken from 'junegunn/limelight.vim', in
  " lieu of TNB's idiom: `('0x' . strpart(a:rgb, 0, 2)) + 0`
  " Not sure if there's any differences in performance, edge cases,
  " or portability; but I trust junegunn's code moreso than TNB.
  let l:r = eval('0x' . l:rgb[0:1])
  let l:g = eval('0x' . l:rgb[2:3])
  let l:b = eval('0x' . l:rgb[4:5])
  " Get ordinals of the closest greyscale-ramp codepoint.
  " (or the black/white corners of the color-cube)
  let l:gx = s:grey_lvl2ord(l:r)
  let l:gy = s:grey_lvl2ord(l:g)
  let l:gz = s:grey_lvl2ord(l:b)
  " Get ordinals of the closest colour-cube codepoint.
  let l:cx = s:rgb_lvl2ord(l:r)
  let l:cy = s:rgb_lvl2ord(l:g)
  let l:cz = s:rgb_lvl2ord(l:b)

  if l:gx == l:gy && l:gy == l:gz
    " All grey ordinals are equal, so the color is
    " *semantically* grey.  However, the closest *codepoint*
    " for representing that grey could be either the one in
    " the greyscale-ramp or the one in the color-cube; so we
    " need to figure out which is closer.
    let l:dgr = s:grey_ord2lvl(l:gx) - l:r
    let l:dgg = s:grey_ord2lvl(l:gy) - l:g
    let l:dgb = s:grey_ord2lvl(l:gz) - l:b
    let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
    let l:dr = s:rgb_ord2lvl(l:gx) - l:r
    let l:dg = s:rgb_ord2lvl(l:gy) - l:g
    let l:db = s:rgb_ord2lvl(l:gz) - l:b
    let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
    if l:dgrey < l:drgb
      return s:grey_ord2code(l:gx)
    else
      return s:rgb_ord2code(l:cx, l:cy, l:cz)
    endif
  else
    " Grey ordinals are not all equal, therefore is
    " semantically a color.
    " TODO: technically the greyscale-ramp codepoint could
    "   still be closer.  So why did TNB not check?
    return s:rgb_ord2code(l:cx, l:cy, l:cz)
  endif
endfun


" Inverse of naivecolor#hex2code(), for debugging/reference.
fun! naivecolor#code2hex(cp)
  if &t_Co == 88
    if a:cp < 16
      throw 'ERROR(naivecolor#code2hex): cannot handle system colors'
    elseif a:cp < 80
      " We're in the color cube.
      let l:z = (a:cp - 16) % 4
      let l:y = ((a:cp - 16 - l:z) / 4) % 4
      let l:x = ((a:cp - 16 - l:z - (l:y * 4)) / 16) % 4
      let l:r = s:rgb_ord2lvl(l:x)
      let l:g = s:rgb_ord2lvl(l:y)
      let l:b = s:rgb_ord2lvl(l:z)
      return printf('%02x%02x%02x', l:r, l:g, l:b)
    else
      " We're in the greyscale ramp.
      let l:x = a:cp - 79
      let l:n = s:grey_ord2lvl(l:x)
      return printf('%02x%02x%02x', l:n, l:n, l:n)
    endif
  elseif &t_Co == 256
    if a:cp < 16
      throw 'ERROR(naivecolor#code2hex): cannot handle system colors'
    elseif a:cp < 232
      " We're in the color cube.
      let l:z = (a:cp - 16) % 6
      let l:y = ((a:cp - 16 - l:z) / 6) % 6
      let l:x = ((a:cp - 16 - l:z - (l:y * 6)) / 36) % 6
      let l:r = s:rgb_ord2lvl(l:x)
      let l:g = s:rgb_ord2lvl(l:y)
      let l:b = s:rgb_ord2lvl(l:z)
      return printf('%02x%02x%02x', l:r, l:g, l:b)
    else
      " We're in the greyscale ramp.
      let l:x = a:cp - 231
      let l:n = s:grey_ord2lvl(l:x)
      return printf('%02x%02x%02x', l:n, l:n, l:n)
    endif
  else
    throw 'Error(naivecolor): unknown color palette: ' . &t_Co
  endif
endfun

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~ Clean Up ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
let &cpo = s:save_cpo
unlet s:save_cpo
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin.
