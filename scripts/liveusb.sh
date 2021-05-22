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

#1.创建“制作基地”
export LIVEUSB=/haoos/liveusb
rm -rf ${LIVEUSB}
mkdir -pv $LIVEUSB
#2.创建制作相关的目录
#（1）创建制作初始化辅助系统的目录
mkdir -pv ${LIVEUSB}/tmpfs/{initramfs,initrd,tmp}
#（2）创建制作最终文件系统的目录
mkdir -pv ${LIVEUSB}/system
#（3）创建制作ISO文件的目录，usb目录用于存放LiveUSB的内容，包括最终系统景象文件
#boot目录存放GRUB相关的文件
#live目录存放内核及辅助系统文件等
mkdir -pv ${LIVEUSB}/usb/{boot,live}
#（4）创建软件包编译目录
mkdir -pv ${LIVEUSB}/{build,download}

export BUILD_DIR=${LIVEUSB}/build
export DOWNLOAD_DIR=${LIVEUSB}/download

#liveusb filesystem build
pushd ${LIVEUSB}/system
echo "copying the files to system..."
#cp -a /{bin,dev,etc,home,lib,lib64,run,sbin,tmp,usr,var} ./
#cp -a /{bin,dev,etc,lib,lib64,run,sbin,tmp,usr,var,opt} ./
cp -a /{dev,etc,run,usr,var,opt} ./

#如果主系统存在/lib64目录，则把/lib64内容移动到/system/usr/lib64下，并创建
#/system/lib64软链接指向/system/usr/lib64.
ROOT_DIR="bin lib lib32 lib64 libx32 sbin"
for root_dir in $ROOT_DIR
do
if [ -d /$root_dir ];then
	cp -a /$root_dir ./usr/
	ln -svf usr/$root_dir ./
fi
done

mkdir -vp media mnt proc root srv sys home tmp
#创建默认用户haoos和root，密码为1
set +e
chroot ${LIVEUSB}/system rm -rf haoos
chroot ${LIVEUSB}/system userdel haoos
chroot ${LIVEUSB}/system groupdel haoos
chroot ${LIVEUSB}/system groupadd haoos
chroot ${LIVEUSB}/system useradd -m -s /bin/bash  -g haoos haoos
echo "root:1" | chroot ${LIVEUSB}/system/ chpasswd
echo "haoos:1" | chroot ${LIVEUSB}/system/ chpasswd
set -e

rm -rf usr/src
rm -rf lib/modules

rm -rf lib/udev/write_*
rm -f etc/udev/rules.d/70*

rm ${LIVEUSB}/system/etc/fstab
cat > ${LIVEUSB}/system/etc/fstab << EOF
none	/proc		proc	defaults	0	0
sysfs	/sys		sysfs	defaults	0	0
devpts	/dev/pts	devpts	gid=4,mode=620	0	0
#tmpfs	/dev/shm	tmpfs	defaults	0	0
EOF

rm ${LIVEUSB}/system/etc/mtab
cat > ${LIVEUSB}/system/etc/mtab << EOF
none	/proc		proc	defaults	0	0
sysfs	/sys		sysfs	defaults	0	0
devpts	/dev/pts	devpts	gid=4,mode=620	0	0
EOF

#build liveusb kernel
pushd /lfs/linux-5.10.17
#拷贝内核文件到live目录
cp -av arch/x86/boot/bzImage ${LIVEUSB}/usb/live/liveusb-kernel
#安装内核到文件系统
make INSTALL_MOD_PATH=${LIVEUSB}/system/ INSTALL_MOD_STRIP=1 modules_install

popd #linux-5.10.17
#done

popd #${LIVEUSB}/system

#build liveusb initramfs
CURRENT_DIR=`dirname $0`
. $CURRENT_DIR/initramfs-liveusb.sh
#done

#创建USB启动盘识别标签
echo "HaoOS's LiveUSB" > ${LIVEUSB}/usb/LABEL

#将所需的文件和目录制作成镜像文件
pushd ${LIVEUSB}/system
mksquashfs * ${LIVEUSB}/usb/SYSTEM.img
popd #${LIVEUSB}/system

#grub2 install
pushd ${LIVEUSB}/usb
#1
#mkdir -p boot/grub
#2安装grub2的模块文件,这里从lfs系统拷贝，system没有字体文件。
cp -av /boot/grub boot/

#3创建GRUB-2的启动配置文件
cat > ${LIVEUSB}/usb/boot/grub/grub.cfg << "EOF"
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
menuentry "HaoOS's LiveUSB" {
	set gfxpayload=keep
	echo    '载入 Linux 5.10.17 ...'
	linux	/live/liveusb-kernel
	echo    '载入初始化内存盘...'
	initrd	/live/liveusb-initramfs.img
}
menuentry '重启'{
	reboot
}
menuentry '关机'{
	halt
}
menuentry '进入UEFI界面'{
	fwsetup
}
EOF

#4创建LiveUSB启动文件
#-p --prefix-directory.Set the $prefix variable
export PREFIX=/boot/grub
grub-mkimage -o ${LIVEUSB}/core.img -p $PREFIX -O i386-pc iso9660 linux biosdisk
cat /usr/lib/grub/i386-pc/cdboot.img ${LIVEUSB}/core.img \
	> ${LIVEUSB}/usb/boot/liveusb.img
popd #${LIVEUSB}/usb

#添加UEFI启动支持
tar xf /sources/other-sources/EFI.tar.xz -C ${LIVEUSB}/usb/

#generate usb file
pushd ${LIVEUSB}
mkisofs -R -boot-info-table -no-emul-boot -boot-load-size 4 -b boot/liveusb.img -V "myliveusb" \
	-o haoos-liveusb.iso usb
popd
