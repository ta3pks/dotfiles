function garbage-collect-pacman
	sudo pacman -Rsn (pacman -Qdtq)
end
