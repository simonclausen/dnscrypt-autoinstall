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
ADDRESS1=113.20.6.2
ADDRESS2=113.20.8.17
PNAME1=2.dnscrypt-cert.cloudns.com.au
PNAME2=2.dnscrypt-cert-2.cloudns.com.au
PKEY1=1971:7C1A:C550:6C09:F09B:ACB1:1AF7:C349:6425:2676:247F:B738:1C5A:243A:C1CC:89F4
PKEY2=67A4:323E:581F:79B9:BC54:825F:54FE:1025:8B4F:37EB:0D07:0BCE:4010:6195:D94F:E330

case "$1" in
  start)
    echo "Starting $NAME"
    $DAEMON --daemonize --ephemeral-keys --user=dnscrypt --local-address=127.0.0.1 --resolver-address=$ADDRESS1 --provider-name=$PNAME1 --provider-key=$PKEY1
	$DAEMON --daemonize --ephemeral-keys --user=dnscrypt --local-address=127.0.0.2 --resolver-address=$ADDRESS2 --provider-name=$PNAME2 --provider-key=$PKEY2
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
