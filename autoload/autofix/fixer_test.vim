let s:suite = themis#suite('autoload/autofix/fixer.vim')
let s:assert = themis#helper('assert')
call themis#helper('command').with(s:assert)

let s:name = 'test fixer name'
function! s:suite.before_each()
	let s:fixer = autofix#fixer#new_bare(s:name)
endfunction

function! s:suite.after_each()
	unlet s:fixer
endfunction

function! s:suite.test_new_bare()
	call s:assert.equals(s:fixer.name, s:name)
	call s:assert.equals(s:fixer.matchers, {}, 'should be initialized with empty matchers')
	call s:assert.is_function(s:fixer.visit_qfitem)
	call s:assert.is_function(s:fixer.check_match)
	call s:assert.is_function(s:fixer._generate_matcher_key)
endfunction

function! s:suite.test_with_exec()
	let newfixer = autofix#fixer#with_exec(s:fixer, '') " exec nothing
	call s:assert.is_function(newfixer.apply)
	call s:assert.equal(newfixer.apply({}), 1)

	let newfixer = autofix#fixer#with_exec(s:fixer, 'nonexistentcommand')
	call s:assert.is_function(newfixer.apply)
	Throws /Not an editor command: nonexistentcommand/ newfixer.apply({})
endfunction

function! s:suite.test_with_text_matcher()
	call s:assert.equal(len(s:fixer.matchers), 0)
	let pattern = "^missing ',' before newline"
	let newfixer = autofix#fixer#with_text_matcher(s:fixer, pattern)
	call s:assert.equal(len(newfixer.matchers), 1)
	call s:assert.is_function(newfixer.matchers.text_matcher_0)
	call s:assert.equal(0, newfixer.matchers.text_matcher_0({'text': 'unknown error'}))
	call s:assert.equal(1, newfixer.matchers.text_matcher_0({'text': "missing ',' before newline in argument list"}))
endfunction

function! s:suite.test_with_extension_matcher()
	call s:assert.equal(len(s:fixer.matchers), 0)
	let ext = "go"
	let newfixer = autofix#fixer#with_extension_matcher(s:fixer, ext)
	call s:assert.equal(len(newfixer.matchers), 1)
	call s:assert.is_function(newfixer.matchers.extension_matcher_0)
	open test.vim
	let bufnr = bufnr("%")
	call s:assert.equal(0, newfixer.matchers.extension_matcher_0({'bufnr': bufnr}))
	exec 'bdelete!' bufnr
	open test.go
	let bufnr = bufnr("%")
	call s:assert.equal(1, newfixer.matchers.extension_matcher_0({'bufnr': bufnr}))
	exec 'bdelete!' bufnr
endfunction

function! s:suite.test_visit_qfitem()
	open test.vim
	normal! iFirst Line
	normal! oSecond Line
	normal! oThird Line
	let bufnr = bufnr("%")
	let qfitem = {'bufnr': bufnr, 'lnum': 2, 'col': 3, 'valid': 1, 'vcol': 0}
	call cursor(0, 0)

	call s:fixer.visit_qfitem(qfitem)
	let cursor = getcurpos()
	call s:assert.equal(2, cursor[1])
	call s:assert.equal(3, cursor[2])

	exec 'bdelete!' bufnr
endfunction

function! s:suite.test_visit_qfitem_throws_on_invalid_qfitem()
	let qfitem = {'bufnr': 0, 'lnum': 0, 'col': 0, 'valid': 0, 'vcol': 0}
	let fixer = s:fixer
	Throws /Invalid quickfix item is passed to visit_qfitem/ fixer.visit_qfitem(qfitem)
endfunction

function! s:suite.test_check_match()
	let fixer = deepcopy(s:fixer)
	function! fixer.matchers.match_fizz(qfitem) abort
		return a:qfitem.nr % 3 == 0
	endfunction
	function! fixer.matchers.match_buzz(qfitem) abort
		return a:qfitem.nr % 5 == 0
	endfunction
	let i = 1
	while i <= 45
		let qfitem = {'nr': i}
		let fizzbuzz = i%15 == 0
		call s:assert.equals(fixer.check_match(qfitem), fizzbuzz)
		let i += 1
	endwhile
endfunction

function! s:suite.test_generate_matcher_key()
	let fixer = deepcopy(s:fixer)
	let prefix = "foo"
	call s:assert.equals(fixer._generate_matcher_key(prefix), prefix.'_0')
	call s:assert.equals(fixer._generate_matcher_key(prefix), prefix.'_0')
	let fixer.matchers = {'1': 1, '2': 2, '3': 3}
	call s:assert.equals(fixer._generate_matcher_key(prefix), prefix.'_3')
endfunction
