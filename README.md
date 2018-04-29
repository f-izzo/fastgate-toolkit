# Fastgate Toolkit

You can find quick information on this page and detailed information on the [Wiki](https://github.com/Nimayer/fastgate-toolkit/wiki)

## Obtain SSH access
You can obtain SSH access to the FastGATE using the [fastgate-python](https://github.com/Depau/fastgate-python#installation) script as explained [here](https://github.com/Nimayer/fastgate-toolkit/wiki/Get-a-root-shell-(SSH))


## Make persistent modifications to filesystem
You can make persistent changes to the root filesystem as explained [here](https://github.com/Nimayer/fastgate-toolkit/wiki/Make-persistent-changes-to-filesystem).

## Custom firewall rules
The stock firewall has various issues, like:
- allowing IPv6 connections from internet to LAN
...

This method allow to replace stock iptables configuration with a new one.
A complete IPv6 firewall configuration is provided.

Custom rules are saved in `iptables_rules`, the example takes care of clearing
existing rules

The files can be sent to the Fastgate by starting a `python3 -m http.server`
inside this repository folder, to use `wget` on the Fastgate
```
# mount /tmp/ubifs
cd /tmp
wget http://your-pc-ip:8088/firewall.sh
cd /tmp/ubifs
mv usr/sbin/firewall.sh usr/sbin/firewall //be careful not to overwrite original firewall.sh
mv /tmp/firewall.sh usr/sbin/firewall.sh
chmod 775 usr/sbin/firewall.sh
```
- copy `iptables_rules` in `/etc` in a similar manner

## Install a chroot on a USB drive
A mainstream distro chroot allows using a package manager to easily get commonly used software (like Python and compilers) running on the gateway. See this [wiki page](https://github.com/Nimayer/fastgate-toolkit/wiki/Set-up-a-chroot) for instructions on how to get a Debian chroot.

Work is being done to get LXC containers running. See [wiki page](https://github.com/Nimayer/fastgate-toolkit/wiki/LXC).

Credits to lorenzodes for web-interface exploit
