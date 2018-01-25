" TODO: Consider the appropriate undochain and jumplist while executing/canceling fixers

function! autofix#autofix(bang) abort
	let interface = autofix#interface#new()
	if a:bang
		call autofix#apply_fixers(getqflist(), autofix#load_fixers_with_caching(), interface)
	else
		call autofix#apply_fixers_interactive(getqflist(), autofix#load_fixers_with_caching(), interface)
	endif
endfunction

function! autofix#autofix_current_loc(bang) abort
	let interface = autofix#interface#new()
	if a:bang
		call autofix#apply_fixers(getloclist(winnr()), autofix#load_fixers_with_caching(), interface)
	else
		call autofix#apply_fixers_interactive(getloclist(winnr()), autofix#load_fixers_with_caching(), interface)
	endif
endfunction

function! autofix#apply_fixers(qflist, fixers, interface) abort
	let found = 0
	for qfitem in a:qflist
		for fixer in a:fixers
			if fixer.check_match(qfitem)
				let found = 1
				call fixer.visit_qfitem(qfitem)
				call fixer.apply(qfitem)
			endif
		endfor
	endfor

	if !found
		call a:interface.echomsg("vim-autofix: nothing to do")
	endif
endfunction

function! autofix#apply_fixers_interactive(qflist, fixers, interface) abort
	" show cursorline/column to indicate where a fixer is being applied
	let save_cursorline=&cursorline
	let save_cursorcolumn=&cursorcolumn
	set cursorline
	set cursorcolumn

	let found = 0
	let l:quit = 0
	for qfitem in a:qflist
		for fixer in a:fixers
			if fixer.check_match(qfitem)
				let found = 1

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

	if !found
		call a:interface.echomsg("vim-autofix: nothing to do")
	endif

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

" for testing
function! autofix#_clear_loaded_fixers() abort
	if exists('s:fixers')
		unlet s:fixers
	endif
endfunction

function! s:load_fixers() abort
	let fixers = []
	let fixer_files = split(globpath(&runtimepath, 'autoload/autofix/fixers/**/*.vim'), '\n')
	for file in fixer_files
		let path = substitute(matchstr(file, 'autofix/fixers/\zs.*\ze.vim'), '/', '#', 'g')
		let fixer = autofix#fixers#{path}#define()
		if get(g:, 'autofix#ignore_default_fixers', 0) && fixer._private.default
			continue
		endif
		call extend(fixers, [fixer])
	endfor
	return fixers
endfunction
