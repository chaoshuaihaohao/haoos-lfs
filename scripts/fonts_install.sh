#!/bin/bash
set -e
#Part IV. Building the LFS System
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi
#Chapter 8. Installing Basic System Software

if [ -n $JOBS ];then
        JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
        if [ ! $JOBS ];then
                JOBS="1"
        fi
fi
export MAKEFLAGS=-j$JOBS

export OTHER_SRC_DIR=$LFS/sources/other-sources

pushd /lfs

tar xvf  $OTHER_SRC_DIR/truetype.tar.xz -C /usr/share/fonts/

popd #/lfs
