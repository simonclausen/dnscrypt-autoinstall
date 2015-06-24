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

case "$1" in
  start)
    echo "Starting $NAME"
    $DAEMON --daemonize --ephemeral-keys --user=dnscrypt -R OpenDNS
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
