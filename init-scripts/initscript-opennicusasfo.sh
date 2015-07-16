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

# Authors: https://github.com/simonclausen/dnscrypt-autoinstall/graphs/contributors
# Project site: https://github.com/simonclausen/dnscrypt-autoinstall

PATH=/usr/sbin:/usr/bin:/sbin:/bin
DAEMON=/usr/local/sbin/dnscrypt-proxy
NAME=dnscrypt-proxy
ADDRESS=104.245.33.185
PNAME=2.fvz-rec-us-ca-02.dnscrypt-cert.meo.ws
PKEY=9DF8:E6F0:2434:C1D2:A76D:578C:113D:26C8:8FAC:9CBB:8E22:86FF:D8A4:4317:467C:5469

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
