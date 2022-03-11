function nvim --wraps=vim --description 'alias nvim=nvim'
	if test (count $argv) -eq 0
		set -l arg  (fzf)
		command nvim  $arg
 else
	 command nvim $argv; 
 end
end
