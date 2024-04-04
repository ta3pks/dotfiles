img="$HOME/bg_images/$(ls ~/bg_images/|sort -R|head -n1)"
convert $img -resize $(xdpyinfo | grep dimensions | grep "[0-9]\+x[0-9]\+ p" -o | cut -d " " -f1) /tmp/bg.png
i3lock -i "/tmp/bg.png"
