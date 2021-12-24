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
export RELEASE=/haoos/release
rm -rf ${RELEASE}
mkdir -pv $RELEASE
#2.创建制作相关的目录
#（1）创建制作初始化辅助系统的目录
mkdir -pv ${RELEASE}/initramfs
#（2）创建制作最终文件系统的目录
mkdir -pv ${RELEASE}/squashfs
#（3）创建制作ISO文件的目录，live目录用于存放Live的内容，包括最终系统景象文件
#boot目录存放GRUB相关的文件
#live目录存放内核及辅助系统文件等
mkdir -pv ${RELEASE}/ISO/{boot,live}

#RELEASE filesquashfs build
pushd ${RELEASE}/squashfs
echo "copying the files to squashfs..."
#cp -a /{bin,dev,etc,home,lib,lib64,run,sbin,tmp,usr,var} ./
#cp -a /{bin,dev,etc,lib,lib64,run,sbin,tmp,usr,var,opt} ./
cp -a /{dev,etc,run,usr,lib64,var,opt} ./

#如果主系统存在/lib64目录，则把/lib64内容移动到/squashfs/usr/lib64下，并创建
#/squashfs/lib64软链接指向/squashfs/usr/lib64.
#ROOT_DIR="bin lib lib32 lib64 libx32 sbin"
ROOT_DIR="bin lib lib32 libx32 sbin"
for root_dir in $ROOT_DIR
do
if [ -d $root_dir ];then
	cp -a $root_dir ./usr/
fi
ln -svf usr/$root_dir ./
done

mkdir -vp media mnt proc root srv sys home tmp
#创建默认用户haoos和root，密码为1
set +e
#chroot ${RELEASE}/squashfs rm -rf haoos
#chroot ${RELEASE}/squashfs userdel haoos
#chroot ${RELEASE}/squashfs groupdel haoos
#chroot ${RELEASE}/squashfs groupadd haoos
#chroot ${RELEASE}/squashfs useradd -m -s /bin/bash  -g haoos haoos
#echo "root:1" | chroot ${RELEASE}/squashfs/ chpasswd
#echo "haoos:1" | chroot ${RELEASE}/squashfs/ chpasswd
set -e

cat > ${RELEASE}/squashfs/etc/haoos_defconf << "EOF"
#!/bin/bash
gsettings set org.gnome.Terminal.Legacy.Settings theme-variant 'dark'

gsettings set org.gnome.desktop.interface monospace-font-name '文泉驿等宽微米黑 Bold 10'

gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/saigepengkegirl.jpg'

gsettings set org.gnome.desktop.screensaver picture-uri 'file:///usr/share/backgrounds/saigepengkegirl.jpg'

gsettings set org.gnome.desktop.input-sources mru-sources "[('ibus', 'libpinyin'), ('xkb', 'us')]"

gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'libpinyin')]"

EOF

chmod 777 ${RELEASE}/squashfs/etc/haoos_defconf

cat > ${RELEASE}/squashfs/etc/systemd/system/hello.service << "EOF"
# Simple service unit file to use for testing
# startup configurations with squashfsd.
# By David Both
# Licensed under GPL V2
#
[Unit]
Description=My hello shell script
[Service]
Type=oneshot
ExecStart=/etc/haoos_defconf
StandardOutput=journal+console
[Install]
WantedBy=multi-user.target
EOF

#chroot ${RELEASE}/squashfs systemctl enable hello.service

#rm -rf usr/src
#rm -rf lib/modules

#rm -rf lib/udev/write_*
#rm -f etc/udev/rules.d/70*

rm -f ${RELEASE}/squashfs/etc/fstab
cat > ${RELEASE}/squashfs/etc/fstab << EOF
none	/proc		proc	defaults	0	0
sysfs	/sys		sysfs	defaults	0	0
devpts	/dev/pts	devpts	gid=4,mode=620	0	0
#tmpfs	/dev/shm	tmpfs	defaults	0	0
EOF

rm -f ${RELEASE}/squashfs/etc/mtab
cat > ${RELEASE}/squashfs/etc/mtab << EOF
none	/proc		proc	defaults	0	0
sysfs	/sys		sysfs	defaults	0	0
devpts	/dev/pts	devpts	gid=4,mode=620	0	0
EOF

#build RELEASE kernel
#pushd /lfs/linux-5.10.17
#拷贝内核文件到live目录
#cp -av arch/x86/boot/bzImage ${RELEASE}/ISO/live/live-kernel
#安装内核到文件系统
#make INSTALL_MOD_PATH=${RELEASE}/squashfs/ INSTALL_MOD_STRIP=1 modules_install

#popd #linux-5.10.17
#done

popd #${RELEASE}/squashfs

#build RELEASE initramfs
CURRENT_DIR=`dirname $0`
. $CURRENT_DIR/initramfs-live.sh
#done

#创建live启动盘识别标签
echo "HaoOS's RELEASE" > ${RELEASE}/ISO/LABEL

#将所需的文件和目录制作成镜像文件
pushd ${RELEASE}/squashfs
mksquashfs * ${RELEASE}/ISO/squashfs.img
popd #${RELEASE}/squashfs

#grub2 install
pushd ${RELEASE}/ISO
#1
#mkdir -p boot/grub
#2安装grub2的模块文件,这里从lfs系统拷贝，squashfs没有字体文件。
#cp -av /boot/grub boot/
cp -av /boot .
kernel_version=`ls /lib/modules`

cp -av ./boot/vmlinuz-$kernel_version ${RELEASE}/ISO/live/live-kernel

#3创建GRUB-2的启动配置文件
cat > ${RELEASE}/ISO/boot/grub/grub.cfg << "EOF"
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
menuentry "HaoOS's RELEASE" {
	set gfxpayload=keep
	echo    '载入 Linu ...'
	linux	/live/live-kernel
	echo    '载入初始化内存盘...'
	initrd	/live/live-initramfs.img
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

#4创建RELEASE启动文件
#-p --prefix-directory.Set the $prefix variable
export PREFIX=/boot/grub
grub-mkimage -o ${RELEASE}/core.img -p $PREFIX -O i386-pc iso9660 linux biosdisk
cat /usr/lib/grub/i386-pc/cdboot.img ${RELEASE}/core.img \
	> ${RELEASE}/ISO/boot/live.img
popd #${RELEASE}/ISO

#添加UEFI启动支持
tar xf /haoos-lfs/build/src/lfs/EFI.tar.xz -C ${RELEASE}/ISO/

#generate iso file
pushd ${RELEASE}
mkisofs -R -boot-info-table -no-emul-boot -boot-load-size 4 -b boot/live.img -V "mylive" \
	-o haoos-live.iso ISO
popd
