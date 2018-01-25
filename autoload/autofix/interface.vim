" TODO: maybe move fixer.prompt_apply_fixer to this interface

" autofix#interface#new provides an object which wraps user-interaction
" function calls in order to make testing easier
function! autofix#interface#new() abort
	let interface = {}
	let interface.echomsg = function('s:echomsg')
	let interface.echoerr = function('s:echoerr')
	return interface
endfunction

function! s:echomsg(msg) abort dict
	execute 'echomsg "' . a:msg . '"'
endfunction

function! s:echoerr(msg) abort dict
	execute 'echoerr "' . a:msg . '"'
endfunction
