nnoremap \e :exe 'vsp\|term lua %'\|norm! i<cr>
nnoremap <silent> <c-m-l> :w\|silent !stylua % <cr>
nnoremap <silent> \l :silent !love "%:h"&<cr>
