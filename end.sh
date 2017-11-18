ip tunnel del sit1
PULSE_PID=`cat /tmp/openconnect.pid`
kill $PULSE_PID
rm /tmp/openconnect.pid
