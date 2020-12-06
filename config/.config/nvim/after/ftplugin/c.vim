nnoremap <leader>e  :call RunCLang()<cr>
nnoremap <leader>ct  :call C_TEST()<cr>
inoreabbr <> #include <:%lib%:.h>
inoreabbr incl #include ":%lib%:.h"
func! C_TEST()
	vsp
	term make test
	normal i
endfunction
func! RunCLang()
	vsp
	term gcc -g % && ./a.out
	normal i
endfunction
