#!/bin/bash

### 
# Installation and autoconfigure script for debian'ish systems and dnscrypt.
#
# This script will install pre-req's, make & install dnscrypt and finally set it up
# as a daemon service that runs on system startup. It also gives you the option to
# choose which DNSCrypt service to use and easily reconfigure DNSCrypt and uninstall it.
#
# This script should work on new(er) debian'ish releases.
#
# Authors: https://github.com/simonclausen/dnscrypt-autoinstall/graphs/contributors
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
LSODIUMURL="https://download.libsodium.org/libsodium/releases"
DNSCRYPTURL="https://download.dnscrypt.org/dnscrypt-proxy"
INITURL="https://raw.github.com/simonclausen/dnscrypt-autoinstall/legacy/init-scripts"
LSODIUMVER=$(curl --retry 5 -L $LSODIUMURL | awk -F'(.tar|libsodium-)' '/libsodium-1/ {v=$2}; END {print v}')
DNSCRYPTVER=$(curl --retry 5 -L $DNSCRYPTURL | awk -F'(.tar|proxy-)' '/proxy-1/ {v=$2}; END {print v}')
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
	echo "1) Off           (Regular, unencrypted DNS)"
	echo "2) DNSCrypt.eu   (Europe - no logs, DNSSEC)"
	echo "3) Cisco OpenDNS (Anycast)"
	echo "4) CloudNS       (Australia - no logs, DNSSEC)"
	echo "5) OpenNIC       (Japan - no logs)"
	echo "6) OpenNIC       (Europe - no logs, whitelisted users only)"
	echo "7) OpenNIC       (Toronto, Canada - no logs)"
	echo "8) OpenNIC       (San Francisco, USA - no logs)"
	echo "9) OpenNIC       (Seattle, USA - no logs)"
	echo "10) OkTurtles     (Georgia, USA - no logs)"
	echo "11) Soltysiak.com (Europe - no logs, DNSSEC)"
	echo ""
	read -p "Select an option [1-11]: " OPTION
	case $OPTION in
		1)
		WHICHRESOLVER=off
		;;
		2)
		WHICHRESOLVER=dnscrypteu
		;;
		3)
		WHICHRESOLVER=opendns
		;;
		4)
		WHICHRESOLVER=cloudns
		;;
		5)
		WHICHRESOLVER=opennicjp
		;;
		6)
		WHICHRESOLVER=openniceu
		;;
		7)
		WHICHRESOLVER=opennicca
		;;
		8)
		WHICHRESOLVER=opennicusasfo
		;;
		9)
		WHICHRESOLVER=opennicusasea
		;;
		10)
		WHICHRESOLVER=okturtles
		;;
		11)
		WHICHRESOLVER=soltysiak
		;;
	esac
	return 0
}

config_resolv() {
	# Set up resolv.conf to use dnscrypt
	sudo bash <<EOF
	chattr -i /etc/resolv.conf
	echo "nameserver 127.0.0.1" > /etc/resolv.conf
	echo "nameserver 127.0.0.2" >> /etc/resolv.conf
	
	# Make immutable. Dirty but dependable.
	chattr +i /etc/resolv.conf
EOF
}

