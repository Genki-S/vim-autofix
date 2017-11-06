let s:fixer = autofix#fixer#new_bare('go#colon_equal_to_equal')

function! autofix#fixers#go#colon_equal_to_equal#define() abort
	return s:fixer
endfunction

let s:fixer = autofix#fixer#with_matcher_extension(s:fixer, 'go')
" This is most likely because the LHS is already defined
let s:fixer = autofix#fixer#with_matcher_text(s:fixer, 'expected identifier on left side of :=')
" So we are substituting short variable declaration operator to assignment operator
let s:fixer = autofix#fixer#with_apply_exec(s:fixer, 's/:=/=/')

let s:fixer._private = {}
let s:fixer._private.default = 1
