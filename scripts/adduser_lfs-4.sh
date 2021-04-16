#!/bin/bash
set -e
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

echo "export LFS=/mnt/lfs" >  ~/.bash_profile
source ~/.bash_profile

#4.2. 在 LFS 文件系统中创建有限目录布局
mkdir -pv $LFS/{bin,etc,lib,sbin,usr,var}
case $(uname -m) in
  x86_64) mkdir -pv $LFS/lib64 ;;
esac

mkdir -pv $LFS/tools

#4.3. 添加 LFS 用户
set +e
userdel lfs
set -e
rm /home/lfs -rf
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
echo "Please set the new account lfs's password:"
passwd lfs

chown -R lfs $LFS
chgrp -R lfs $LFS
case $(uname -m) in
  x86_64) chown -v lfs $LFS/lib64 ;;
esac

#copy object compile file to lfs account
mkdir -vp /home/lfs/scripts
cp -r `pwd`/* /home/lfs/

#change the owner and group of /home/lfs from root to lfs.
chown -v -R lfs /home/lfs
chgrp -v -R lfs /home/lfs

su - lfs
