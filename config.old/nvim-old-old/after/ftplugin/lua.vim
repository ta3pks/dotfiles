nnoremap \e :exe 'vsp\|term lua %'\|norm! i<cr>
nnoremap <silent> <c-m-l> :w\|silent !stylua % <cr>
nnoremap <silent> \l :silent !love "%:h"&<cr>
nnoremap <buffer><silent> <leader>vle :lua Exe_current_viml_line()<cr>
vnoremap <buffer><silent> <leader>ve :lua Exe_current_lua_selection()<cr>
nnoremap <buffer>Q <Cmd>call <sid>KillLuapadOrNormalCloseBuffer()<cr>

function! s:KillLuapadOrNormalCloseBuffer() 
	if stridx(bufname(),'Luapad') > -1
	quit
	else
	lua require"keymaps".close_buffer()
	endif
endfunction
