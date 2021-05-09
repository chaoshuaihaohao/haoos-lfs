#!/bin/bash
set -e
#第 7 章 进入 Chroot 并构建其他临时工具
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

echo "export LFS=/mnt/lfs" >  ~/.bash_profile
source ~/.bash_profile
echo $LFS

#拷贝haoos-lfs文件
cp -a * $LFS/haoos/

#7.2. 改变$LFS所有者
chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
  x86_64) chown -R root:root $LFS/lib64 ;;
esac

#7.3. 准备虚拟内核文件系统
mkdir -pv $LFS/{dev,proc,sys,run}

#7.3.1. 创建初始设备节点
if [ ! -c $LFS/dev/console ];then
	mknod -m 600 $LFS/dev/console c 5 1
fi
if [ ! -c $LFS/dev/null ];then
	mknod -m 666 $LFS/dev/null c 1 3
fi

#7.3.2. 挂载和填充 /dev
mount -v --bind /dev $LFS/dev

#7.3.3. 挂载虚拟内核文件系统
mount -v --bind /dev/pts $LFS/dev/pts
mount -vt proc proc $LFS/proc
mount -vt sysfs sysfs $LFS/sys
mount -vt tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
  mkdir -pv $LFS/$(readlink $LFS/dev/shm)
fi

#7.4. 进入 Chroot 环境
chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="$TERM"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    /bin/bash --login +h
