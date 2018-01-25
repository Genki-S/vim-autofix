" TODO: Consider the appropriate undochain and jumplist while executing/canceling fixers

function! autofix#autofix(bang) abort
	if a:bang
		call autofix#apply_fixers(getqflist(), autofix#load_fixers_with_caching())
	else
		call autofix#apply_fixers_interactive(getqflist(), autofix#load_fixers_with_caching())
	endif
endfunction

function! autofix#autofix_current_loc(bang) abort
	if a:bang
		call autofix#apply_fixers(getloclist(winnr()), autofix#load_fixers_with_caching())
	else
		call autofix#apply_fixers_interactive(getloclist(winnr()), autofix#load_fixers_with_caching())
	endif
endfunction

function! autofix#apply_fixers(qflist, fixers) abort
	for qfitem in a:qflist
		for fixer in a:fixers
			if fixer.check_match(qfitem)
				call fixer.visit_qfitem(qfitem)
				call fixer.apply(qfitem)
			endif
		endfor
	endfor
endfunction

function! autofix#apply_fixers_interactive(qflist, fixers) abort
	" show cursorline/column to indicate where a fixer is being applied
	let save_cursorline=&cursorline
	let save_cursorcolumn=&cursorcolumn
	set cursorline
	set cursorcolumn

	let l:quit = 0
	for qfitem in a:qflist
		for fixer in a:fixers
			if fixer.check_match(qfitem)
				call fixer.visit_qfitem(qfitem)
				redraw

				let choice = fixer.prompt_apply_fixer()
				if choice == "Yes"
					call fixer.apply(qfitem)
					redraw
				elseif choice == "Quit"
					let l:quit = 1
					break
				endif
			endif
		endfor

		if l:quit
			break
		endif
	endfor

	let &cursorline = save_cursorline
	let &cursorcolumn = save_cursorcolumn
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
