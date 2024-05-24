lsblk
sudo dd if=/dev/zero of=/dev/sdb bs=1024 count=1
sudo fdisk /dev/sdb

#Once you're in the fdisk interactive mode, follow these steps based on the output you provided:
#	-->Type n and press Enter to create a new partition.
#	-->Choose p for primary partition.
#	-->When prompted for the partition number, press Enter to accept the default value (1).
#	-->Accept the default first sector by pressing Enter.
#	-->Specify the size of the partition. In your provided example, it's +200M for a 200 MB #	-->partition. You can adjust the size according to your requirements.
#	-->Type n again to create another partition.
#	-->Choose p for primary partition.
#	-->Press Enter to accept the default partition number (2).
#	-->Press Enter to accept the default first sector.
#	-->Press Enter to accept the default last sector, using the remaining space on the SD card.
#	-->Once you've created the partitions, type w and press Enter to write the changes to the disk and exit.

#Command (m for help): a
#	-->Partition number (1-4): 1

#Command (m for help): t
#	-->Partition number (1-4): 1
#	-->Hex code (type L to list codes): c
#	Changed system type of partition 1 to c (W95 FAT32 (LBA))

#Command (m for help): t
#	-->Partition number (1-4): 2
#	-->Hex code (type L to list codes): 83

#Command (m for help): p
#Command (m for help): w

sudo mkfs.vfat -F 32 -n boot /dev/sdb1
sudo mkfs.ext4 -L root /dev/sdb2

sudo mkdir -p /mnt/sdb1
sudo mount /dev/sdb1 /mnt/sdb1
sudo mkdir -p /mnt/sdb2
sudo mount /dev/sdb2 /mnt/sdb2

cd yocto-zynq/poky/build/tmp/deploy/images/zedboard-zynq7

sudo cp boot.bin boot.scr core-image-minimal-zedboard-zynq7.cpio.gz.u-boot u-boot.img uEnv.txt uImage zynq-zed.dtb .dtb /mnt/sdb1/

sudo cp core-image-minimal-zedboard-zynq7.tar.gz /mnt/sdb2/
cd /mnt/sdb2/
sudo tar xvzf core-image-minimal-zedboard-zynq7.tar.gz




