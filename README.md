dnscrypt-autoinstall
====================
A script for installing and automatically configuring DNSCrypt on Linux-based systems.

## Alternatives
Development on this project has slowed down a lot and [DNSCrypt-Loader](https://github.com/gortcodex/dnscrypt-loader) provides some very nice features that this project has yet to implement (use of automatically updated official dnscrypt server list for one): go have a look at that one to see if that does not better support your need. Pull requests for this project are of course still very welcome if you feel like it :)

## Description

DNSCrypt is a protocol for securing communications between a client and a DNS resolver by encrypting DNS queries and responses. It verifies that responses you get from a DNS provider have actually been sent by that provider, and haven't been tampered with.

This script will automatically and securely set up DNSCrypt as a background service that runs at system startup using [DNSCrypt-proxy](https://github.com/jedisct1/dnscrypt-proxy/), the [libsodium](https://github.com/jedisct1/libsodium) cryptography library, and the DNSCrypt service provider of your choice. The script also has options that allow you to change the service provider at any time, turn off DNSCrypt to use regular unencrypted DNS, as well as uninstall DNSCrypt.

## Installation
### Debian, Ubuntu, Linux Mint:

```
wget https://raw.github.com/simonclausen/dnscrypt-autoinstall/master/dnscrypt-autoinstall.sh
chmod +x dnscrypt-autoinstall.sh
./dnscrypt-autoinstall.sh
```

### Fedora, CentOS, Scientific Linux:

```
wget https://raw.github.com/simonclausen/dnscrypt-autoinstall/master/dnscrypt-autoinstall-redhat.sh
chmod +x dnscrypt-autoinstall-redhat.sh
./dnscrypt-autoinstall-redhat.sh
```

###Arch Linux:

Install `dnscrypt-autoinstall` from the AUR:

https://aur.archlinux.org/packages/dnscrypt-autoinstall/

## Supported providers

Provider | Location | Note
-------- | -------- | ----
[DNSCrypt.eu](https://dnscrypt.eu/) | Europe | No logs, DNSSEC
[OpenDNS](https://www.opendns.com/about/innovations/dnscrypt/) | Anycast | 
[CloudNS](https://cloudns.com.au/) | Australia | No logs, DNSSEC
[OpenNIC](https://www.opennicproject.org/) | Japan | No logs
[OpenNIC](https://www.opennicproject.org/) | Europe | No logs
[Soltysiak.com](http://dc1.soltysiak.com/) | Europe | No logs, DNSSEC

## Troubleshooting
If the install fails at a particular stage and the script mentions DNSCrypt is already configured, use the `forcedel` argument to force an uninstallation:

```
./dnscrypt-autoinstall.sh forcedel
```
