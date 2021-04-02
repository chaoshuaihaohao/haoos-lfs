#!/bin/bash
set -e
if [ `id -u` != 0 ];then
        echo Permision deley, Please run as root!
        exit
fi

#将/etc/ssh/sshd_config中，#PermitRootLogin prohibit-password取消注
#释并修改为PermitRootLogin yes。
sed -i 's/#PermitRootLogin\ prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart sshd

PS3="What you like most of the open source system?"
echo "Please set the mount dev of lfs you want(such as '/dev/sdb':)"
read lfs_dev
#echo $lfs_dev
echo "Please set the mount dev of swap you want(such as '/dev/sdc':)"
read swap_dev
#echo $swap_dev

echo "export LFS=/mnt/lfs" >  ~/.bash_profile
source ~/.bash_profile
#挂载lfs分区
mkdir -pv $LFS
set +e
umount $lfs_dev
mkfs -v -t ext4 $lfs_dev
set -e
if [ ! "`grep "/dev/sdb  /mnt/lfs ext4   defaults      1     1" /etc/fstab | head -1`" ];then
	echo "$lfs_dev  /mnt/lfs ext4   defaults      1     1" >> /etc/fstab
fi
#挂载swap分区
set +e
umount $swap_dev
mkswap $swap_dev
/sbin/swapon -v $swap_dev
set -e
if [ ! "`grep "/dev/sdc  swap swap   defaults      0     0" /etc/fstab | head -1`" ];then
	echo "$swap_dev  swap swap   defaults      0     0" >> /etc/fstab
fi
mount -a

#拷贝lfs source code files.
VMWARE_NAME=`whoami`
VMWARE_IP=`hostname -I | sed 's/\ //g'`
echo "Please set the host name and ip, such as uos@10.16.5.206:"
read HOST
#scp $HOST:~/lfs-sources.tar.gz $VMWARE_NAME@$VMWARE_IP:$LFS/
scp $HOST:~/lfs-sources.tar.gz $LFS/
echo "scp $HOST:~/lfs-sources.tar.gz $VMWARE_NAME@$VMWARE_IP:$LFS/"
