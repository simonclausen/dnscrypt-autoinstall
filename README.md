dnscrypt-autoinstall
====================

> This project has been archived, see last comment in #108.

---

A script for installing and automatically configuring DNSCrypt on Linux-based systems.

# Description

DNSCrypt is a protocol for securing communications between a client and a DNS resolver by encrypting DNS queries and responses. It verifies that responses you get from a DNS provider have actually been sent by that provider, and haven't been tampered with.

This script will automatically and securely set up DNSCrypt as a background service that runs at system startup using [DNSCrypt-proxy](https://github.com/jedisct1/dnscrypt-proxy/), the [libsodium](https://github.com/jedisct1/libsodium) cryptography library, and the DNSCrypt service provider of your choice. The script also has options that allow you to change the service provider at any time, turn off DNSCrypt to use regular unencrypted DNS, as well as uninstall DNSCrypt.

## Installation

The script supports recent Red Hat-based (CentOS, Fedora, Scientific Linux), Debian-based (Debian, Ubuntu, Linux Mint) distributions and OpenSUSE.

| Note | Scripts with sysvinit support were moved to the "legacy" branch (CentOS 6, Debian 7, Ubuntu < 16.04) |
| --- | --- |

```
wget https://raw.githubusercontent.com/simonclausen/dnscrypt-autoinstall/master/dnscrypt-autoinstall
chmod +x dnscrypt-autoinstall
su -c ./dnscrypt-autoinstall
```

## Supported providers

Providers are retrieved from the latest published dnscrypt-resolvers.csv (github.com/jedisct1),
with a fallback to those included with the DNSCrypt installation.

## Troubleshooting

If the install fails at a particular stage and the script mentions DNSCrypt is already configured, use the `forcedel` argument to force an uninstallation:

```
./dnscrypt-autoinstall.sh forcedel
```
