#!/bin/bash
#Chapter 7. Entering Chroot and Building Additional Temporary Tools
set -e
if [ `id -u` != 0 ];then
        echo Permision deley, Please run as root!
        exit
fi

echo "export LFS=/mnt/lfs" >  ~/.bash_profile
source ~/.bash_profile
echo $LFS

#拷贝必要的脚本文件
mkdir -vp $LFS/haoos/scripts
cp Makefile $LFS/haoos/
cp scripts/* $LFS/haoos/scripts/

#7.2. Changing Ownership
chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) chown -R root:root $LFS/lib64 ;;
esac

#7.3. Preparing Virtual Kernel File Systems
mkdir -pv $LFS/{dev,proc,sys,run}
#7.3.1. Creating Initial Device Nodes
mknod -m 600 $LFS/dev/console c 5 1
mknod -m 666 $LFS/dev/null c 1 3
#7.3.2. Mounting and Populating /dev
mount -v --bind /dev $LFS/dev
#7.3.3. Mounting Virtual Kernel File Systems
mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
  mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi

#7.4. Entering the Chroot Environment
chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login +h
