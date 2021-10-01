#!/bin/bash
set -e
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

set +e
#将/etc/ssh/sshd_config中，#PermitRootLogin prohibit-password取消注
#释并修改为PermitRootLogin yes。
sed -i 's/#PermitRootLogin\ prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart sshd
set -e

#第 2 章 准备宿主系统
echo "Please set the mount dev of lfs you want(such as '/dev/sdb' or '/dev/vdb':)"
read lfs_dev
#echo $lfs_dev

#2.6. 设置 $LFS 环境变量
echo "export LFS=/mnt/lfs" >  ~/.bash_profile
source ~/.bash_profile

#2.7. 挂载新的分区
#磁盘分区,grub 300M, 交换分区2G, 其余的作为lfs构建分区
fdisk $lfs_dev << EOF
g
n
1

+1M
n
2

+512M
n
3


t
1
4
t
2
1
p
w
EOF

#挂载efi分区
set +e
umount ${lfs_dev}2
set -e
mkdir -pv $LFS/boot/efi
mkfs.fat -v ${lfs_dev}2
if [ ! "`grep "${lfs_dev}2  /boot/efi  vfat      umask=0077     0     1" /etc/fstab | head -1`" ];then
#	echo "${lfs_dev}2  /boot/efi  vfat      umask=0077     0     1" >> /etc/fstab
	echo "${lfs_dev}2  /boot/efi  vfat      umask=0077     0     1"
fi

#挂载lfs分区
#mkdir -pv $LFS
set +e
umount ${lfs_dev}3
mkfs -v -t ext4 ${lfs_dev}3
set -e
if [ ! "`grep "${lfs_dev}3  $LFS ext4   defaults      1     1" /etc/fstab | head -1`" ];then
#	echo "${lfs_dev}3  $LFS ext4   defaults      1     1" >> /etc/fstab
	echo "${lfs_dev}3  $LFS ext4   defaults      1     1"
fi
mount ${lfs_dev}3 $LFS
#mount -a
