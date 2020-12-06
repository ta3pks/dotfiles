set_brightness()
{
	_b_file="/sys/class/leds/smc::kbd_backlight/brightness"
	_b=`cat $_b_file`
	if [ $1 = "+" ]
	then
		_b=$((_b+5))
		echo $_b > $_b_file
	elif [ $1 = "-" ]
	then
		_b=$((_b-5))
		echo $_b | tee $_b_file
		[ $? -ne 0 ] && echo 0 > $_b_file
	else
		echo unknown value $1
	fi
}

set_brightness $1
