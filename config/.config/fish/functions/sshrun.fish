# Defined in /tmp/fish.l1KIqU/sshrun.fish @ line 1
function sshrun
parallel "ssh root@{} $argv" ::: $HOSTS
end
