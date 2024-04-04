function nvim --wraps=vim --description 'alias nvim=nvim'
	if test (count $argv) -eq 1 -a "$argv[1]" = "-"
		set -l arg  (fzf)
		command nvim  $arg
 else
	 command nvim $argv; 
 end
end
