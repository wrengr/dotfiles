(N.B., this file is only pretending to be Markdown.  Also, using
ts=2 so that the default syntax/markdown.vim doesn't treat things
as blockquotes; though it still catches a few things anyways.  You
may want to run `:syn clear markdownCodeBlock` whenenever (re)loading
this file.)

----------------------------------------------------------------
# What the heck goes where in the ~/.vim directory?

This blog post has a nice summary of the directory structure in
~/.vim/, including a bunch of directories I don't have (yet)
  <http://www.panozzaj.com/blog/2011/09/09/vim-directory-structure/>
See also:
  `:h runtimepath`

tl;dr:
  -- General-purpose plugins:
  plugin      -- always loaded at startup time.
                  `:h write-plugin`
  autoload    -- loaded whenever their autoload functions are first called.
                  `:h autoload-functions`

  -- Special support for specific filetypes / programming languages.
  ftplugin    -- plugins, loaded whenever the filetype matches.
  ftdetect
  syntax      -- syntax parsing
  indent      -- `:h indent-expression`

  -- Other stuff.
  colors      -- colorschemes
  compiler    -- `:h write-compiler-plugin`
  keymap      -- `:h keymap-file-format`
  lang        -- `:h multilang-menus`, `:menutrans`, `'langmenu'`, `:language`
  macros      -- mere examples of how to do things.


----------------------------------------------------------------
# What the heck does ... mean in vimscript?

* What is good style for your ~/.vimrc file?
  <http://vim.wikia.com/wiki/Keep_your_vimrc_file_clean>
  <https://google.github.io/styleguide/vimscriptguide.xml>
  <https://www.arp242.net/effective-vimscript.html>

* What's the difference between `has()` vs `exists()`?
  `has(...)`    checks compiled-in "features"
  `exists(...)` checks reconfigurable "options"

* what the what?
  Features    Vim's compile-time settings.
  Options     Built-in special variables for configurable settings.
  Registers   Classic Vi places to store things (e.g., from Normal-mode)
  Variables   Ex(?) / Vimscript places to store things.
  Mappings    Vim's Normal-/Visual-/...-mode programming (binds keystrokes to commands)
  Commands    Ex programming (user-defined or built-in)
  Functions   Vimscript programming

  Tabpages    Holds multiple "Windows" (`:h tabpage.txt`)
  Windows     A viewport into a buffer (`:h windows.txt`)
  Buffers     A file loaded into memory

--------------------------------
## Features

<https://vi.stackexchange.com/a/22449>


--------------------------------
## Options

* What do those funny symbols on `:set` mean?
  `:set foo`    turn foo on
  `:set nofoo`  turn foo off
  `:set invfoo` toggle foo
  `:set foo!`   toggle foo
  `:set foo&`   set foo to its default value
  `:set foo?`   show the current value of foo
  `:set foo<`   remove the local value, so the gobal will get used

--------------------------------
## Registers

For the following we'll use register 'r' and pretend 'X' is some normal-command and 'E' some expression:

Mode:   Normal      Command
Read:   <C-r>r      @r
Write:  "rX         let @r=E    (possibly only @/ and @@ can be written to via :let)

### Special registers

    ""          Default register for: <y>, <d>, <x>, <c>, <s>; <p>, <P>; etc
    "0 "9       Previous values of ""
    "-          small-delete
    "* "+ "~    GUI selection/clipboard registers, see helppages for: `quotestar`, `quoteplus`, `x11-selection`, `gui-clipboard`, `+xterm_clipboard`.
    "~          GUI drag'n'drop register (read-only); see also the <Drop> pseudokey.
    "=          expression pseudo-register
    ":          last commandline (read-only := can only be used with <p>, <P>, and `:put`)
    ".          last inserted-text (read-only). Doesn't play nice with c_<C-r>
    "%          name of current file (read-only).
    "#          name of alternate-file for current-window.      cf., <C-^>
    "_          blackhole
    "/          last search
    "@          who knows?!  cf., the sample code in `:h g@` aka `:h E774`


