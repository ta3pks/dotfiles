#!/usr/bin/fish
set --local	_b_file "/sys/class/backlight/gmux_backlight/brightness"
set --local _b (cat $_b_file)
if  test "$argv[1]" = "+" 
	set _b (math "$_b+20")
	echo $_b |tee $_b_file
else if  test "$argv[1]" = "-" 
	set	_b (math "$_b-20")
	echo $_b |tee $_b_file
	if test $status -ne 0
		echo 0 > $_b_file
end
else
	echo unknown value $1
end
