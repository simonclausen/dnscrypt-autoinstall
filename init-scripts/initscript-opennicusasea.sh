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
ADDRESS=23.226.230.72
PNAME=2.fvz-rec-us-wa-01.dnscrypt-cert.meo.ws
PKEY=48D8:70BF:2833:49E8:59AC:DD12:2D49:F119:DA7E:1CAB:A2D3:B9C0:F573:133D:8BC1:A26E

case "$1" in
  start)
    echo "Starting $NAME"
    $DAEMON --daemonize --ephemeral-keys --user=dnscrypt --resolver-address=$ADDRESS --provider-name=$PNAME --provider-key=$PKEY
    ;;
  stop)
    echo "Stopping $NAME"
    pkill -f $DAEMON
    ;;
  restart)
    $0 stop
    $0 start
    ;;
  *)
    echo "Usage: /etc/init.d/dnscrypt-proxy {start|stop|restart}"
    exit 1
    ;;
esac

exit 0
