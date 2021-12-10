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
export LFS_SRC_DIR=/sources/lfs-sources

#执行kernel.cmd
./os-build/install.sh -f ./os-build/lfs-list-chapter10

rm -rf linux-firmware-20210315
tar xf $LFS_SRC_DIR/linux-firmware-20210315.tar.xz
pushd linux-firmware-20210315
make install
popd
rm -rf linux-firmware-20210315

popd #/lfs
