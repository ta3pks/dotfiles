nnoremap \fr :FlutterHotRestart<cr>
nnoremap \fs :FlutterRun<cr>
nnoremap \fq :FlutterQuit<cr>
nnoremap \fv :FlutterVSplit<cr>
nnoremap \fh :FlutterSplit<cr>
nnoremap \fd :FlutterVisualDebug<cr>
nnoremap \fa :vsp \| exe 'term flutter analyze'\|normal! i<cr>
setl wildignore+=*/build/*,*.png
setl foldmethod=indent
