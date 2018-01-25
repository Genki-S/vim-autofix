function! autofix#fixer#new_bare(name) abort
	let fixer = {}
	let fixer.name = a:name
	let fixer.visit_qfitem = function('s:visit_qfitem')
	let fixer.check_match = function('s:check_match')
	let fixer.prompt_apply_fixer = function('s:prompt_apply_fixer')
	let fixer.matchers = {}

	let fixer._generate_matcher_key = function('s:generate_matcher_key')
	return fixer
endfunction

function! autofix#fixer#with_apply_exec(fixer, exec) abort
	let newfixer = deepcopy(a:fixer)
	let exec = a:exec
	function! newfixer.apply(qfitem) abort dict closure
		exec exec
		return 1
	endfunction
	return newfixer
endfunction

function! autofix#fixer#with_matcher_text(fixer, pattern) abort
	let newfixer = deepcopy(a:fixer)
	let pattern = a:pattern
	let key = newfixer._generate_matcher_key('text_matcher')
	exec join([
				\ 'function! newfixer.matchers.'.key.'(qfitem) abort dict closure',
				\ '  return match(a:qfitem.text, pattern) != -1',
				\ 'endfunction'
				\ ], "\n")
	return newfixer
endfunction

function! autofix#fixer#with_matcher_extension(fixer, ext) abort
	let newfixer = deepcopy(a:fixer)
	let ext = a:ext
	let key = newfixer._generate_matcher_key('extension_matcher')
	exec join([
				\ 'function! newfixer.matchers.'.key.'(qfitem) abort dict closure',
				\ '  return match(bufname(a:qfitem.bufnr), "\.".ext."$") != -1',
				\ 'endfunction'
				\ ], "\n")
	return newfixer
endfunction

function! s:visit_qfitem(qfitem) abort dict
	if !a:qfitem.valid
		throw 'Invalid quickfix item is passed to visit_qfitem'
	endif
	if a:qfitem.vcol
		" TODO: Figure out what this means and handle appropriately
	endif
	exec 'buffer' a:qfitem.bufnr
	call cursor(a:qfitem.lnum, a:qfitem.col)
endfunction

function! s:check_match(qfitem) abort dict
	let ok = 1
	for k in keys(self.matchers)
		let ok = ok && self.matchers[k](a:qfitem)
		if !ok
			return 0
		endif
	endfor
	return 1
endfunction

function! s:prompt_apply_fixer() abort dict
	let msg = 'Apply fixer "' . self.name . '"?'
	let choice = 0
	while choice == 0
		let choice = confirm(msg, "&Yes\n&No\n&Quit", 0)
	endwhile
	let to_name = {1: "Yes", 2: "No", 3: "Quit"}
	return to_name[choice]
endfunction

function! s:generate_matcher_key(prefix) abort dict
	let n = len(self.matchers)
	return a:prefix . '_' . n
endfunction
