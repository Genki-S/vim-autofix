let s:fixer = autofix#fixer#new_bare('go#missing_comma')

function! autofix#fixers#go#missing_comma#define() abort
	return s:fixer
endfunction

let s:fixer = autofix#fixer#with_matcher_extension(s:fixer, 'go')
let s:fixer = autofix#fixer#with_matcher_text(s:fixer, "missing ',' before newline.*")
let s:fixer = autofix#fixer#with_apply_exec(s:fixer, 'normal! A,')

let s:fixer._private = {}
let s:fixer._private.default = 1
