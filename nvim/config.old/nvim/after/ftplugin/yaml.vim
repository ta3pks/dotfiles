" if name contains playbook
if expand('%:p') =~ 'playbook'
    nnoremap <buffer> <leader>ee :vsp<bar>term ansible-playbook %:p<CR>
endif
