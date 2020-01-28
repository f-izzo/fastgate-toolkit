# Unbrick your FASTGate router via hardware programmer

## Requirements
1. Backups of all mtd partitions
2. Kernellog showing mtd partition mapping
3. Saved output of /proc/mtd
3. createnfimg tool (search on github)

## Example of kernellog section
```
***** Found UBIFS Marker at 0x0fb1ff00
***** Found UBIFS Marker at 0x0041ff00
Creating 11 MTD partitions on "brcmnand.0":
0x00000fb20000-0x00001ede0000 : "rootfs"
0x000000420000-0x00000f700000 : "rootfs_update"
0x00001fb00000-0x00001ff00000 : "data"
0x000000000000-0x000000020000 : "nvram"
0x00000f700000-0x00001ede0000 : "image"
0x000000020000-0x00000f700000 : "image_update"
0x00000f700000-0x00000fb20000 : "bootfs"
0x000000020000-0x000000420000 : "bootfs_update"
0x00001f700000-0x00001fb00000 : "misc3"
0x00001f600000-0x00001f700000 : "misc2"
0x00001ee00000-0x00001f600000 : "misc1"
```

## Example of /proc/mtd
```
dev:  size     erasesize name 
mtd0: 0f2c0000 00020000 "rootfs"
mtd1: 0f2e0000 00020000 "rootfs_update"
mtd2: 00400000 00020000 "data"
mtd3: 00020000 00020000 "nvram"
mtd4: 0f6e0000 00020000 "image"
mtd5: 0f6e0000 00020000 "image_update"
mtd6: 00420000 00020000 "bootfs"
mtd7: 00400000 00020000 "bootfs_update"
mtd8: 00400000 00020000 "misc3"
mtd9: 00100000 00020000 "misc2"
mtd10: 00800000 00020000 "misc1"
mtd11: 0e861000 0001f000 "rootfs_ubifs"
mtd12: 00100000 00020000 "STNVRAM"
mtd13: 00040000 00020000 "STENVRAM"
mtd14: 00100000 00020000 "STNVRAMBKP"
mtd15: 00040000 00020000 "STENVRAMBKP"
```

## NAND blocks
```c
#define PAGE_SIZE 512
#define SPARE_SIZE 16
#define PAGES_PER_BLOCK 4

#define USERDATA_IN_BLOCK (PAGE_SIZE * PAGES_PER_BLOCK)
#define SPAREDATA_IN_BLOCK (SPARE_SIZE * PAGES_PER_BLOCK)

#define PHYS_BLOCK_SIZE (USERDATA_IN_BLOCK + SPAREDATA_IN_BLOCK)

#define ECC_ALGO "BCH4"
```

## How To
1. (Optional) If mtd partitions were dumped including SPARE data, strip it so you end up with just userdata.
2. Concatenate mtd backup images in the layout dictated by kernellog.
   Note: Yes, sections overlap. Just put the data in the memory region it expects.
3. You should end up with something like the following layout for your rebuilt NAND image:
```
0x00000000-0x00020000 mtd3  nvram
0x00020000-0x0f700000 mtd5  image_update
0x0f700000-0x0fb20000 mtd6  bootfs
0x0fb20000-0x1ede0000 mtd0  rootfs
0x1ede0000-0x1ee00000 EMTPY (0x20000 bytes)
0x1ee00000-0x1f600000 mtd10 misc1
0x1f600000-0x1f700000 mtd9  misc2
0x1f700000-0x1fb00000 mtd8  misc3
0x1fb00000-0x1ff00000 mtd2  data
0x1ff00000-0x20000000 EMPTY (0x100000 bytes)
```
4. Run the image through through *createnfimg* tool
```
./createnfimg \
  -b 4 \
  -l 1 \
  -p 512 \
  -r 16 \
  -n 4 \
  -i rebuilt_nand.img
  
Explaination:
-b <bch_level> -- Level of BCH correction
-l <0|1>       -- 1=Select little endian clean marker (default is big endian)
-p <page_size> -- Page size in bytes
-r <oob_size>  -- OOB size in bytes per 512 byte subpage
-n <pages_per_block> -- Pages per erase block
-i <infile>    -- Name of the input file.  Output files will be 'infile.out'
```
5. Desolder NAND, program it with *rebuilt_nand.img.out*, solder it back
6. Hopefully: Profit!
