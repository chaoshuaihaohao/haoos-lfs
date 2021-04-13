#!/bin/bash
set -e
#Chapter 11. The End - Part 2
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

#copy file

#
export LIVECD=/opt/livecd/
mkdir -pv $LIVECD
#
mkdir -pv ${LIVECD}/image/{initramfs,initrd}
#
mkdir -pv ${LIVECD}/system
#
mkdir -pv ${LIVECD}/iso/boot
#
mkdir -pv ${LIVECD}/{build,download}

export BUILD_DIR=${LIVECD}/build
export DOWNLOAD_DIR=${LIVECD}/download

#livecd filesystem build
pushd ${LIVECD}/system

cp -a /{bin,dev,etc,home,lib,lib64,run,sbin,tmp,usr,var} ./
mkdir -vp media mnt opt proc root srv sys

rm -rf usr/src
rm -rf lib/modules

rm lib/udev/write_*
rm -f etc/udev/rules.d/70*

#cat > ${LIVECD}/system/etc/fstab << EOF
#none	/proc		proc	defaults	0	0
#sysfs	/sys		sysfs	defaults	0	0
#devpts	/dev/pts	devpts	gid=4,mode=620	0	0
#tmpfs	/dev/shm	tmpfs	defaults	0	0
#EOF

#cat > ${LIVECD}/system/etc/mtab << EOF
#none	/proc		proc	defaults	0	0
#sysfs	/sys		sysfs	defaults	0	0
#devpts	/dev/pts	devpts	gid=4,mode=620	0	0
#EOF

#build livecd kernel
#todo...

#build livecd initramfs
#todo...

cp -av /boot/vmlinuz-5.10.17-lfs-20210326-systemd ${LIVECD}/iso/boot/livecd-kernel
mkdir -pv lib/modules/
#cp /lib/module/* ${LIVECD}/system/lib/modules/ -a

cp -av /boot/initrd.img-5.10.17-lfs-20210326-systemd ${LIVECD}/iso/boot/initramfs.img.gz

mksquashfs * ${LIVECD}/iso/SYSTEM.img
popd #${LIVECD}/system

pushd ${LIVECD}/iso
#grub2 install
#1
mkdir -p boot/grub
#2
cp -a /usr/lib/grub/i386-pc/*.mod boot/grub
cp -a /usr/lib/grub/i386-pc/*.lst boot/grub
#3
cat > ${LIVECD}/iso/boot/grub/grub.cfg << "EOF"
set default=0
set timeout=5

menuentry "My LiveCD with Initramfs" {
	linux	/boot/livecd-kernel
	initrd	/boot/initramfs.img.gz
}
menuentry "My LiveCD with Initrd" {
	linux	/boot/livecd-kernel root=/dev/livecd
	initrd	/boot/initrd.img.gz
}
menuentry "My LiveCD with Initramfs on USB" {
	linux	/boot/livecd-kernel rootdelay=0
	initrd	/boot/initramfs.img.gz
}
menuentry "My LiveCD with Initrd on USB" {
	linux	/boot/livecd-kernel rootdelay=0
	initrd	/boot/initrd.img.gz
}

insmod vbe
set gfxpayload=800x600x16
EOF

#4
set -x
export LIVECD=/opt/livecd/
grub-mkimage -o ${LIVECD}/core.img -p ${LIVECD} -O i386-pc iso9660 linux biosdisk
cat /usr/lib/grub/i386-pc/cdboot.img ${LIVECD}/core.img \
	> ${LIVECD}/iso/boot/livecd.img
set +x
popd #${LIVECD}/iso

#generate iso file
pushd ${LIVECD}
mkisofs -R -boot-info-table -no-emul-boot -boot-load-size 4 -b boot/livecd.img -V "mylivecd" \
	-o mylivecd.iso iso
popd