After saying "= or <C-r>= the cursor will move to the commandline
where you can enter any expression (with all the standard commandline
edditing commands available). When you hit <CR>, the expression is
evaluated to a string.


Reminder (where M is some motion):
            Synonyms
            Normal      Visual  VBlock          Select
    <D>     <d$>        <X>     (also to EOL)
    <x>     <dl>        <d>                     <C-h> aka <BS>
    <X>     <dh>        <D>
    <cc>    <dd><i>
    <c>M    <d>M<i>     <s>     akin to v_b_I, but deleting first
    <C>     <c$>        <S>     <c> but also to EOL `:h v_b_C`
    <s>     <cl>        <c>
    <S>     <cc>        <C>
See also `:h o_v`, `:h :d`, `:h mode-ins-repl`

--------------------------------
## Variables

* What do those {&,@,g:,w:,...} prefixes on variables mean?
  `:h internal-variables`
  <https://codeyarns.com/2010/11/26/how-to-view-variables-in-vim/>
  <http://learnvimscriptthehardway.stevelosh.com/chapters/19.html>

  N.B., fresh variables `:let` in functions are always (at least
  these days) implicitly in the l: scope.  However, as mentioned
  by `:h l:` if there is a v: scoped variable of the same name
  then Vim will assume you meant that one rather than a function-local
  one.  Thus, while using l: is seldom actually required, it does
  help avoid some bugginess.

* Using options as variables:
  Use/Reference
      Explicitly Global `&g:o`
      Explicitly Local  `&l:o`
      'Smart'           `&o`                -- Local if defined, else global.
  Echoing
      Global        `:setg o?`  `:echo &g:o`
      Local         `:setl o?`  `:echo &l:o`
      'Smart'       `:set  o?`  `:echo &o`
  Assignment
      Global-only   `:setg o=v` `:let &g:o=v`
      Local-only    `:setl o=v` `:let &l:o=v`
      'Both'(!!)    `:set  o=v` `:let &o=v` -- Clear the local, set the global.
  Caveats:
  * `:set o=v` requires that v is a literal/constant value;
    whereas `:let &o=v` allows v to be an expression.
  * "local" means totally different things for `&l:opt` vs `l:var`.
    For `l:var` it always means function-local scope.  For `&l:opt`
    it means one of tab-local, window-local, or buffer-local,
    depending on the option.

* Using registers as variables:
  Assignment  `"r{...}`     `:let @r=v`
  Echoing                   `:echo @r`

* Using other things as variables vis-a-vis `:let`, see the help for:
  `:h :let-$`, `:let-environment`
  `:h :let-@`, `:let-register`
  `:h :let-&`, `:let-option`

* Functions for variable scoping shenanigans.  To disambiguate the
  "local"-ness of options we use the usual namespace sigils for
  variables, even though technically we're not allowed to apply
  those for options.  In addition, if we need to be generic about
  the scope, then we'll use 'x:' or 'y:' (which I'm pretty sure don't
  exist to mean something else).

  * In all the following functions:
    * The {def} is optional and defaults to the empty string.
    * The {name} is a string
    * The {name} must not have the `'x:'`
    * If {name} begins with `'&'` (except for `gettabvar()`)
      * if exactly `'&'` then return dict of all `&x:opt`   (but see note below)
      * otherwise return the value of `&x:opt`, falling back
        eventually to `&g:opt`, and then to {def}.
    * Otherwise {name} doesn't begin with `'&'`
      * if `''` then return dict of all `x:var`             (but see note below)
      * otherwise return the value of `x:var`, falling back to
        {def}.  None of these functions works for `g:var` nor
        for other `y:var`.

  * t: (no options allowed)
      `gettabvar({tabnr}, {name}, {def})`
  * w: (or `&b:opt`)
      `gettabwinvar({tabnr}, {winnr}, {name}, {def})`
      `getwinvar({winnr}, {name}, {def})`   " uses current tabpage
  * b:
      `getbufvar({buf}, {name}, {def})`
        * Before 7.4.434, `getbufvar()` returns an empty string
          instead of an empty dict when nothing is found.
        * Also, older version of vim don't return local options
          with `getbufvar(bid, '&')`
        <https://github.com/LucHermitte/lh-vim-lib/blob/693f67011cb8a959875524502661442412cba60a/autoload/lh/option.vim#L286>


