let s:suite = themis#suite('autoload/autofix/fixer.vim')
let s:assert = themis#helper('assert')
call themis#helper('command').with(s:assert)

function! s:suite.before_each() abort
endfunction

function! s:suite.after_each() abort
endfunction

function! s:suite.test_apply_fixers() abort
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

function! s:suite.test_load_fixers_with_caching_and_reload_fixers() abort
	let save_rtp = &runtimepath
	let &runtimepath = join(filter(
				\ split(&runtimepath, ','),
				\ 'v:val =~# "vim-autofix"'
				\ ), ',')
	let loaded = autofix#load_fixers_with_caching()
	let target = filter(loaded, 'v:val.name ==# "go#missing_comma"')
	call s:assert.equals(len(target), 1, 'target fixer should be loaded')

	let &runtimepath = ''
	let loaded = autofix#load_fixers_with_caching()
	" Should load from cached content
	call s:assert.equals(len(target), 1, 'target fixer should be loaded')

	call autofix#reload_fixers()
	let loaded = autofix#load_fixers_with_caching()
	call s:assert.equals(len(loaded), 0)

	let &runtimepath = save_rtp
endfunction
