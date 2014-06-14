#!/bin/bash

### 
# Autoconfigure script for Arch Linux and dnscrypt.
#
# This script will set up dnscrypt as a daemon service that runs on
# system startup. It gives you the option to choose which DNSCrypt service to use 
# and easily reconfigure DNSCrypt.
#
# Author: Simon Clausen <kontakt@simonclausen.dk>
# Version: 0.3
###

# Are you root?
if (( UID = 0 )); then
	echo "Error!"
	echo ""
	echo "You need to be root to run this script."
	exit 1
fi

# Vars for stuff
WHICHRESOLVER=dnscrypteu
GITURL=https://raw.github.com/simonclausen/dnscrypt-autoinstall/master/systemd

function config_interface {
	echo ""
	echo "Which DNSCrypt service would you like to use?"
	echo ""
	echo "1) DNSCrypt.eu (Europe - no logs, DNSSEC)"
	echo "2) OpenDNS (Anycast)"
	echo "3) CloudNS (Australia - no logs, DNSSEC)"
	echo "4) OpenNIC (Japan - no logs)"
	echo "5) OpenNIC (Europe - no logs)"
	echo "6) Soltysiak.com (Europe - no logs, DNSSEC)"
	echo ""
	read -p "Select an option [1-6]: " OPTION
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
		WHICHRESOLVER=soltysiak
		;;
	esac
	return 0
}

function config_do {
	systemctl stop dnscrypt-proxy.service
	curl -Lo /etc/conf.d/dnscrypt-config $GITURL/dnscrypt-config-$WHICHRESOLVER
	systemctl start dnscrypt-proxy.service
	return 0
}

echo -e "\nWelcome to dnscrypt-autoinstall.\n"
echo -e "This will autoconfigure DNSCrypt to run as a daemon at start up.\n"
read -n1 -r -p "Press any key to continue..."
clear

echo -e "\nWould you like to see a list of supported providers?"
read -p "(DNSCrypt.eu is default) [y/n]: " -e -i n SHOWLIST

if [ $SHOWLIST == "y" ]; then
	config_interface
fi
systemctl enable dnscrypt-proxy.service
config_do
