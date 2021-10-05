#!/bin/bash
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

[ ! -e /etc/bash.bashrc ] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE
export LFS=/mnt/lfs

#4.2. 在 LFS 文件系统中创建有限目录布局
. build/cmd/chapter04/creatingminlayout.cmd

#4.3. 添加 LFS 用户
#echo "Please set the new account lfs's password:"
#passwd lfs
#echo lfs:1 | chpasswd
getent group | grep lfs
if [ $? -eq 0 ];then
	userdel lfs
	groupdel lfs
	rm /home/lfs -rf
fi
sed -i 's/passwd lfs/echo lfs:1 | chpasswd/g' build/cmd/chapter04/addinguser.cmd
. build/cmd/chapter04/addinguser.cmd
