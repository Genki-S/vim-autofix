let s:suite = themis#suite('autoload/autofix/fixer.vim')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
endfunction

function! s:suite.after_each()
endfunction

function! s:suite.test_apply_fixers()
	let fizz_fixer = autofix#fixer#new_bare('test-fixer')
	let fizz_fixer_visited_count = 0
	let fizz_fixer_applied_count = 0
	function! fizz_fixer.matchers.match_fizz(qfitem) abort
		return a:qfitem.nr % 3 == 0
	endfunction
	function! fizz_fixer.visit_qfitem(qfitem) abort closure
		let fizz_fixer_visited_count += 1
		return 1
	endfunction
	function! fizz_fixer.apply(qfitem) abort closure
		let fizz_fixer_applied_count += 1
		return 1
	endfunction
	let buzz_fixer = autofix#fixer#new_bare('test-fixer')
	let buzz_fixer_visited_count = 0
	let buzz_fixer_applied_count = 0
	function! buzz_fixer.matchers.match_buzz(qfitem) abort
		return a:qfitem.nr % 5 == 0
	endfunction
	function! buzz_fixer.visit_qfitem(qfitem) abort closure
		let buzz_fixer_visited_count += 1
		return 1
	endfunction
	function! buzz_fixer.apply(qfitem) abort closure
		let buzz_fixer_applied_count += 1
		return 1
	endfunction

	let qflist = []
	let i = 1
	while i <= 30
		let qfitem = { 'nr': i }
		call extend(qflist, [qfitem])
		let i += 1
	endwhile
	call autofix#apply_fixers(qflist, [fizz_fixer, buzz_fixer])

	call s:assert.equals(fizz_fixer_visited_count, 30 / 3)
	call s:assert.equals(fizz_fixer_applied_count, 30 / 3)
	call s:assert.equals(buzz_fixer_visited_count, 30 / 5)
	call s:assert.equals(buzz_fixer_applied_count, 30 / 5)
endfunction

function! s:suite.test_load_fixers()
	let save_rtp = &runtimepath
	let &runtimepath = join(filter(
				\ split(&runtimepath, ','),
				\ 'v:val =~# "vim-autofix"'
				\ ), ',')
	let loaded = autofix#load_fixers()
	let target = filter(loaded, 'v:val.name ==# "go#missing_comma"')
	call s:assert.equals(len(target), 1)
	let &runtimepath = save_rtp
endfunction
