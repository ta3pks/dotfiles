nnoremap <buffer><space>ot <Cmd>lua require("orgmode").action("org_mappings.insert_todo_heading_respect_content")<CR>
nnoremap <buffer><space>oxi <Cmd>lua require("orgmode").action("clock.org_clock_in")<CR>
nnoremap <buffer><space>oxo <Cmd>lua require("orgmode").action("clock.org_clock_out")<CR>
nnoremap <buffer><space>oxj <Cmd>lua require("orgmode").action("clock.org_clock_goto")<CR>
nnoremap <buffer><space>oxq <Cmd>lua require("orgmode").action("clock.org_clock_cancel")<CR>
