# Defined in /tmp/fish.OFCQIP/applefnmode.fish @ line 1
function applefnmode
	if test (count $argv) -eq 0 
		echo "default 2"
		set fnmode 2
	else
		set fnmode $argv[1]
	end
	echo $fnmode | sudo tee   /sys/module/hid_apple/parameters/fnmode
end
