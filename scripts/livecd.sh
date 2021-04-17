#!/bin/bash
set -e
#Chapter 11. The End - Part 2
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

#copy file
#cp /usr/src/linux-5.10.17/usr/{gen_initramfs.sh,gen_init_cpio}

#
export LIVECD=/opt/livecd
rm -rf ${LIVECD}/*
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
echo "copying the files to system..."
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
#1.init
pushd ${LIVECD}/image/initramfs
cat > init << "EOF"
#!/bin/bash
mount -t	proc	proc	/proc
mount -t	sysfs	sysfs	/sys
mount -n -t	tmpfs	-o mode=0755	udev	/dev
cp --preserve=all --recursive --remove-destination
chmod 1777 /dev/shm
echo "" > /sys/kernel/uevent_helper
udevd --daemon
mkdir -p /dev/.udev/queue
udevadm	trigger
udevadm	settle
export SYSTEM=/SYSTEM
mkdir -p ${SYSTEM} /mnt
mount -t tmpfs	tmpfs	/mnt
mkdir -p /mnt/{cdrom,system}
CDROM_OK="F"
while [ "${CDROM_OK}" = "F" ]
do
	for i in $(cat /proc/sys/dev/cdrom/info | grep "drive name" \
		| sed 's@drive name:@@g')
	do
		LABEL=$(dd if=/dev/${i} bs=1 skip=32808 count=32 2>/dev/null)
		LABEL=$(echo "${LABEL}" | grep -o "[^ ]\+\(\+[^ ]\+\)*")
		if [ "${LABEL}" = "mylivecd" ]; then
			mount -t iso9660 /dev/${i} /mnt/cdrom
			break;
		fi
	done
	if [ "${CDROM_OK}" = "F" ]; then
		sleep 3
	fi
done
popd
mount -t tmpfs	tmpfs	${SYSTEM}
mount -o loop -t squashfs /mnt/cdrom/SYSTEM.img /mnt/system
mount -t aufs -o dirs=${SYSTEM}=rw:mnt/system=ro aufs ${SYSTEM}
mkdir -p ${SYSTEM}/{dev,proc,sys,tmp,mnt,initrd,home}

mkdir -p ${SYSTEM}/var/{run,log,lock,mail,spool}
mkdir -p ${SYSTEM}/var/{opt,cache,lib/{misc,locate},local}

touch ${SYSTEM}/var/run/utmp ${SYSTEM}/var/log/btmp,lastlog,wtmp}
chgrp utmp ${SYSTEM}/var/run/utmp ${SYSTEM}/var/log/lastlog
chmod 664 ${SYSTEM}/car/run/utmp ${SYSTEM}/var/log/lastlog

chmod 1777 ${SYSTEM}/tmp
chmod 0700 ${SYSTEM}/root
killall udevd
exec switch_root ${SYSTEM} /sbin/init
EOF

chmod +x init

#2.build initramfs file system
#(1)
mkdir bin etc lib proc sys
#(2)
cp -a /bin/{chgrp,cp,grep,mkdir,sed,dd} bin
cp -a /bin/{cat,chmod,mount,sleep} bin
#cp -a /usr/bin/{touch,killall} bin
cp -a /bin/{touch,killall} bin
cp -a /sbin/{switch_root,udevd,udevadm} bin
cp -a /bin/bash bin
#(3)
cp -a /lib/udev lib
cp -a /etc/udev etc
#(4)
cp -a /etc/{group,passwd} etc
#(5)
touch etc/fstab
#(6)
for i in $(ldd bin/* lib/udev/*id | grep "=>" | sed 's@(.*)@@g' \
	| sort | awk -F'=>' '{print $2}' | uniq);
do
	cp -v ${i} lib/
done
#cp -v /lib/ld-linux.so.2 lib/
cp -v /lib/libnss_files.so.2 lib/
#(7)
echo "haoos's LiveCD" > ${LIVECD}/iso/LABEL
#3.generate initramfs file
pushd ${LIVECD}/image
cp -av /lfs/linux-5.10.17/usr .
usr/gen_initramfs.sh -o initramfs.img initramfs 
cp initramfs.img ${LIVECD}/iso/boot/
#cp initramfs.img.gz ${LIVECD}/iso/boot/
popd
#4.end build
popd
#todo...

pushd /lfs/linux-5.10.17
#
cp -av arch/x86/boot/bzImage ${LIVECD}/iso/boot/livecd-kernel
#
make INSTALL_MOD_PATH=${LIVECD}/system/ modules_install

#cp -av /boot/initrd.img-5.10.17-lfs-20210326-systemd ${LIVECD}/iso/boot/initramfs.img.gz
popd #linux-5.10.17

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
