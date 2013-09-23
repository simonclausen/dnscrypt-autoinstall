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
ADDRESS=113.20.6.2
PNAME=2.dnscrypt-cert.cloudns.com.au
PKEY=1971:7C1A:C550:6C09:F09B:ACB1:1AF7:C349:6425:2676:247F:B738:1C5A:243A:C1CC:89F4

case "$1" in
  start)
    echo "Starting $NAME"
    $DAEMON --daemonize --user=dnscrypt --resolver-address=$ADDRESS --provider-name=$PNAME --provider-key=$PKEY
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