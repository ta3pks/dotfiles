function vlad_bg
if test -z "$argv[1]"
	echo "missing name"
	return
end
	curl "https://vlad.studio/fullscreen-preview/?f=$argv[1]&w=1920&h=1080" -o /tmp/file
	convert /tmp/file "$HOME/bg_images/$argv[1].png"
end
