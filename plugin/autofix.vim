if exists('g:loaded_autofix')
	finish
endif
let g:loaded_autofix = 1
let s:save_cpo = &cpo
set cpo&vim

command! -nargs=0 -bar Autofix call autofix#autofix()
command! -nargs=0 -bar AutofixLoc call autofix#autofix_current_loc()
command! -nargs=0 -bar AutofixReloadFixers call autofix#reload_fixers()

let &cpo = s:save_cpo
unlet s:save_cpo
