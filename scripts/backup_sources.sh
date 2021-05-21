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

#删除目录文件，只保留压缩文件和patch文件
for file in `find $LFS/sources/lfs-sources/*`
do
  if [ -d $file ];then
    rm -rfv $file
  fi
done

for file in `find $LFS/sources/blfs-sources/*`
do
  if [ -d $file ];then
    rm -rfv $file
  fi
done

for file in `find $LFS/sources/other-sources/*`
do
  if [ -d $file ];then
    rm -rfv $file
  fi
done

#压缩文件
pushd $LFS/sources
tar czvf lfs-sources.tar.xz lfs-sources && rm -rf lfs-sources
tar czvf blfs-sources.tar.xz blfs-sources && rm -rf blfs-sources
tar czvf other-sources.tar.xz other-sources && rm -rf other-sources
popd

pushd $LFS
tar czvf sources.tar.xz sources && rm -rf sources
popd

#解压缩还原最新的压缩包文件
pushd $LFS
tar xvf sources.tar.xz
pushd $LFS/sources
tar xvf lfs-sources.tar.xz
tar xvf blfs-sources.tar.xz
tar xvf other-sources.tar.xz
popd #$LFS/sources
popd #$LFS
