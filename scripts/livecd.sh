#!/bin/bash
set -e
#Chapter 11. The End - Part 2
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

if [ -n $JOBS ];then
        JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
        if [ ! $JOBS ];then
                JOBS="1"
        fi
fi
export MAKEFLAGS=-j$JOBS
DEVICE=/dev/vdb

#1.创建“制作基地”
export LIVECD=/opt/livecd
rm -rf ${LIVECD}/*
mkdir -pv $LIVECD
#2.创建制作相关的目录
#（1）创建制作初始化辅助系统的目录
mkdir -pv ${LIVECD}/tmpfs/{initramfs,initrd,tmp}
#（2）创建制作最终文件系统的目录
mkdir -pv ${LIVECD}/system
#（3）创建制作ISO文件的目录，iso目录用于存放LiveCD的内容，包括最终系统景象文件
#boot目录存放GRUB相关的文件
#live目录存放内核及辅助系统文件等
mkdir -pv ${LIVECD}/iso/{boot,live}
#（4）创建软件包编译目录
mkdir -pv ${LIVECD}/{build,download}

export BUILD_DIR=${LIVECD}/build
export DOWNLOAD_DIR=${LIVECD}/download

#livecd filesystem build
pushd ${LIVECD}/system
echo "copying the files to system..."
#cp -a /{bin,dev,etc,home,lib,lib64,run,sbin,tmp,usr,var} ./
cp -a /{bin,dev,etc,lib,lib64,run,sbin,tmp,usr,var} ./
mkdir -vp media mnt opt proc root srv sys home
#创建默认用户haoos和root，密码为1
chroot ${LIVECD}/system groupadd haoos
chroot ${LIVECD}/system useradd -m -d /home/haoos -g haoos haoos
chroot ${LIVECD}/system echo root:1 | chpasswd
#chroot ${LIVECD}/system echo haoos:1 | chpasswd

rm -rf usr/src
rm -rf lib/modules

rm lib/udev/write_*
rm -f etc/udev/rules.d/70*

rm ${LIVECD}/system/etc/fstab
cat > ${LIVECD}/system/etc/fstab << EOF
none	/proc		proc	defaults	0	0
sysfs	/sys		sysfs	defaults	0	0
devpts	/dev/pts	devpts	gid=4,mode=620	0	0
#tmpfs	/dev/shm	tmpfs	defaults	0	0
EOF

rm ${LIVECD}/system/etc/mtab
cat > ${LIVECD}/system/etc/mtab << EOF
none	/proc		proc	defaults	0	0
sysfs	/sys		sysfs	defaults	0	0
devpts	/dev/pts	devpts	gid=4,mode=620	0	0
EOF

#build livecd kernel
pushd /lfs/linux-5.10.17
#拷贝内核文件到live目录
cp -av arch/x86/boot/bzImage ${LIVECD}/iso/live/livecd-kernel
#安装内核到文件系统
make INSTALL_MOD_PATH=${LIVECD}/system/ INSTALL_MOD_STRIP=1 modules_install

popd #linux-5.10.17
#done

popd #${LIVECD}/system

#build livecd initramfs
CURRENT_DIR=`dirname $0`
. $CURRENT_DIR/initramfs-livecd.sh
#done

#将所需的文件和目录制作成镜像文件
pushd ${LIVECD}/system
mksquashfs * ${LIVECD}/iso/SYSTEM.img
popd #${LIVECD}/system

#grub2 install
pushd ${LIVECD}/iso
#1
#mkdir -p boot/grub
#2安装grub2的模块文件,这里从lfs系统拷贝，system没有字体文件。
cp -av /boot/grub boot/

#3创建GRUB-2的启动配置文件
cat > ${LIVECD}/iso/boot/grub/grub.cfg << "EOF"
set default=0
set timeout=5
insmod vbe
insmod font
if loadfont /boot/grub/fonts/unicode.pf2
then
	insmod gfxterm
	set gfxmode=auto
	set gfxpayload=keep
	terminal_output gfxterm
fi
insmod gfxmenu
loadfont ($root)/boot/grub/themes/Cyberpunk/Blender_Pro_Book_12.pf2
loadfont ($root)/boot/grub/themes/Cyberpunk/Blender_Pro_Book_14.pf2
loadfont ($root)/boot/grub/themes/Cyberpunk/Blender_Pro_Book_16.pf2
loadfont ($root)/boot/grub/themes/Cyberpunk/Blender_Pro_Book_24.pf2
loadfont ($root)/boot/grub/themes/Cyberpunk/Blender_Pro_Book_32.pf2
loadfont ($root)/boot/grub/themes/Cyberpunk/Blender_Pro_Book_48.pf2
loadfont ($root)/boot/grub/themes/Cyberpunk/terminus-12.pf2
loadfont ($root)/boot/grub/themes/Cyberpunk/terminus-14.pf2
loadfont ($root)/boot/grub/themes/Cyberpunk/terminus-16.pf2
loadfont ($root)/boot/grub/themes/Cyberpunk/terminus-18.pf2
insmod png
set theme=($root)/boot/grub/themes/Cyberpunk/theme.txt
export theme
menuentry "HaoOS's LiveCD" {
	set gfxpayload=keep
	echo    '载入 Linux 5.10.17 ...'
	linux	/live/livecd-kernel
	echo    '载入初始化内存盘...'
	initrd	/live/livecd-initramfs.img
}
menuentry '重启 '{
	reboot
}
EOF

#4创建LiveCD启动文件
#-p --prefix-directory.Set the $prefix variable
export PREFIX=/boot/grub
grub-mkimage -o ${LIVECD}/core.img -p $PREFIX -O i386-pc iso9660 linux biosdisk
cat /usr/lib/grub/i386-pc/cdboot.img ${LIVECD}/core.img \
	> ${LIVECD}/iso/boot/livecd.img
popd #${LIVECD}/iso

#添加UEFI启动支持
tar xf /sources/other-sources/EFI.tar.xz -C ${LIVECD}/iso/

#generate iso file
pushd ${LIVECD}
mkisofs -R -boot-info-table -no-emul-boot -boot-load-size 4 -b boot/livecd.img -V "mylivecd" \
	-o mylivecd.iso iso
popd
