nnoremap \e :exe "vsp\|term nasm -f elf64 -o /tmp/out.o % && ld /tmp/out.o -o /tmp/out.as&&/tmp/out.as"\|normal! i<cr>
