let b:ale_fixers = ['pgformatter']
let b:ale_linters= []
let g:sql_type_default = 'pgsql'
" set ft = "pgsql"
nnoremap \e :exe 'vsp \| exe "term PGPASSWORD=postgres psql -h localhost -U postgres -f ".expand("%") \| norm! i' <cr>
nnoremap \c :vsp \| exe "term PGPASSWORD=postgres psql -h localhost -U postgres " \| norm! i <cr>
