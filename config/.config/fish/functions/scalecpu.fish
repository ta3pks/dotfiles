function scalecpu
sudo cpupower -c all frequency-set -u  (echo "$argv[1]*1000000"|bc -l)
end
