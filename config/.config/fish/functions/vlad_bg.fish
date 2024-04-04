function vlad_bg
if test -z "$argv[1]"
	echo "missing name"
	return
end
	curl "https://vlad.studio/fullscreen-preview/?filename=$argv[1]&screen_width=1920&screen_height=1080" -L -o /tmp/file
	convert /tmp/file "$HOME/bg_images/$argv[1].png"
end
