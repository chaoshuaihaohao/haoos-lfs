#!/bin/bash
set -e
#Chapter 11. The End - Part 2
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

echo "export LFS=/mnt/lfs" >  ~/.bash_profile
source ~/.bash_profile
echo $LFS

#do this if the dir is not link
#pushd $LFS
#mv lib/systemd/* lib/systemd/ && rm -rf lib/systemd
#mv lib/* usr/lib/ && rm -rf lib
#ln -svf usr/lib lib
#mkdir -vp usr/lib64
#mv lib64/* usr/lib64/ && rm -rf lib64
#ln -svf usr/lib64 lib64
#mv sbin/* usr/sbin/ && rm -rf sbin
#ln -svf usr/sbin sbin
#popd

umount -Rv $LFS
shutdown -r now
