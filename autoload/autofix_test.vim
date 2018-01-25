let s:suite = themis#suite('autoload/autofix/fixer.vim')
let s:assert = themis#helper('assert')
call themis#helper('command').with(s:assert)

function! s:suite.before_each() abort
	let s:fizz_fixer = autofix#fixer#new_bare('test-fixer')
	let s:fizz_fixer_visited_count = 0
	let s:fizz_fixer_applied_count = 0
	function! s:fizz_fixer.matchers.match_fizz(qfitem) abort
		return a:qfitem.nr % 3 == 0
	endfunction
	function! s:fizz_fixer.visit_qfitem(qfitem) abort closure
		let s:fizz_fixer_visited_count += 1
		return 1
	endfunction
	function! s:fizz_fixer.apply(qfitem) abort closure
		let s:fizz_fixer_applied_count += 1
		return 1
	endfunction
	let s:buzz_fixer = autofix#fixer#new_bare('test-fixer')
	let s:buzz_fixer_visited_count = 0
	let s:buzz_fixer_applied_count = 0
	function! s:buzz_fixer.matchers.match_buzz(qfitem) abort
		return a:qfitem.nr % 5 == 0
	endfunction
	function! s:buzz_fixer.visit_qfitem(qfitem) abort closure
		let s:buzz_fixer_visited_count += 1
		return 1
	endfunction
	function! s:buzz_fixer.apply(qfitem) abort closure
		let s:buzz_fixer_applied_count += 1
		return 1
	endfunction

	let s:qflist_length = 30
	let s:qflist = []
	let i = 1
	while i <= s:qflist_length
		let qfitem = { 'nr': i }
		call extend(s:qflist, [qfitem])
		let i += 1
	endwhile
endfunction

function! s:suite.after_each() abort
endfunction

function! s:suite.test_apply_fixers() abort
	call autofix#apply_fixers(s:qflist, [s:fizz_fixer, s:buzz_fixer])

	call s:assert.equals(s:fizz_fixer_visited_count, s:qflist_length / 3)
	call s:assert.equals(s:fizz_fixer_applied_count, s:qflist_length / 3)
	call s:assert.equals(s:buzz_fixer_visited_count, s:qflist_length / 5)
	call s:assert.equals(s:buzz_fixer_applied_count, s:qflist_length / 5)
endfunction

function! s:suite.test_apply_fixers_interactive() abort
	function! s:fizz_fixer.prompt_apply_fixer() abort closure
		return "Yes"
	endfunction
	function! s:buzz_fixer.prompt_apply_fixer() abort closure
		return "No"
	endfunction

	call autofix#apply_fixers_interactive(s:qflist, [s:fizz_fixer, s:buzz_fixer])

	call s:assert.equals(s:fizz_fixer_visited_count, s:qflist_length / 3)
	call s:assert.equals(s:fizz_fixer_applied_count, s:qflist_length / 3)
	call s:assert.equals(s:buzz_fixer_visited_count, s:qflist_length / 5)
	call s:assert.equals(s:buzz_fixer_applied_count, 0)
endfunction

function! s:suite.test_apply_fixers_interactive_quit() abort
	function! s:fizz_fixer.prompt_apply_fixer() abort closure
		return "Quit"
	endfunction

	call autofix#apply_fixers_interactive(s:qflist, [s:fizz_fixer, s:buzz_fixer])

	call s:assert.equals(s:fizz_fixer_visited_count, 1)
	call s:assert.equals(s:fizz_fixer_applied_count, 0)
	call s:assert.equals(s:buzz_fixer_visited_count, 0)
	call s:assert.equals(s:buzz_fixer_applied_count, 0)
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
