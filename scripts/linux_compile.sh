#!/bin/bash
set -e
#Chapter 10. Making the LFS System Bootable
if [ -n $JOBS ];then
        JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
        if [ ! $JOBS ];then
                JOBS="1"
        fi
fi
export MAKEFLAGS=-j$JOBS

#执行kernel.cmd
./os-build/install.sh -f ./os-build/lfs-list-chapter10

rm -rf linux-firmware-20211027
wget https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/snapshot/linux-firmware-20211027.tar.gz
tar xvf linux-firmware-20211027.tar.gz
make install
