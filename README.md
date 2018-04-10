# Fastgate Toolkit

## web interface exploit
`./fastgate_tester.sh getroot`
The script enables SSH by setting NVRAM variables,  
this method will be reverted by a reset of the router.

## Make persistent modifications to filesystem
```
# Create mount point
mkdir /tmp/ubifs
mount -o remount,rw ubi0:rootfs_ubifs /
mount -o bind -t ubifs ubi0:rootfs_ubifs /tmp/ubifs
```
- Then copy or modify files in /tmp/ubifs
- Unmount the filesystem and reboot to apply changes
```
umount /tmp/ubifs
reboot
```

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

## Enable SSH via rc-init script
This method survives the reset of the router (which only clears NVRAM)
```
# mount /tmp/ubifs
cd /tmp
wget http://192.168.1.154:8088/sshd.sh
cp /tmp/sshd.sh /tmp/ubifs/etc/init.d/
chmod 755 /tmp/ubifs/etc/init.d/sshd.sh
cd /tmp/ubifs/etc/rc3.d/
ln -s ../init.d/sshd.sh S99ssh
umount /tmp/ubifs
```

## Install a Debian chroot on a USB drive

Format the USB drive using provided `mke2fs` (it will take a while)

```sh
# Make sure /dev/sda1 is the correct device
# You can use /statusapi/sbin/blkid
/statusapi/sbin/mke2fs /dev/sda1
```

On a Debian system, [create a Debian chroot](https://wiki.debian.org/ArmHardFloatChroot).

```sh
apt install debootstrap qemu-user-static
qemu-debootstrap --arch=armel sid /path/to/sid-armel http://ftp.debian.org/debian/
```

Copy the chroot to the USB drive. Make sure you keep permissions (i.e. use
`tar -a` if making a tarball or `cp -a`).

Edit and copy `chroot.sh` to the USB drive and make it executable.

Get into the chroot:

```sh
/mnt/sda1/chroot.sh
```


Credits to lorenzodes for web-interface exploit
