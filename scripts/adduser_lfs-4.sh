#!/bin/bash
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
export LFS=/mnt/lfs

#4.2. 在 LFS 文件系统中创建有限目录布局
. build/cmd/lfs/chapter04/creatingminlayout.cmd

#4.3. 添加 LFS 用户
getent group | grep lfs
if [ $? -eq 0 ];then
	userdel lfs
	groupdel lfs
	rm /home/lfs/* -rf
fi
#拷贝haoos-lfs到/home/lfs目录
mkdir -pv /home/lfs
cp -a ../haoos-lfs /home/lfs/
#change the owner and group of /home/lfs from root to lfs.
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
chown -v -R lfs:lfs /home/lfs
#chown -v -R lfs /home/lfs
#chgrp -v -R lfs /home/lfs

sed -i 's/passwd lfs/echo lfs:1 | chpasswd/g' build/cmd/lfs/chapter04/addinguser.cmd
. build/cmd/lfs/chapter04/addinguser.cmd
