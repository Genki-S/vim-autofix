# vim-autofix

Automatically fix quickfix items with predefined/customizable "Fixers".

![demo.gif](https://user-images.githubusercontent.com/1609598/35377941-66f656e4-01f4-11e8-924d-1998aac6447a.gif)

## Introduction

vim-autofix lets you fix QuickFix errors with "Fixers".

"Fixer" is a thing which can 1. match QuickFix error and 2. fix the error.

This plugin comes with some default Fixers, and plugin users can easily add
their own Fixers. For how to define your own fixer, please refer to
"Defining your fixers" section below.

## Usage

vim-autofix defines some commands described in the help file. Use them
as-is, or define mappings yourself to make it easier to invoke. For example:

```vim
  " "fq" for fix quickfix items
  nnoremap <silent> <Leader>fq :<C-u>Autofix<CR>
  " "fl" for fix locationlist items
  nnoremap <silent> <Leader>fl :<C-u>AutofixLoc<CR>
```

For the list of commands, please see `:h autofix-commands`

## Defining your fixers

Users can add their own fixers without touching this plugin. This section
describes step-by-step instruction for defining custom fixers.
For example Fixer definitions, please see files in `autoload/autofix/fixers`
under vim-autofix installation directory.

### Placing Fixer files

vim-autofix sources Fixers that can be found by the following:

```vim
  globpath(&runtimepath, 'autoload/autofix/fixers/**/*.vim')
```

This means, you can define your Fixers under "$HOME/.vim/autoload/fixers"
directory. For example, you can place your Fixer files as follows:

```
  $HOME/.vim
  └── autoload
      └── fixers
          ├── your_fixer.vim
          └── subdir
              └── your_another_fixer.vim
```

### Defining a Fixer

vim-autofix expects Fixer definition files to provide a function named
`autofix#fixers#{SUBDIR_AND_FILE_NAME}#define`. This function will be called
by vim-autofix to get your Fixer.

Let's take the fixer definition files illustrated above as an example.

Define the following function in `your_fixer.vim`:

```vim
  function! autofix#fixers#your_fixer#define() abort
    return s:fixer
  endfunction
```

And define the following function in `your_another_fixer.vim`:

```vim
  function! autofix#fixers#subdir#your_another_fixer#define() abort
    return s:fixer
  endfunction
```

You will configure your s:fixer's in the following section.

### Configuring a Fixer

A Fixer is a dictionary containing some required fields and some optional
fields. Use the following function to create a new Fixer:

```vim
  let s:fixer = autofix#fixer#new_bare('your fixer name')
```

You have to at least define "matcher" functions and an "apply" function.
Matcher functions are used to match against quickfix errors to determine if
a Fixer is applicable to an error. An apply function is the operation which
fixes the error.  Both of these functions gets qfitem as an argument, qfitem
is a dictionary obtained by calling `getqflist()` or `getloclist()` vim
functions.

For example, define the following functions to match the golang error
`"missing ',' before newline"` and fix it:

```vim
  " whatever works for the function name ("match_missing_comma" in this case)
  " as long as they are unique
  function! s:fixer.matchers.match_missing_comma(qfitem) abort dict closure
    return match(a:qfitem.text, pattern) != -1',
  endfunction'

  " when you define multiple matcher functions under s:fixer.matchers, all the
  " matcher functions should return truethy for the fixer to take effect

  function! s:fixer.apply(qfitem) abort dict closure
    " vim-autofix brings cursor to quickfix item location before calling apply
    " so just exec'ing is fine
    exec "normal! A,"
    " return truethy to signal the apply was successful
    return 1
  endfunction
```
