#!/bin/bash
set -e
#Chapter 10. Making the LFS System Bootable




echo "export LFS=/mnt/lfs" >  ~/.bash_profile
source ~/.bash_profile
echo $LFS

#10.3. Linux-5.11.10
pushd $LFS/lfs

pushd linux-5.10.17
make mrproper
make menuconfig
make
make modules_install

mount --bind /boot /mnt/lfs/boot

cp -iv arch/x86/boot/bzImage /boot/vmlinuz-5.11.10-lfs-20210326-systemd

cp -iv System.map /boot/System.map-5.11.10

cp -iv .config /boot/config-5.11.10

install -d /usr/share/doc/linux-5.11.10
cp -r Documentation/* /usr/share/doc/linux-5.11.10
