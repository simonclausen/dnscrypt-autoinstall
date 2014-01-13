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
ADDRESS1=77.66.84.233
ADDRESS2=176.56.237.171
PNAME1=2.dnscrypt-cert.resolver2.dnscrypt.eu
PNAME2=2.dnscrypt-cert.resolver1.dnscrypt.eu
PKEY1=3748:5585:E3B9:D088:FD25:AD36:B037:01F5:520C:D648:9E9A:DD52:1457:4955:9F0A:9955
PKEY2=67C0:0F2C:21C5:5481:45DD:7CB4:6A27:1AF2:EB96:9931:40A3:09B6:2B8D:1653:1185:9C66

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