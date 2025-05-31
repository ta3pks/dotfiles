cnoreabbrev <buffer> <silent> wq w<bar>Neorg return
cnoreabbrev <buffer> <silent> q Neorg return
nnoremap <buffer> <silent> <c-n> :call search('([- ])')<CR>
nnoremap <buffer> <silent> <c-p> :call search('([- ])','b')<CR>
nnoremap <buffer> <silent> <a-j> ddp
nnoremap <buffer> <silent> <a-k> ddkP
inoreabbrev <buffer> <silent> () ( )
