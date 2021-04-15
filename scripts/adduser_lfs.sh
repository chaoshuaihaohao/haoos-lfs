#!/bin/bash
set -e
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

echo "export LFS=/mnt/lfs" >  ~/.bash_profile
source ~/.bash_profile

mkdir -pv $LFS/{etc,var}
mkdir -pv $LFS/usr/{bin,lib,lib32,libx32,sbin}
ln -svf $LFS/usr/bin	$LFS/bin
ln -svf $LFS/usr/lib	$LFS/lib
ln -svf $LFS/usr/lib32	$LFS/lib32
ln -svf $LFS/usr/libx32	$LFS/libx32
ln -svf $LFS/usr/sbin	$LFS/sbin

case $(uname -m) in
  x86_64) mkdir -pv $LFS/usr/lib64 && ln -svf $LFS/usr/lib64 $LFS/lib64;;
esac

mkdir -pv $LFS/tools

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
