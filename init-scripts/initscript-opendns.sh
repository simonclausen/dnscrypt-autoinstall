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
ADDRESS1=208.67.220.220
ADDRESS2=208.67.222.123
PNAME1=2.dnscrypt-cert.opendns.com
PNAME2=2.dnscrypt-cert.opendns.com
PKEY=B735:1140:206F:225D:3E2B:D822:D7FD:691E:A1C3:3CC8:D666:8D0C:BE04:BFAB:CA43:FB79

case "$1" in
  start)
    echo "Starting $NAME"
    $DAEMON --daemonize --user=dnscrypt --local-address=127.0.0.1 --resolver-address=$ADDRESS1 --provider-name=$PNAME1 --provider-key=$PKEY
$DAEMON --daemonize --user=dnscrypt --local-address=127.0.0.2 --resolver-address=$ADDRESS2 --provider-name=$PNAME2 --provider-key=$PKEY
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
