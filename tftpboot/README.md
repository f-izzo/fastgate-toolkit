# TFTP booting on AsKey RTV1907VW
For older firmwares that feature interactive CFE

## Kernel
Usually when booted from NAND, CFE uncompressed vmlinux.lz from JFFS2 volume "bootfs".
Vmlinux.lz is compressed .TEXT section of a kernel ELF with prepended, broadcom-specific fileheader.

To use it for TFTP you need to convert it to a real ELF. See contained script!

```
1. Place vmlinux.lz next to script
2. Run convert.sh
3. Use created vmlinux.elf
```

## Initrd
Supported formats:
* Squashfs
* gzipped EXT2FS

## Cmdline
For initrd to work you might want to hexedit kernel elf to use
`root=/dev/ram0`
