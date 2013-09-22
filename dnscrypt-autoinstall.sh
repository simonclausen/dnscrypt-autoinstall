#!/bin/bash

### 
# Installation and autoconfigure script for debian and dnscrypt.eu
#
# Author: Simon Clausen <kontakt@simonclausen.dk>
#
# This script needs a lot of work done - this is just a first draft I quickly cooked up.
#
# Todo: proper init script, choice of dnscrypt service (OpenDNS, CloudNS, DNSCrypt.eu, "other"),
#		reconfigure after installed, uninstall feature, download newest version, checksum files, etc.
###

if [ $USER != 'root' ]; then
	echo "Error: You need to be root to run this."
	exit
fi

if [ -e /usr/local/sbin/dnscrypt-proxy ]; then
	echo "It looks like DNSCrypt is already installed. Quitting."
	exit
else
	apt-get install automake libtool
	cd
	mkdir dnscrypt-autoinstall
	cd dnscrypt-autoinstall
	wget -no-check-certificate https://download.libsodium.org/libsodium/releases/libsodium-0.4.3.tar.gz
	wget -no-check-certificate http://download.dnscrypt.org/dnscrypt-proxy/dnscrypt-proxy-1.3.3.tar.gz
	tar -zxf libsodium-0.4.3.tar.gz
	cd libsodium-0.4.3
	./configure
	make
	make check
	make install
	cd ..
	tar -zxf dnscrypt-proxy-1.3.3.tar.gz
	cd dnscrypt-proxy-1.3.3
	./configure
	make
	make install
	cd ..
	useradd -g dnscrypt -d /dev/null -s /dev/nologin dnscrypt
	wget --no-check-certficate https://raw.github.com/simonclausen/dnscrypt-autoinstall/master/initscript.sh -o /etc/init.d/dnscrypt-proxy
	chmod +x /etc/init.d/dnscrypt-proxy
	update-rc.d dnscrypt-proxy defaults
	/etc/init.d/dnscrypt-proxy start
	sed s/nameserver/#nameserver/ </etc/resolv.conf
	cat "nameserver 127.0.0.1" >> /etc/resolv.conf
	cd
	rm -rf dnscrypt-autoinstall
fi