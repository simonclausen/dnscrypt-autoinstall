#!/bin/bash

### 
# Installation and autoconfigure script for Red Hat-based systems (Fedora, CentOS, 
# Scientific Linux) and dnscrypt.
#
# This script will install pre-req's, make & install dnscrypt and finally set it up
# as a daemon service that runs on system startup. It also gives you the option to
# choose which DNSCrypt service to use and easily reconfigure DNSCrypt and uninstall it.
#
# Author: Simon Clausen <kontakt@simonclausen.dk> + contributers. Thank you very much!
# Project site: https://github.com/simonclausen/dnscrypt-autoinstall
#
###

# Are you root?
if [ "$(id -u)" == 0 ]; then
	echo "You should not run this script directly as root."
	exit 1
elif ! sudo -v; then
	echo "Please configure sudo correctly before running this script."
	exit 1
fi

# Vars for stuff
LSODIUMINST=false
DNSCRYPTINST=false
DNSCRYPTCONF=false
LSODIUMVER=1.0.3
DNSCRYPTVER=1.5.0
LSODIUMURL="https://github.com/jedisct1/libsodium/releases/download/1.0.3"
DNSCRYPTURL="https://github.com/jedisct1/dnscrypt-proxy/releases/download/1.5.0"
GPGURL_LS="https://download.libsodium.org/libsodium/releases"
GPGURL_DC="http://download.dnscrypt.org/dnscrypt-proxy"
INITURL="https://raw.github.com/simonclausen/dnscrypt-autoinstall/master/init-scripts"
WHICHRESOLVER=dnscrypteu

# /tmp may be mounted noexec
TMPDIR="$(dirname "$0")/dnscrypt-autoinstall"

# Check files and set variables
if [ -e /usr/local/sbin/dnscrypt-proxy ]; then
	DNSCRYPTINST=true
fi

if [ -e /usr/local/lib/libsodium.so ]; then
	LSODIUMINST=true
fi

if [ -e /etc/init.d/dnscrypt-proxy ]; then
	DNSCRYPTCONF=true
fi

config_interface() {
	echo ""
	echo "Which DNSCrypt service would you like to use?"
	echo ""
	echo "1) DNSCrypt.eu (Europe - no logs, DNSSEC)"
	echo "2) Cisco OpenDNS (Anycast)"
	echo "3) CloudNS (Australia - no logs, DNSSEC)"
	echo "4) OpenNIC (Japan - no logs)"
	echo "5) OpenNIC (Europe - no logs, whitelisted users only)"
	echo "6) OpenNIC (Toronto, Canada - no logs)"
	echo "7) OpenNIC (San Francisco, USA - no logs)"
	echo "8) OkTurtles (Georgia, USA - no logs)"
	echo "9) Soltysiak.com (Europe - no logs, DNSSEC)"
	echo ""
	read -p "Select an option [1-9]: " OPTION
	case $OPTION in
		1)
		WHICHRESOLVER=dnscrypteu
		;;
		2)
		WHICHRESOLVER=opendns
		;;
		3)
		WHICHRESOLVER=cloudns
		;;
		4)
		WHICHRESOLVER=opennicjp
		;;
		5)
		WHICHRESOLVER=openniceu
		;;
		6)
		WHICHRESOLVER=opennicca
		;;
		7)
		WHICHRESOLVER=opennicusa
		;;
		8)
		WHICHRESOLVER=okturtles
		;;
		9)
		WHICHRESOLVER=soltysiak
		;;
	esac
	return 0
}

config_do() {
	sudo bash <<EOF
	curl --retry 5 -Lo initscript-$WHICHRESOLVER.sh $INITURL/initscript-$WHICHRESOLVER.sh
	if [ "$DNSCRYPTCONF" == "true" ]; then
		/etc/init.d/dnscrypt-proxy stop
		chkconfig --del dnscrypt-proxy
	fi
	mv initscript-$WHICHRESOLVER.sh /etc/init.d/dnscrypt-proxy
	chmod +x /etc/init.d/dnscrypt-proxy
	chkconfig --add dnscrypt-proxy
	/etc/init.d/dnscrypt-proxy start
EOF
	return 0
}

import_gpgkey() {
	echo "Importing key with ID: $1"
	gpg --keyserver keys.gnupg.net --recv-keys "$1"
	if [ $? -ne 0 ]; then
        	echo "Error importing key $1" 
		exit 1
        fi
}

verify_sig() {
	echo "Verifying signature of: ${1%%.sig}"
	gpg --verify "$1"

	if [ $? -ne 0 ]; then
		echo "Error verifying signature"
		exit 1
	fi
}

config_del() {
	sudo bash <<EOF
	/etc/init.d/dnscrypt-proxy stop
	chkconfig --del dnscrypt-proxy
	rm -f /etc/init.d/dnscrypt-proxy
	rm -f /usr/local/sbin/dnscrypt-proxy
	userdel -r dnscrypt
	rm -rf /etc/dnscrypt
	chattr -i /etc/resolv.conf
	mv /etc/resolv.conf-dnscryptbak /etc/resolv.conf
EOF
}

# Debug: Remove after failed install
if [ "$1" == "forcedel" ]; then
	config_del
	exit
fi

