dnscrypt-autoinstall
====================

## Decription
Installation and autoconfigure script for debian'ish systems and dnscrypt.

This script will install pre-req's, make & install dnscrypt and finally set it up
as a daemon service that runs on system startup. It also gives you the option to
choose which DNSCrypt service to use and easily reconfigure DNSCrypt and uninstall it.

## Installation
`wget --no-check-certificate https://raw.github.com/simonclausen/dnscrypt-autoinstall/master/dnscrypt-autoinstall.sh`
`chmod +x dnscrypt-autoinstall.sh`
`./dnscrypt-autoinstall.sh`
