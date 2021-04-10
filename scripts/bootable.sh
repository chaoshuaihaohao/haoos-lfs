#!/bin/bash
set -e
#Chapter 10. Making the LFS System Bootable
export MAKEFLAGS='-j4'




#10.2. Creating the /etc/fstab File
cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/vdb1	/boot	ext4	defaults	1	1
/dev/vdb2	/boot/efi	vfat	umask=0077      0       1
/dev/vdb3	/	ext4	defaults	1	1

# End /etc/fstab
EOF

#mkfs.ext4 /dev/vdb1
mount /dev/vdb1 /boot
mkdir -vp /boot/efi
mkfs.fat /dev/vdb2
mount /dev/vdb2 /boot/efi

mount -a

pushd /lfs

#10.4. 使用 GRUB 设定引导过程
pushd /tmp
grub-mkrescue --output=grub-img.iso
#xorriso -as cdrecord -v dev=/dev/cdrw blank=as_needed grub-img.iso
#grub-install --grub-setup=/bin/true /dev/vdb -v
#grub-install --boot-directory=/boot/grub --efi-directory=/boot/efi /dev/vdb -v
grub-install /dev/vdb -v
grub-mkconfig -o /boot/grub/grub.cfg
popd

popd #/lfs
