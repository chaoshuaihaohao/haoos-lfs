#!/bin/bash
set -e
LIVEUSB=/opt/liveusb
TMP_DIR=${LIVEUSB}/tmpfs/tmp

pushd $TMP_DIR

mkdir -vp ${TMP_DIR}/sbin &&
cat > ${TMP_DIR}/sbin/mkinitramfs << "EOF"
#!/bin/bash
# This file based in part on the mkinitramfs script for the LFS LiveUSB
# written by Alexander E. Patrakov and Jeremy Huntwork.

copy()
{
  local file

  if [ "$2" = "lib" ]; then
    file=$(PATH=/lib:/usr/lib type -p $1)
  else
    file=$(type -p $1)
  fi

  if [ -n "$file" ] ; then
    cp $file $WDIR/$2
  else
    echo "Missing required file: $1 for directory $2"
    rm -rf $WDIR
    exit 1
  fi
}

if [ -z $1 ] ; then
  INITRAMFS_FILE=initrd.img-no-kmods
else
  KERNEL_VERSION=$1
  INITRAMFS_FILE=initrd.img-$KERNEL_VERSION
fi

if [ -n "$KERNEL_VERSION" ] && [ ! -d "/lib/modules/$1" ] ; then
  echo "No modules directory named $1"
  exit 1
fi

printf "Creating $INITRAMFS_FILE... "

binfiles="sh cat cp dd killall ls mkdir mknod mount "
binfiles="$binfiles umount sed sleep ln rm uname"
binfiles="$binfiles readlink basename"
#add by chenhao
binfiles="$binfiles grep sed awk sleep touch chgrp chmod find"

# Systemd installs udevadm in /bin. Other udev implementations have it in /sbin
if [ -x /bin/udevadm ] ; then binfiles="$binfiles udevadm"; fi

sbinfiles="modprobe blkid switch_root"

#Optional files and locations
for f in mdadm mdmon udevd udevadm; do
  if [ -x /sbin/$f ] ; then sbinfiles="$sbinfiles $f"; fi
done

# Add lvm if present (cannot be done with the others because it
# also needs dmsetup
if [ -x /sbin/lvm ] ; then sbinfiles="$sbinfiles lvm dmsetup"; fi

unsorted=$(mktemp /tmp/unsorted.XXXXXXXXXX)

DATADIR=/opt/liveusb/tmpfs/tmp/usr/share/mkinitramfs
INITIN=init.in

# Create a temporary working directory
WDIR=$(mktemp -d /tmp/initrd-work.XXXXXXXXXX)

# Create base directory structure
mkdir -p $WDIR/{bin,dev,lib/firmware,run,sbin,sys,proc,usr}
mkdir -p $WDIR/etc/{modprobe.d,udev/rules.d}
touch $WDIR/etc/modprobe.d/modprobe.conf
ln -s lib $WDIR/lib64
ln -s ../bin $WDIR/usr/bin

# Create necessary device nodes
mknod -m 640 $WDIR/dev/console c 5 1
mknod -m 664 $WDIR/dev/null    c 1 3

# Install the udev configuration files
if [ -f /etc/udev/udev.conf ]; then
  cp /etc/udev/udev.conf $WDIR/etc/udev/udev.conf
fi

for file in $(find /etc/udev/rules.d/ -type f) ; do
  cp $file $WDIR/etc/udev/rules.d
done

# Install any firmware present
cp -a /lib/firmware $WDIR/lib

# Copy the RAID configuration file if present
if [ -f /etc/mdadm.conf ] ; then
  cp /etc/mdadm.conf $WDIR/etc
fi

# Install the init file
install -m0755 $DATADIR/$INITIN $WDIR/init

if [  -n "$KERNEL_VERSION" ] ; then
  if [ -x /bin/kmod ] ; then
    binfiles="$binfiles kmod"
  else
    binfiles="$binfiles lsmod"
    sbinfiles="$sbinfiles insmod"
  fi
fi

# Install basic binaries
for f in $binfiles ; do
  if [ -e /bin/$f ]; then d="/bin"; else d="/usr/bin"; fi
  ldd $d/$f | sed "s/\t//" | cut -d " " -f1 >> $unsorted
  copy $d/$f bin
done

for f in $sbinfiles ; do
  ldd /sbin/$f | sed "s/\t//" | cut -d " " -f1 >> $unsorted
  copy $f sbin
