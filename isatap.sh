ip tunnel del sit1
#PULSE_PID=`cat /tmp/openconnect.pid`
#kill $PULSE_PID
#rm /tmp/openconnect.pid

NS_IP=`dig +short dns.tsinghua.edu.cn @114.114.114.114`
PULSE_IP=`dig +short sslvpn.tsinghua.edu.cn @$NS_IP`
PULSE_USERNAME=`cat tsinghua_username`
PULSE_PASSWD=`cat tsinghua_passwd`
nohup /usr/local/pulse/PulseClient.sh -h sslvpn.tsinghua.edu.cn -u $PULSE_USERNAME -p $PULSE_PASSWD -r ldap > /dev/null 2>&1 &
PULSE_PID=$!
#echo $PULSE_PASSWD | openconnect -b --pid-file=/tmp/openconnect.pid --user=$PULSE_USERNAME --no-cert-check --juniper $PULSE_IP
while ! ifconfig | grep "tun0" > /dev/null; do
  sleep 1
  if ! ps -p $PULSE_PID > /dev/null; then 
    nohup /usr/local/pulse/PulseClient.sh -h sslvpn.tsinghua.edu.cn -u $PULSE_USERNAME -p $PULSE_PASSWD -r ldap > /dev/null 2>&1 &
    PULSE_PID=$!
  fi
done

TSINGHUA_IP=`ifconfig tun0 | grep inet | awk '{print $2}'`
ISATAP_IP=`dig +short isatap.tsinghua.edu.cn @$NS_IP`

ip tunnel add sit1 mode sit remote $ISATAP_IP local $TSINGHUA_IP
ifconfig sit1 up
ifconfig sit1 add fe80::200:5efe:$TSINGHUA_IP/64
ifconfig sit1 add 2402:f000:1:1501:200:5efe:$TSINGHUA_IP/64

ip route add ::/0 via 2402:f000:1:1501:200:5efe:$ISATAP_IP metric 1
ip route add 115:2000::/32 via 115:2000:1::1

ip6tables -t nat -A POSTROUTING -o sit1 -s 115:2000::/32 -j MASQUERADE
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
