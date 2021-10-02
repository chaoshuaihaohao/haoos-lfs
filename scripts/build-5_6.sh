#!/bin/bash
set -e

if [ -n $JOBS ];then
        JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
        if [ ! $JOBS ];then
                JOBS="1"
        fi
fi
export MAKEFLAGS=-j$JOBS

#DIR="bin lib lib32 lib64 libx32 sbin"
#for dir in $DIR
#do
#	if [ ! -d "$dir" ];then
#		mkdir -pv $LFS/usr/$dir
#		pushd $LFS
#		ln -svf usr/$dir ./
#		popd
#	fi
#done

./os-build/install.sh -f ./os-build/lfs-list-chapter05
./os-build/install.sh -f ./os-build/lfs-list-chapter06