done

# Add udevd libraries if not in /sbin
if [ -x /lib/udev/udevd ] ; then
  ldd /lib/udev/udevd | sed "s/\t//" | cut -d " " -f1 >> $unsorted
elif [ -x /lib/systemd/systemd-udevd ] ; then
  ldd /lib/systemd/systemd-udevd | sed "s/\t//" | cut -d " " -f1 >> $unsorted
fi

# Add module symlinks if appropriate
if [ -n "$KERNEL_VERSION" ] && [ -x /bin/kmod ] ; then
  ln -s kmod $WDIR/bin/lsmod
  ln -s kmod $WDIR/bin/insmod
fi

# Add lvm symlinks if appropriate
# Also copy the lvm.conf file
if  [ -x /sbin/lvm ] ; then
  ln -s lvm $WDIR/sbin/lvchange
  ln -s lvm $WDIR/sbin/lvrename
  ln -s lvm $WDIR/sbin/lvextend
  ln -s lvm $WDIR/sbin/lvcreate
  ln -s lvm $WDIR/sbin/lvdisplay
  ln -s lvm $WDIR/sbin/lvscan

  ln -s lvm $WDIR/sbin/pvchange
  ln -s lvm $WDIR/sbin/pvck
  ln -s lvm $WDIR/sbin/pvcreate
  ln -s lvm $WDIR/sbin/pvdisplay
  ln -s lvm $WDIR/sbin/pvscan

  ln -s lvm $WDIR/sbin/vgchange
  ln -s lvm $WDIR/sbin/vgcreate
  ln -s lvm $WDIR/sbin/vgscan
  ln -s lvm $WDIR/sbin/vgrename
  ln -s lvm $WDIR/sbin/vgck
  # Conf file(s)
  cp -a /etc/lvm $WDIR/etc
fi

# Install libraries
sort $unsorted | uniq | while read library ; do
# linux-vdso and linux-gate are pseudo libraries and do not correspond to a file
# libsystemd-shared is in /lib/systemd, so it is not found by copy, and
# it is copied below anyway
  if [[ "$library" == linux-vdso.so.1 ]] ||
     [[ "$library" == linux-gate.so.1 ]] ||
     [[ "$library" == libsystemd-shared* ]]; then
    continue
  fi

  copy $library lib
done

if [ -d /lib/udev ]; then
  cp -a /lib/udev $WDIR/lib
fi
if [ -d /lib/systemd ]; then
  cp -a /lib/systemd $WDIR/lib
fi
if [ -d /lib/elogind ]; then
  cp -a /lib/elogind $WDIR/lib
fi

# Install the kernel modules if requested
if [ -n "$KERNEL_VERSION" ]; then
  find                                                                        \
     /lib/modules/$KERNEL_VERSION/kernel/{acpi}					\
     /lib/modules/$KERNEL_VERSION/kernel/{crypto,fs,lib}                      \
     /lib/modules/$KERNEL_VERSION/kernel/drivers/{block,ata,md,firewire}      \
     /lib/modules/$KERNEL_VERSION/kernel/drivers/{scsi,message,pcmcia,virtio} \
     /lib/modules/$KERNEL_VERSION/kernel/drivers/usb/{host,storage}           \
     /lib/modules/$KERNEL_VERSION/kernel/drivers/{hid,input}		      \
     /lib/modules/$KERNEL_VERSION/kernel/drivers/{gpu,video,media,iommu}			      \
     /lib/modules/$KERNEL_VERSION/kernel/drivers/i2c			      \
     -type f 2> /dev/null | cpio --make-directories -p --quiet $WDIR

  cp /lib/modules/$KERNEL_VERSION/modules.{builtin,order}                     \
            $WDIR/lib/modules/$KERNEL_VERSION

  depmod -b $WDIR $KERNEL_VERSION
fi

( cd $WDIR ; find . | cpio -o -H newc --quiet | gzip -9 ) > $INITRAMFS_FILE

