#! /bin/sh
### BEGIN INIT INFO
# Provides:          dnscrypt-proxy
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: dnscrypt-proxy
# Description:       dnscrypt-proxy secure DNS client
### END INIT INFO

# Author: Simon Clausen <kontakt@simonclausen.dk> 

PATH=/usr/sbin:/usr/bin:/sbin:/bin
DAEMON=/usr/local/sbin/dnscrypt-proxy
NAME=dnscrypt-proxy
ADDRESS1=185.19.104.45
ADDRESS2=185.19.105.6
PNAME1=2.dnscrypt-cert.ns8.uk.dns.opennic.glue
PNAME2=2.dnscrypt-cert.ns9.uk.dns.opennic.glue 
PKEY1=A17C:06FC:BA21:F2AC:F4CD:9374:016A:684F:4F56:564A:EB30:A422:3D9D:1580:A461:B6A6
PKEY2=E864:80D9:DFBD:9DB4:58EA:8063:292F:EC41:9126:8394:BC44:FAB8:4B6E:B104:8C3B:E0B4 

case "$1" in
  start)
    echo "Starting $NAME"
    $DAEMON --daemonize --user=dnscrypt --local-address=127.0.0.1 --resolver-address=$ADDRESS1 --provider-name=$PNAME1 --provider-key=$PKEY1
	$DAEMON --daemonize --user=dnscrypt --local-address=127.0.0.2 --resolver-address=$ADDRESS2 --provider-name=$PNAME2 --provider-key=$PKEY2
    ;;
  stop)
    echo "Stopping $NAME"
    pkill -f dnscrypt-proxy
    ;;
  *)
    echo "Usage: /etc/init.d/dnscrypt-proxy {start|stop}"
    exit 1
    ;;
esac

exit 0
