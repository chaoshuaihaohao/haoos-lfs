#!/bin/bash
set -e
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi


#备份软件包sources
if [ -d /mnt/lfs ];then
	export LFS=/mnt/lfs
else
	export LFS=/
fi

pushd $LFS/sources
tar czf lfs-sources.tar.xz lfs-sources && rm -rf lfs-sources
tar czf blfs-sources.tar.xz blfs-sources && rm -rf blfs-sources
tar czf other-sources.tar.xz other-sources && rm -rf other-sources
popd
pushd $LFS
tar czf sources.tar.xz sources && rm -rf sources
popd
