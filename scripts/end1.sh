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

umount -Rv $LFS
shutdown -r now
