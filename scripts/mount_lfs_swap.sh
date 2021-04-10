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

echo "Please set the mount dev of lfs you want(such as '/dev/sdb' or '/dev/vdb':)"
read lfs_dev
#echo $lfs_dev

echo "export LFS=/mnt/lfs" >  ~/.bash_profile
source ~/.bash_profile

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


p
w
EOF

#挂载boot分区，ext4文件系统格式
#mkdir -pv $LFS/boot
#set +e
#echo ${lfs_dev}1
#umount ${lfs_dev}1
#mkfs -v -t ext4 ${lfs_dev}1
#set -e
#if [ ! "`grep "${lfs_dev}1  $LFS/boot ext4   defaults      1     1" /etc/fstab | head -1`" ];then
#        echo "${lfs_dev}1  $LFS/boot ext4   defaults      1     1" >> /etc/fstab
#fi

#挂载efi分区
set +e
#umount ${lfs_dev}2
mkdir -pv $LFS/boot/efi
mkfs.fat -v ${lfs_dev}2
set -e
if [ ! "`grep "${lfs_dev}2  /boot/efi  vfat      umask=0077     0     1" /etc/fstab | head -1`" ];then
	echo "${lfs_dev}2  /boot/efi  vfat      umask=0077     0     1" >> /etc/fstab
fi

#挂载swap分区
#set +e
#umount ${lfs_dev}2
#mkswap ${lfs_dev}2
#/sbin/swapon -v ${lfs_dev}2
#set -e
#if [ ! "`grep "${lfs_dev}2  swap swap   defaults      0     0" /etc/fstab | head -1`" ];then
#	echo "${lfs_dev}2  swap swap   defaults      0     0" >> /etc/fstab
#fi

#挂载lfs分区
#mkdir -pv $LFS
set +e
#umount ${lfs_dev}3
mkfs -v -t ext4 ${lfs_dev}3
set -e
if [ ! "`grep "${lfs_dev}3  $LFS ext4   defaults      1     1" /etc/fstab | head -1`" ];then
	echo "${lfs_dev}3  $LFS ext4   defaults      1     1" >> /etc/fstab
fi
mount -a

#拷贝lfs source code files.
VMWARE_NAME=`whoami`
VMWARE_IP=`hostname -I | sed 's/\ //g'`
echo "Please set the host name and ip, such as "uos@10.16.5.206:""
read HOST
#scp $HOST:~/lfs-sources.tar.gz $VMWARE_NAME@$VMWARE_IP:$LFS/
scp $HOST:~/lfs-sources.tar.gz $LFS/
echo "scp $HOST:~/lfs-sources.tar.gz $VMWARE_NAME@$VMWARE_IP:$LFS/"
