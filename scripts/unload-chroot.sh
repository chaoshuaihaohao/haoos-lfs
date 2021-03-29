#!/bin/bash
if [ `id -u` != 0 ];then
        echo Permision deley, Please run as root!
        exit
fi

echo "export LFS=/mnt/lfs" >  ~/.bash_profile
source ~/.bash_profile
echo $LFS

umount $LFS/dev{/pts,}
umount $LFS/{sys,proc,run}
