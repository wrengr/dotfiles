================================================================
=== What the heck goes where in the ~/.vim directory? ===

This blog post has a nice summary of the directory structure in
~/.vim/, including a bunch of directories I don't have (yet)
    <http://www.panozzaj.com/blog/2011/09/09/vim-directory-structure/>
See also:
    :help runtimepath

tl;dr:
    -- General-purpose plugins:
    plugin      -- always loaded at startup time.
                    :help write-plugin
    autoload    -- loaded whenever their autoload functions are first called.
                    :help autoload-functions

    -- Special support for specific filetypes / programming languages.
    ftplugin    -- plugins, loaded whenever the filetype matches.
    ftdetect
    colors      -- colorschemes
    syntax      -- syntax parsing
    indent      -- :help indent-expression

    -- Other stuff.
    compiler    -- :help write-compiler-plugin
    keymap      -- :help keymap-file-format
    lang        -- :help multilang-menus :menutrans 'langmenu' :language
    macros      -- mere examples of how to do things.


================================================================
=== How do I manage all this stuff? ===

There are a plethora of different plugin managers for vim, all in
various states of deprecation and unmaintinence. For my part, I'm
going to (try to) use vim-plug, which appears to be the latest and
greatest of the options.
    <https://github.com/junegunn/vim-plug>

Of course, I also want to have my own homerolled stuff, and don't
want it to get trounced by plugin managers. So where should I put
that stuff?


================================================================
=== What the heck does ... mean in vimscript? ===

* What is good style for your ~/.vimrc file?
    <http://vim.wikia.com/wiki/Keep_your_vimrc_file_clean>

* What's the difference between has() vs exists()?
    has(...) checks for compiled-in "features"
    exists(...) checks "options"

* what the what?
    Features    Vim's compile-time settings.
    Options     Built-in special variables for configurable settings.
    Registers   Classic Vi places to store things (e.g., from Normal-mode)
    Variables   Ex(?) / Vimscript places to store things.
    Mappings    Vim's Normal-/Visual-/...-mode programming (binds keystrokes to commands)
    Commands    Ex programming (user-defined or built-in)
    Functions   Vimscript programming

================================
====== Features ======

https://vi.stackexchange.com/a/22449


================================
====== Options ======
* What do those funny symbols on :set mean?
    :set foo    " turn foo on
    :set nofoo  " turn foo off
    :set invfoo " toggle foo
    :set foo!   " toggle foo
    :set foo&   " set foo to its default value
    :set foo?   " show the current value of foo


================================
====== Variables ======
* What do all those variations on :{n,v,i,}{nore,}map mean?
    the official story: <http://vimdoc.sourceforge.net/htmldoc/map.html>
    the full story:     <http://stackoverflow.com/a/11676244>
    the short version:  <http://stackoverflow.com/a/3776182>

* What do those {&,@,g:,w:,...} prefixes on variables mean?
    <https://codeyarns.com/2010/11/26/how-to-view-variables-in-vim/>
    <http://learnvimscriptthehardway.stevelosh.com/chapters/19.html>

* Using options as variables:
    Global Assignment   :set o=v        :let &o=v
    Local Assignment    :setlocal o=v   :let &l:o=v
    Echoing             :set o?         :echo &o
    Caveats:
    * `:set o=v` requires that v is a literal/constant value;
      whereas `:let &o=v` allows v to be an expression.
    * `:let &o=v` will set the *global* option, not the buffer option.
      to set the local option you need to say `:let &l:o=v`

* Using registers as variables:
    Assignment  "r{...}     :let @r=v
    Echoing                 :echo @r


================================
====== Mappings ======
* What does <silent> etc mean on key mappings?
    <http://vimdoc.sourceforge.net/htmldoc/map.html#:map-arguments>

* What about <expr> on mappings?
    <https://vi.stackexchange.com/a/6030>

* What about <buffer> on mappings?  And <leader> vs <localleader>
    <https://learnvimscriptthehardway.stevelosh.com/chapters/11.html>

* When do I need a trailing <CR> vs not?
    *mappings* need <CR>
        (to simulate the user hitting enter after typing the command)
    *commands* mustn't have <CR>
        (If you have it you'll get "E488: Trailing characters")
    <https://vi.stackexchange.com/q/4689>
    <https://vi.stackexchange.com/a/4690>

* How can I see what mappings are currently set/active?
    To get a short list (i.e., no combos)
        :redir! > vim_keys.txt
        :silent verbose map
        :redir END
    To get what they're set to In The Beginning
        :help index

================================
====== Commands ======


================================
====== Functions ======
* What the heck is s: or <SID> on function names?
    <http://vimdoc.sourceforge.net/htmldoc/map.html#<SID>>
    N.B., you only need to say <SID> when defining *mappings*.  When
    defining *commands* or just calling the function in an expression,
    you can say s: instead (and doing so is better style).

* Should I use ! for function definitions?
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

* Issues about adding "abort" to function definitions:
    <https://stackoverflow.com/q/13425648>
    <http://vimdoc.sourceforge.net/htmldoc/eval.html#except-compat>

* Vim 8.1.1310 allows true optional funargs (and with specified
    default values), but that's not supported by Neovim etc.
    <https://github.com/vim/vim/commit/42ae78cfff171fbd7412306083fe200245d7a7a6>


================================
====== Datatypes: Strings ======

* String comparison testing:
        ==?     case-insensitive
        ==#     case-sensitive
        ==      depends on the user's (no)ignorecase settings.
        Similarly for other comparators (<#, <?, >=#, etc)
    For scripting purposes never ever use ==, just as you should
    never ever use mappings without "nore"
    <https://learnvimscriptthehardway.stevelosh.com/chapters/22.html>

    Apparently newer versions of vim also introduce `is`/`is#`/`is?`.
    For lists/dicts that means pointer equality, but for strings
    I'm not sure whether/how it's different.
