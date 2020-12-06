a=`cat /tmp/current_workspace|xargs printf`
case $1 in
	-)
		a=$(( (a-1)%11 ))
		[ $a -lt 0 ] && a=10
		;;
	+)
		a=$(( (a+1)%11 ))
		;;
	*)
		exit 1
esac
echo $a>/tmp/current_workspace
i3-msg workspace $a
