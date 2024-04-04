nnoremap <buffer><Leader>e :!sh %<cr>
nnoremap <buffer><Leader>t :exe "vsp\|term bats " . expand ('%:p:r') . "_test.sh" \| normal i<cr>
"templates
inoremap <buffer> {{{}}} #{{{	#}}}
