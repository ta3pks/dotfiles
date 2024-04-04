# Defined in /tmp/fish.r2mjaL/governcpu.fish @ line 2
function governcpu
	if test -z $argv[1]
		cpupower frequency-info -g
	else
		sudo cpupower -c all frequency-set -g $argv[1]
	end
end