config_do() {
	# Download and install the initscript for the chosen provider (including empty script for "off" mode).
	sudo bash <<EOF
	curl --retry 5 -Lo initscript-$WHICHRESOLVER.sh $INITURL/initscript-$WHICHRESOLVER.sh
	if [ "$DNSCRYPTCONF" == "true" ]; then
		/etc/init.d/dnscrypt-proxy stop
		update-rc.d -f dnscrypt-proxy remove
	fi
	mv initscript-$WHICHRESOLVER.sh /etc/init.d/dnscrypt-proxy
	chmod +x /etc/init.d/dnscrypt-proxy
EOF
	
	if [ "$WHICHRESOLVER" == "off" ]; then
		# User has chosen to turn off DNSCrypt and use regular, unencrypted DNS.
		# Restore resolv.conf-dnscryptbak by copying it to resolv.conf. Leave the backup in place in case the user uninstalls or turns DNSCrypt off again later.
		sudo bash <<EOF
		chattr -i /etc/resolv.conf
		cp -p /etc/resolv.conf-dnscryptbak /etc/resolv.conf
EOF
		return 0
	else
		# User has chosen a DNSCrypt provider. Start DNSCrypt.
		sudo bash <<EOF
		update-rc.d dnscrypt-proxy defaults
		/etc/init.d/dnscrypt-proxy start
EOF
		config_resolv
		return 0
	fi
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
	update-rc.d -f dnscrypt-proxy remove
	rm -f /etc/init.d/dnscrypt-proxy
	rm -f /usr/local/sbin/dnscrypt-proxy
	deluser dnscrypt
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
		echo "Welcome to the dnscrypt-autoinstall script."
		echo ""
		echo "It seems like DNSCrypt was installed and configured by this script."
		echo ""
		echo "What would you like to do?"
		echo ""
		echo "1) Configure another DNSCrypt service or turn off DNSCrypt."
		echo "2) Uninstall DNSCrypt and remove the auto-startup configuration."
		echo "3) Exit."
		echo ""
		read -p "Select an option [1-3]: " OPTION
		case $OPTION in
			1)
			config_interface
			config_do
			echo "Reconfiguration done. Quitting."
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
		echo "    ./dnscrypt-autoinstall.sh forcedel"
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
		echo "    ./dnscrypt-autoinstall.sh forcedel"
		echo ""
		echo "Quitting."
		exit 1
	else
		echo ""
		echo "Welcome to the dnscrypt-autoinstall script."
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
		apt-get update
		apt-get install -y automake libtool build-essential ca-certificates curl sudo
EOF
		[ ! -d "$TMPDIR" ] && mkdir "$TMPDIR"
		pushd "$TMPDIR"
		
		# Import GPG key to verify files
		import_gpgkey 54A2B8892CC3D6A597B92B6C210627AABA709FE1
		
		# Is libsodium installed?
		if [ "$LSODIUMINST" == "false" ]; then
			# Nope? Then let's get it set up
			curl --retry 5 -Lo libsodium-$LSODIUMVER.tar.gz $LSODIUMURL/libsodium-$LSODIUMVER.tar.gz
			curl --retry 5 -Lo libsodium-$LSODIUMVER.tar.gz.sig $LSODIUMURL/libsodium-$LSODIUMVER.tar.gz.sig
			
			# Verify signature
			verify_sig libsodium-$LSODIUMVER.tar.gz.sig
			
			tar -zxf libsodium-$LSODIUMVER.tar.gz
			pushd libsodium-$LSODIUMVER
			./configure --enable-minimal && make && make check && \
			sudo bash <<EOF
			make install
			ldconfig
EOF
			popd
		fi
		
		# Continue with dnscrypt installation
		curl --retry 5 -Lo dnscrypt-proxy-$DNSCRYPTVER.tar.gz $DNSCRYPTURL/dnscrypt-proxy-$DNSCRYPTVER.tar.gz
		curl --retry 5 -Lo dnscrypt-proxy-$DNSCRYPTVER.tar.gz.sig $DNSCRYPTURL/dnscrypt-proxy-$DNSCRYPTVER.tar.gz.sig
		
		# Verify signature
		verify_sig dnscrypt-proxy-$DNSCRYPTVER.tar.gz.sig
		
		tar -zxf dnscrypt-proxy-$DNSCRYPTVER.tar.gz
		pushd dnscrypt-proxy-$DNSCRYPTVER
		./configure && make && \
		sudo bash <<EOF
		make install
		
		# Add dnscrypt user and homedir
		adduser --system --home /etc/dnscrypt/run --shell /bin/false --group \
			--disabled-password --disabled-login dnscrypt
EOF
		popd
		
		# Backup resolv.conf
		sudo bash <<EOF
		cp -p /etc/resolv.conf /etc/resolv.conf-dnscryptbak
EOF
		
		# Set up init script
		config_do
		
		# Clean up
		popd
		rm -rf "$TMPDIR"
		
		echo ""
		echo "DNSCrypt is now installed."
		echo "You can run this script again to reconfigure, turn off, or uninstall it."
	fi
fi
