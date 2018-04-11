#!/statusapi/bin/busybox sh

chroot="/mnt/sda1/sid-armel"
bin="/bin/bash"
usb="/dev/sda1"

busybox="/statusapi/bin/busybox"

if [ ! "x$1" = "x" ]; then
	bin="$1"
fi

$busybox mkdir -p "${chroot}/dev"
$busybox mkdir -p "${chroot}/proc"
$busybox mkdir -p "${chroot}/sys"
$busybox mkdir -p "${chroot}/fastgate"
$busybox mkdir -p "${chroot}/usb"

$busybox mount -o bind / "${chroot}/fastgate" 2>&1 > /dev/null
$busybox mount -o bind /dev "${chroot}/dev" 2>&1 > /dev/null
$busybox mount -o bind /proc "${chroot}/proc" 2>&1 > /dev/null
$busybox mount -o bind /sys "${chroot}/sys" 2>&1 > /dev/null
$busybox mount "$usb" "${chroot}/usb" 2>&1 > /dev/null

PATH="/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin:/bin" $busybox chroot "$chroot" "$bin"