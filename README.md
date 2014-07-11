dnscrypt-autoinstall
====================

## Description
Installation and autoconfigure script for Linux-based systems and DNSCrypt.

This script will verify, build, and install DNSCrypt and finally set it up as a
daemon service that runs on system startup. It also allows you to choose which
DNSCrypt service to use and easily reconfigure DNSCrypt, as well as uninstall it.

**Todo:** proper init script, download newest version, handle failed download, fix quirks

## Installation
###Debian, Ubuntu:

```
wget https://raw.github.com/simonclausen/dnscrypt-autoinstall/master/dnscrypt-autoinstall.sh
chmod +x dnscrypt-autoinstall.sh
sudo ./dnscrypt-autoinstall.sh
```

###Fedora, CentOS:

```
wget https://raw.github.com/simonclausen/dnscrypt-autoinstall/master/dnscrypt-autoinstall-redhat.sh
chmod +x dnscrypt-autoinstall-redhat.sh
sudo ./dnscrypt-autoinstall-redhat.sh
```

###Arch Linux:

Install *dnscrypt-autoinstall* from the AUR:

https://aur.archlinux.org/packages/dnscrypt-autoinstall/

## Troubleshooting
If the install fails at a particular stage and the script mentions DNSCrypt is already configured, use the `forcedel` argument:

`sudo ./dnscrypt-autoinstall.sh forcedel`
