PID_ADDR="/tmp/xflux.pid"
LAT=41.6538624
LONG=41.6342015
stop()
{
	if [ -f $PID_ADDR ] 
	then
		cat $PID_ADDR | xargs kill
		rm $PID_ADDR
	fi
}
start()
{
		xflux -l $LAT  -g $LONG -k 2000 > $PID_ADDR
		sed -nui 's/.*kill \([0-9]\{3,5\}\).*/\1/p' $PID_ADDR
}
case $1 in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		stop
		start
		;;
esac