--------------------------------
## Mappings

* What do all those variations on `:{n,v,i,}{nore,un,}map` mean?
  `:h map-overview`, `map-modes`
  the official story: <http://vimdoc.sourceforge.net/htmldoc/map.html>
  the full story:     <http://stackoverflow.com/a/11676244>
  the short version:  <http://stackoverflow.com/a/3776182>

  tl;dr: using indentation to indicate setting for multiple modes,
  and ellipses for when no command exists for a specific sub-mode
  included by some more general command:
  `map`
    `omap`      -- OperatorPending-mode
    `nmap`      -- Normal-mode
    `vmap`
      `xmap`    -- Visual-mode
      `smap`    -- Select-mode (i.e., VisualReplace)
  `lmap`
    ...         -- LangArg-mode (see `:h language-mapping`)
    `map!`
      `imap`
        ...     -- Insert-mode
        ...     -- Replace-mode
      `cmap`    -- any of several Commandline-modes (see `:h getcmdtype()`)
  `tmap`        -- TerminalJob-mode (see `:h terminal-typing`)

  * OperatorPending mode is when you've typed the verb of some
    command, but haven't yet given it an object/motion.  Afaict,
    this is how you can define things like `i` and `a` for selecting
    objects, even though they aren't motion commands by themselves.
  * You may also want to look up `:h c_CTRL-U`, which is especially
    helpful when defining omaps.


* What do all these `<foo>` attributes on mappings mean?
  See: `:h :map-arguments` for the top-level, or `:h :map-<foo>`
  for the specific one.
  * `<silent>`  -- Ignore `:echo` (but not `:echomsg`/`:echoerr`)
    * Whereas the command `:silent` ignores `:echomsg`
  * `<expr>`    -- Evaluate the RHS to determine the expansion.
    <https://vi.stackexchange.com/a/6030>
  * `<script>`  -- Only recursively apply script-local mappings.
                    (thus, `:map <script>` ==> `:noremap <script>`)
  * `<buffer>`  -- Define a buffer-local mapping.
    <https://learnvimscriptthehardway.stevelosh.com/chapters/11.html>
  * `<unique>`  -- Fail if the mapping already exists (locally or globally).
  * `<nowait>`  -- On prefix-clash, don't wait for timeout
  * `<special>` -- Overrides `:h cpo-<` to allow mapping special keys
                    (i.e., keys that are spelled with `<...>`)


