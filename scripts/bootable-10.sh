#!/bin/bash
set -e
#Chapter 10. Making the LFS System Bootable
export MAKEFLAGS='-j4'

#10.2. Creating the /etc/fstab File
cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/vdb2	/boot/efi	vfat	umask=0077      0       1
/dev/vdb3	/	ext4	defaults	1	1

# End /etc/fstab
EOF

mkdir -vp /boot/efi
set +e
mkfs.fat /dev/vdb2
mount /dev/vdb2 /boot/efi
set -e

mount -a

pushd /lfs

popd #/lfs
