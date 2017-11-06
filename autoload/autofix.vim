function! autofix#autofix() abort
	call autofix#apply_fixers(getqflist(), autofix#load_fixers_with_caching())
endfunction

function! autofix#autofix_current_loc() abort
	call autofix#apply_fixers(getloclist(winnr()), autofix#load_fixers_with_caching())
endfunction

function! autofix#apply_fixers(qflist, fixers) abort
	for qfitem in a:qflist
		for fixer in a:fixers
			if fixer.check_match(qfitem)
				" TODO: Prompt users before applying fixers (control with bang)
				call fixer.visit_qfitem(qfitem)
				call fixer.apply(qfitem)
			endif
		endfor
	endfor
endfunction

function! autofix#load_fixers_with_caching() abort
	if exists('s:fixers')
		return s:fixers
	endif
	let s:fixers = s:load_fixers()
	return s:fixers
endfunction

function! autofix#reload_fixers() abort
	let s:fixers = s:load_fixers()
endfunction

function! s:load_fixers() abort
	let fixers = []
	let fixer_files = split(globpath(&runtimepath, 'autoload/autofix/fixers/**/*.vim'), '\n')
	" TODO: Make it possible to ignore fixers with g:autofix#fixers#ignored
	for file in fixer_files
		let path = substitute(matchstr(file, 'autofix/fixers/\zs.*\ze.vim'), '/', '#', 'g')
		let fixer = autofix#fixers#{path}#define()
		call extend(fixers, [fixer])
	endfor
	return fixers
endfunction