* What are the other `<foo>` things on mappings?
  Virtual keystrokes for various things:
  * `<Leader>`      -- the current value of the `g:mapleader` variable.
  * `<LocalLeader>` -- the current value of the `b:maplocalleader` variable.
                        (Or rather, should only be used for `<buffer>` maps)
  * `<SID>`         -- The script-local value of a gensym.
  * `<Plug>`        -- See: `:h using-<Plug>`
    * This can't be entered via keyboard, thus it's helpful for
      plugins to hang their mappings off of, since it's less likely
      to clobber the user's own mappings.  (Though, every plugin using
      it can still clobber each other, of course.)  For example, to
      define a new normal-mode mapping:

        ```
        nnoremap <Plug>(Foo) :call <SID>Foo()<CR>
        ```

      A crucial thing to note about this mapping is that only the
      <Plug> itself is the special virtual keystroke; thus, this
      is creating a mapping for the key sequence: <Plug>, '(', 'F',
      'o', 'o', ')'.  Because we're mapping an entire key sequence,
      we need to make sure that no prefix of that sequence clashes
      with another mapping.  Hence the parentheses: if we defined
      mappings '<Plug>Foo' and '<Plug>FooBar' (in the right order,
      so that it's actually possible to call both of them), then
      after the user (virtually)types '<Plug>Foo', vim would be
      forced to wait for the next keystroke (or timeout) in order
      to disambiguate which one the user meant.  The parentheses
      serve to disambiguate, and thus avoid both the timeout and
      the concern over the order of defining the two mappings.  Of
      course, all we really need for enacting those fixes is some
      arbitrary sentinel character at the end which we never use
      in the middle of mappings; the use of ')' for that sentinel,
      and the matching '(', are just conventional idiom.

    * One can also avoid the timeout issue by using the `<nowait>`
      attribute.  All it does is effectively set the timeout to 0
      for the mapping; it doesn't ignore additional input that may
      already be there.  Thus, if you have something like:

        ```
        nnoremap <nowait> <Plug>Foo :call <SID>Foo()
        nnoremap <Plug>FooBar :call <SID>FooBar()
        nnoremap bar <Plug>FooBar
        ```

      Then when the user types 'bar' it expands to '<Plug>FooBar'
      which already has enough to disambiguate it to the second
      mapping and therefore expands to ':call <SID>FooBar()'.

    * To avoid clashing with other plugins, the convention is to
      put the plugin's name as the first thing after the `<Plug>`
      (or after the opening parentheses).

    * Many plugins will go a step further and define a conventional
      (i.e., keyboard-typeable) mapping to go along with the above,
      often with an idiom going something like:

        ```
        " If nothing else already maps to <Plug>(Foo)
        if !hasmapto('<Plug>(Foo)', 'n')
        " ...And if foo doesn't already map to something else
        \ && !mapcheck('foo', 'n')
        " ...Then we'll map foo to <Plug>(Foo)
          nmap foo <Plug>(Foo)
        endif
        ```

      Of course, that still makes me queasy.


* When do I need a trailing `<CR>` vs not?
    *mappings* need `<CR>`
        (to simulate the user hitting enter after typing the command)
    *commands* mustn't have `<CR>`
        (If you have it you'll get "E488: Trailing characters")
    <https://vi.stackexchange.com/q/4689>
    <https://vi.stackexchange.com/a/4690>

* How can I see what mappings are currently set/active?
  * To get a short list (i.e., no combos)

        ```
        :redir! > vim_keys.txt
        :silent verbose map
        :redir END
        ```

  * To get what they're set to In The Beginning
        `:h index`

--------------------------------
## Commands


--------------------------------
## Auto-Commands

An autogroup is nothing more than a particular collection of
autocommands.  The main reason for using autogroups is to make
scripts reentrant.  Each time an `:autocmd` is executed it will
register a callback, but that means a script containing that command
will register a new (duplicate) callback every time the script is
reloaded.  Thus, the reentrancy idiom is:

    ```
    augroup foo
      au!
      ...
    augroup END
    ```

The first `:aug` sets the default autogroup for subsequent `:au`
commands.  The `:au!` will clear out all previously registered
autocommands for this autogroup; which is what makes this hunk of
code reentrant.  Then you add whatever autocommands you want. And
finally `:aug END` changes the default autogroup back to the usual
unnamed one.  Of course, this idiom only works smoothly if this is
the only place we add autocommands to this particular autogroup;
otherwise, we'll loose whatever callbacks were registered elsewhere.


--------------------------------
## Functions

* Is there an *organized* list of the built-in functions?
    `:h function-list`

* What the heck is `s:` or `<SID>` on function names?
    <http://vimdoc.sourceforge.net/htmldoc/map.html#<SID>>
    N.B., you only need to say <SID> when defining *mappings*.  When
    defining *commands* (either by :command or by :autocmd) or just
    calling the function in an expression, you can say s: instead
    (and doing so is better style).

* Should I use `!` for function definitions?
    == From <https://vi.stackexchange.com/q/21856> ==
    Historically this was necessary to allow reloading of plugins;
    however, that behavior was changed in Vim 8.1.0515
        <https://github.com/vim/vim/releases/tag/v8.1.0515>
    and then changed again in Vim 8.1.0573
        <https://github.com/vim/vim/releases/tag/v8.1.0573>.
    So if you're using a newer version of Vim, then in general you
    shouldn't use ! unless you really mean to override something
    that's already around (e.g., in your ~/.vimrc to override some
    obnoxious plugin).  However, beware that many installations
    still only have older versions of Vim.

* Issues about adding `abort` to function definitions:
    <https://stackoverflow.com/q/13425648>
    <http://vimdoc.sourceforge.net/htmldoc/eval.html#except-compat>

* Vim 8.1.1310 allows true optional funargs (and with specified
    default values), but that's not supported by Neovim etc.
    <https://github.com/vim/vim/commit/42ae78cfff171fbd7412306083fe200245d7a7a6>


----------------------------------------------------------------
## Datatypes
--------------------------------
### Strings

* Escaping things in strings
    Double-quotes   `:h expr-string`    (or `:h expr-quote`)
    Single-quotes   `:h literal-string` (or `:h expr-'`)

* String comparison testing:
        `==?`   case-insensitive
        `==#`   case-sensitive
        `==`    depends on the user's `&ignorecase`
        Similarly for other comparators (`<#`, `<?`, `>=#`, etc)
    For scripting purposes never ever use `==`, just as you should
    never ever use mappings without `nore`
    <https://learnvimscriptthehardway.stevelosh.com/chapters/22.html>

    Apparently newer versions of vim also introduce `is`/`is#`/`is?`.
    For lists/dicts that means pointer equality, but for strings
    I'm not sure whether/how it's different.

--------------------------------
### Floats

* `if v:version >= 700 && has('+float')`
    Then Vim has floating-point numbers in addition to the old
    "Number" integers.  The representation is generally going to
    be 64-bit IEEE-754 ("double"), though technically it depends
    on how Vim was compiled.  Unfortunately, because of this late
    addition to the language you need to jump through some hoops
    to actually get floats (see `str2float()` and `float2nr()`),
    though operators do autopromote integers to floats when the
    other operand is already a float.  For a listing of the built-in
    functions for doing maths with floats, see `:h float-functions`.

----------------------------------------------------------------
## Special Listings
                Show List   Repetition{`if has('+listcmds')`}
* Tabs          `:tabs`     `:tabdo`
* Windows                   `:windo` (current tab only)
* Buffers       `:buffers`  `:bufdo` (`:files` and `:ls` are same)
* Tag-stack     `:tags`
* "Arguments"   `:args`     `:argdo`
* "quickfix"    `:cw`/`:cl` `:cdo`/`:cfdo`
* "location"    `:lw`/`:ll` `:ldo`/`:lfdo`

--------------------------------
## Special Windows & Buffers
  `:h preview-window`   `if has('+quickfix')`
  `:h special-buffers`
    * quickfix      -- `:h quickfix-window`
        * errors    -- `:cwindow`
        * locations -- `:lwindow`, `:h location-list`
    * help      -- `:help`
    * terminal  -- `:h terminal`
    * directory -- `:setl buftype=nowrite bufhidden=delete noswapfile`
    * scratch   -- `:setl buftype=nofile bufhidden=hide noswapfile`
    * unlisted  -- `:setl nobuflisted`

--------------------------------
## Tags
  `:h :tag`, `:stag`, `:ptag`
  `:h window-tag`, `preview-window`

----------------------------------------------------------------
----------------------------------------------------------------
