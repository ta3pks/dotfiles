function mx-natural-scroll
	set -l mxid (xinput list | grep -io "Vertical.*pointer" | grep -o "id=[0-9]\+"|grep -o "[0-9]\+")
	if test ! $mxid
		echo "no mx mouse found"
		return
	end
	xinput set-prop $mxid "libinput Natural Scrolling Enabled" 1
end
