function connectwifi
	if test -z $argv[1]
		set _iface "wlp4s0"
	else 
		set _iface $argv[1]
	end
	sudo wpa_supplicant -i $_iface -c ~/.config/wpa_supplicant.conf -B
	sudo dhcpcd
end
