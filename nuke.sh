#!/bin/bash
echo "NUKING $1" >> /var/log/PiEraser.log
#TURN ON LED
gpio -g mode 17 out
gpio -g write 17 1

# This next line handles securely erasing the disk.
# We can comment it out if we don't need secure erasure.
shred --iterations=1 "$1" >> /var/log/PiEraser.log

# Now that We're erased, we can do whatever we want with our new drive.
# There are a couple of options here, but by default, we'll just create a new
# partition and format it to FAT32.
# Another option would be to dd an image onto it.
#dd if=/path/to/file.img of="$1" bs=512
# If you decide to go this route, make sure to comment out every line before
# sync or it will overrite your image!

#The following ugly mess creates a new partition table with one partition that takes up the whole disk.
echo "o
n
p



w

" | fdisk "$1"
# This puts our new filesystem onto the first partition on the disk.
# Fat32 by default. Uncomment only one of the following lines:
mkfs.vfat -F 32 "$1"1
# NTFS. Install the package ntfs-3g to use this option!
#mkfs.ntfs -F "$1"1
#mkfs.ext3 -F "$1"1
#mkfs.ext2 -F "$1"1

# This next section is for doing things with the filesystem once it's been created.
# Mount our new fs to a folder with the same name as the device(to prevent confilicts with
# other instances of this script).
mntpath=/mnt/$(basename "$1")1
mkdir $mntpath
mount "$1"1 $mntpath
cd $mntpath

# Now we have a couple of options of what to do. By default we'll create a text file
# to inform the user that the script worked.
touch Erased_With_Pi-Eraser.txt
echo "This drive has been securely erased and repartitioned with Pi-Eraser\
https://github.com/Real-Time-Kodi/Pi-Eraser" > Erased_With_Pi-Eraser.txt

# We could also take this oppurtunity to call another script:
#/path/to/script
# Or we could copy some files to our new partition:
#cp -R /path/to/files .

cd /
umount $mntpath
rmdir $mntpath

sync #SYNC because I don't trust the kernel to do it for me.

#TURN OFF LED
gpio -g write 17 0

echo "Done" >> /var/log/PiEraser.log