# Prepare early loading of microcode if available
if ls /lib/firmware/intel-ucode/* >/dev/null 2>&1 ||
   ls /lib/firmware/amd-ucode/*   >/dev/null 2>&1; then

# first empty WDIR to reuse it
  rm -r $WDIR/*

  DSTDIR=$WDIR/kernel/x86/microcode
  mkdir -p $DSTDIR

  if [ -d /lib/firmware/amd-ucode ]; then
    cat /lib/firmware/amd-ucode/microcode_amd*.bin > $DSTDIR/AuthenticAMD.bin
  fi

  if [ -d /lib/firmware/intel-ucode ]; then
    cat /lib/firmware/intel-ucode/* > $DSTDIR/GenuineIntel.bin
  fi

  ( cd $WDIR; find . | cpio -o -H newc --quiet ) > microcode.img
  cat microcode.img $INITRAMFS_FILE > tmpfile
  mv tmpfile $INITRAMFS_FILE
  rm microcode.img
fi

# Remove the temporary directories and files
rm -rf $WDIR $unsorted
printf "done.\n"

EOF

chmod 0755 ${TMP_DIR}/sbin/mkinitramfs

mkdir -vp ${TMP_DIR}/usr/share/mkinitramfs &&
cat > ${TMP_DIR}/usr/share/mkinitramfs/init.in << "EOF"
#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
export PATH

problem()
{
   printf "Encountered a problem!\n\nDropping you to a shell.\n\n"
   sh
}

no_device()
{
   printf "The device %s, which is supposed to contain the\n" $1
   printf "root file system, does not exist.\n"
   printf "Please fix this problem and exit this shell.\n\n"
}

no_mount()
{
   printf "Could not mount device %s\n" $1
   printf "Sleeping forever. Please reboot and fix the kernel command line.\n\n"
   printf "Maybe the device is formatted with an unsupported file system?\n\n"
   printf "Or maybe filesystem type autodetection went wrong, in which case\n"
   printf "you should add the rootfstype=... parameter to the kernel command line.\n\n"
   printf "Available partitions:\n"
}

do_mount_root()
{
   mkdir /.root
   [ -n "$rootflags" ] && rootflags="$rootflags,"
   rootflags="$rootflags$ro"

   case "$root" in
      /dev/*    ) device=$root ;;
      UUID=*    ) eval $root; device="/dev/disk/by-uuid/$UUID" ;;
      PARTUUID=*) eval $root; device="/dev/disk/by-partuuid/$PARTUUID" ;;
      LABEL=*   ) eval $root; device="/dev/disk/by-label/$LABEL" ;;
      ""        ) echo "No root device specified." ; problem ;;
   esac

   while [ ! -b "$device" ] ; do
       no_device $device
       problem
   done

   if ! mount -n -t "$rootfstype" -o "$rootflags" "$device" /.root ; then
       no_mount $device
       cat /proc/partitions
       while true ; do sleep 10000 ; done
   else
       echo "Successfully mounted device $root"
   fi
}

export SYSTEM=/SYSTEM
do_mount_root_liveusb()
{
#为Live系统准备目录
mkdir -p ${SYSTEM} /mnt
mount -t tmpfs tmpfs /mnt
mkdir -p /mnt/{usb,system}

#设置等待U盘时间
DELAY=$(cat /proc/cmdline | awk -F'rootdelay=' '{print $2}' \
	| awk -F' ' '{print $1}')
if [ "${DELAY}" = "" ];then
	sleep 10
else
	sleep ${DELAY}
fi

#搜索LiveUSB所在的U盘设备
#（1）UUID编号识别。
#UUID=$(cat /proc/cmdline | awk -F'UUID=' '{print $2}' \
#	| awk -F'"' '{print $1}')
#if [ "${UUID}" = "" ];then
#	LiveUSB=$(cat /proc/cmdline | awk -F'root=' '{print $2}' \
#		| awk '{print $1}')
#else
#	LiveUSB=$(blkid -U ${UUID})
#fi
#if [ "${LiveUSB}" != "" ]; then
#	mount ${LiveUSB} /mnt/usb
#else
#	exit
#fi
#(2)通过在U盘中放置标记文件识别U盘设备
for i in $(find /sys/block/sd*)
do
  REMOVEABLE=$(cat $i/removable)
  if [ "${REMOVEABLE}" = "1" ];then
    for j in $(blkid /dev/$(basename $i)* -o device)
    do
      mount $j /mnt/usb 2>/dev/null
      if test $? = 0;then
        if [ -f /mnt/usb/LABEL ];then
	  if grep -q "HaoOS's LiveUSB" /mnt/usb/LABEL;then
	    break 2;
	  fi
	fi
	umount /mnt/usb
      fi
    done
  fi
done

mount -t tmpfs tmpfs ${SYSTEM}
mount -o loop -t squashfs /mnt/usb/SYSTEM.img /mnt/system
mount -t aufs -o dirs=${SYSTEM}=rw:mnt/system=ro aufs ${SYSTEM}
mkdir -p ${SYSTEM}/{dev,proc,sys,tmp,mnt,initrd,home}

mkdir -p ${SYSTEM}/var/{run,log,lock,mail,spool}
mkdir -p ${SYSTEM}/var/{opt,cache,lib/{misc,locate},local}

touch ${SYSTEM}/var/run/utmp ${SYSTEM}/var/log/{btmp,lastlog,wtmp}
#chgrp utmp ${SYSTEM}/var/run/utmp ${SYSTEM}/var/log/lastlog
chmod 664 ${SYSTEM}/var/run/utmp ${SYSTEM}/var/log/lastlog
chmod 1777 ${SYSTEM}/tmp
chmod 0700 ${SYSTEM}/root
}

do_try_resume()
{
   case "$resume" in
      UUID=* ) eval $resume; resume="/dev/disk/by-uuid/$UUID"  ;;
      LABEL=*) eval $resume; resume="/dev/disk/by-label/$LABEL" ;;
   esac

   if $noresume || ! [ -b "$resume" ]; then return; fi

   ls -lH "$resume" | ( read x x x x maj min x
       echo -n ${maj%,}:$min > /sys/power/resume )
}

init=/sbin/init
root=
rootdelay=
rootfstype=auto
ro="ro"
rootflags=
device=
resume=
noresume=false

#
modprobe nls_iso8859-1
modprobe dm-mirror
modprobe i2c-i801
#加载必要的磁盘block驱动
modprobe virtio_blk
modprobe usb_storage
modprobe uas
modprobe ahci
modprobe xhci-pci
modprobe nvme

#添加必要的显卡驱动
modprobe drm
modprobe radeon
modprobe amdgpu
#modprobe i915
#modprobe virtio-gpu
modprobe video

#加载必要的USB键盘驱动
modprobe psmouse
modprobe hid-generic
modprobe usbkbd
modprobe usbmouse
modprobe usbhid

#挂载必要的文件系统
mount -n -t devtmpfs devtmpfs /dev
mount -n -t proc     proc     /proc
mount -n -t sysfs    sysfs    /sys
mount -n -t tmpfs    tmpfs    /run

read -r cmdline < /proc/cmdline

for param in $cmdline ; do
  case $param in
    init=*      ) init=${param#init=}             ;;
    root=*      ) root=${param#root=}             ;;
    rootdelay=* ) rootdelay=${param#rootdelay=}   ;;
    rootfstype=*) rootfstype=${param#rootfstype=} ;;
    rootflags=* ) rootflags=${param#rootflags=}   ;;
    resume=*    ) resume=${param#resume=}         ;;
    noresume    ) noresume=true                   ;;
    ro          ) ro="ro"                         ;;
    rw          ) ro="rw"                         ;;
    initramfs   ) echo "Go to initramfs mode..." ; exec sh ;;
  esac
done

# udevd location depends on version
if [ -x /sbin/udevd ]; then
  UDEVD=/sbin/udevd
elif [ -x /lib/udev/udevd ]; then
  UDEVD=/lib/udev/udevd
elif [ -x /lib/systemd/systemd-udevd ]; then
  UDEVD=/lib/systemd/systemd-udevd
else
  echo "Cannot find udevd nor systemd-udevd"
  problem
fi

${UDEVD} --daemon --resolve-names=never
udevadm trigger
udevadm settle

if [ -f /etc/mdadm.conf ] ; then mdadm -As                       ; fi
if [ -x /sbin/vgchange  ] ; then /sbin/vgchange -a y > /dev/null ; fi
if [ -n "$rootdelay"    ] ; then sleep "$rootdelay"              ; fi

#do_try_resume # This function will not return if resuming from disk
#do_mount_root
do_mount_root_liveusb

killall -w ${UDEVD##*/}

#exec switch_root /.root "$init" "$@"
#exec switch_root /mnt/system /sbin/init
exec switch_root ${SYSTEM} /sbin/init


EOF

${TMP_DIR}/sbin/mkinitramfs 5.10.17
mv -v initrd.img-5.10.17 ${LIVEUSB}/usb/live/liveusb-initramfs.img
rm -rf ${TMP_DIR}/*

popd