if [ "$DNSCRYPTINST" == "true" ]; then
	if [ "$DNSCRYPTCONF" == "true" ]; then
		echo ""
		echo "Welcome to dnscrypt-autoinstall script."
		echo ""
		echo "It seems like DNSCrypt was installed and configured by this script."
		echo ""
		echo "What would you like to do?"
		echo ""
		echo "1) Configure another DNSCrypt service"
		echo "2) Uninstall DNSCrypt and remove the auto-startup config"
		echo "3) Exit"
		echo ""
		read -p "Select an option [1-3]: " OPTION
		case $OPTION in
			1)
			config_interface
			config_do
			echo "Reconfig done. Quitting."
			exit
			;;
			2)
			config_del
			echo "DNSCrypt has been removed. Quitting."
			exit
			;;
			3)
			echo "Bye!"
			exit
			;;
		esac
	else
		echo ""
		echo "Error!"
		echo ""
		echo "It seems like DNSCrypt is already installed but"
		echo "not configured by this script."
		echo ""
		echo "Remove DNSCrypt and it's configuration completely"
		echo "from the system and run this script again."
		echo ""
		echo "To uninstall DNSCrypt, try running this script"
		echo "again with the 'forcedel' argument. For example:"
		echo "    ./dnscrypt-autoinstall-redhat.sh forcedel"
		echo ""
		echo "Quitting."
		exit 1
	fi
else
	if nc -z -w1 127.0.0.1 53; then
		echo ""
		echo "Error!"
		echo ""
		echo "It looks like there is already a DNS server"
		echo "or forwarder installed and listening on 127.0.0.1."
		echo ""
		echo "To use DNSCypt, you need to either uninstall it"
		echo "or make it listen on another IP than 127.0.0.1."
		echo ""
		echo "To uninstall DNSCrypt, try running this script"
		echo "again with the 'forcedel' argument. For example:"
		echo "    ./dnscrypt-autoinstall-redhat.sh forcedel"
		echo ""
		echo "Quitting."
		exit 1
	else
		echo ""
		echo "Welcome to dnscrypt-autoinstall script."
		echo ""
		echo "This will install DNSCrypt and autoconfigure it to run as a daemon at start up."
		echo ""
		read -n1 -r -p "Press any key to continue..."
		clear
		echo ""
		echo "Would you like to see a list of supported providers?"
		read -p "(DNSCrypt.eu is default) [y/n]: " -e -i n SHOWLIST
		if [ "$SHOWLIST" == "y" ]; then
			config_interface
		fi
		
		# Install prereqs and make a working dir
		sudo bash <<EOF
		yum update
		yum install -y make automake gcc gcc-c++ libtool ca-certificates curl nc sudo
EOF
		[ ! -d "$TMPDIR" ] && mkdir "$TMPDIR"
		pushd "$TMPDIR"
		
		# Fedora 19/20 include libsodium
		yum install -y libsodium-devel && LSODIUMINST=true
		
		# Import GPG key to verify files
		import_gpgkey 54A2B8892CC3D6A597B92B6C210627AABA709FE1
		
		# Is libsodium installed?
		if [ "$LSODIUMINST" == "false" ]; then
			# Nope? Then let's get it set up
			curl --retry 5 -Lo libsodium-$LSODIUMVER.tar.gz $LSODIUMURL/libsodium-$LSODIUMVER.tar.gz
			curl --retry 5 -Lo libsodium-$LSODIUMVER.tar.gz.sig $GPGURL_LS/libsodium-$LSODIUMVER.tar.gz.sig
			
			# Verify signature
			verify_sig libsodium-$LSODIUMVER.tar.gz.sig
			
			tar -zxf libsodium-$LSODIUMVER.tar.gz
			pushd libsodium-$LSODIUMVER
			./configure --enable-minimal && make && make check && \
			sudo bash <<EOF
			make install
			 
			# Fedora does not include /usr/local/lib for linking
			tee /etc/ld.so.conf.d/usr_local_lib.conf <<< /usr/local/lib 
			ldconfig
EOF
			popd
		fi
		
		# Continue with dnscrypt installation 
		curl --retry 5 -Lo dnscrypt-proxy-$DNSCRYPTVER.tar.bz2 $DNSCRYPTURL/dnscrypt-proxy-$DNSCRYPTVER.tar.bz2
		curl --retry 5 -Lo dnscrypt-proxy-$DNSCRYPTVER.tar.bz2.sig $GPGURL_DC/dnscrypt-proxy-$DNSCRYPTVER.tar.bz2.sig
		
		# Verify signature
		verify_sig dnscrypt-proxy-$DNSCRYPTVER.tar.bz2.sig
		
		tar -jxf dnscrypt-proxy-$DNSCRYPTVER.tar.bz2
		pushd dnscrypt-proxy-$DNSCRYPTVER
		./configure && make && \
		sudo bash <<EOF 
		make install
		
		# Add dnscrypt user and homedir
		mkdir -p /etc/dnscrypt/run
		useradd --system -d /etc/dnscrypt/run -s /bin/false dnscrypt
EOF
		popd
		
		# Set up init script
		config_do
		
		# Set up resolv.conf to use dnscrypt
		sudo bash <<EOF
		mv /etc/resolv.conf /etc/resolv.conf-dnscryptbak
		echo "nameserver 127.0.0.1" > /etc/resolv.conf
		echo "nameserver 127.0.0.2" >> /etc/resolv.conf
		
		# Dirty but dependable
		chattr +i /etc/resolv.conf
EOF
		# Clean up
		popd
		rm -rf "$TMPDIR"
	fi
fi
