let s:fixer = autofix#fixer#new_bare('go#missing_comma')

function! autofix#fixers#go#missing_comma#define() abort
	return s:fixer
endfunction

let s:fixer = autofix#fixer#with_extension_matcher(s:fixer, 'go')
let s:fixer = autofix#fixer#with_text_matcher(s:fixer, "missing ',' before newline.*")
let s:fixer = autofix#fixer#with_exec(s:fixer, 'normal! A,')

let s:fixer._private = {}
let s:fixer._private.default = 1
