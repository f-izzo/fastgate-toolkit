#!/statusapi/bin/busybox sh

chroot="/mnt/sda1/sid-armel"
bin="/bin/bash"
usb="/dev/sda1"

bb="/statusapi/bin/busybox"

# Run bash by default
if [ ! "x$1" = "x" ]; then
	bin="$1"
fi

# Create mountpoints
$bb mkdir -p "${chroot}/dev"
$bb mkdir -p "${chroot}/proc"
$bb mkdir -p "${chroot}/sys"
$bb mkdir -p "${chroot}/fastgate"
$bb mkdir -p "${chroot}/usb"

# Mount stuff if not already mounted
$bb mount | $bb grep -q "${chroot}/fastgate" || $bb mount -o bind /        "${chroot}/fastgate"
$bb mount | $bb grep -q "${chroot}/dev"      || $bb mount -o bind /dev     "${chroot}/dev"
$bb mount | $bb grep -q "${chroot}/dev/pts"  || $bb mount -o bind /dev/pts "${chroot}/dev/pts"
$bb mount | $bb grep -q "${chroot}/proc"     || $bb mount -o bind /proc    "${chroot}/proc"
$bb mount | $bb grep -q "${chroot}/sys"      || $bb mount -o bind /sys     "${chroot}/sys"
$bb mount | $bb grep -q "${chroot}/usb"      || $bb mount         "$usb"   "${chroot}/usb"

PATH="/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/bin:/bin" $bb chroot "$chroot" "$bin"