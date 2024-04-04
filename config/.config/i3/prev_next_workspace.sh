test -f /tmp/current_workspace || echo 1>/tmp/current_workspace
a=`cat /tmp/current_workspace|xargs printf`
case $1 in
	-)
		a=$(( (a-1)%11 ))
		[ $a -lt 1 ] && a=10
		;;
	+)
		a=$(( ( a%10 )+1 ))
		;;
	*)
		exit 1
esac
echo $a>/tmp/current_workspace
i3-msg workspace $a
