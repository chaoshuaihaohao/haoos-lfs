#!/bin/bash
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi
#第 3 章 软件包和补丁
echo "export LFS=/mnt/lfs" >  ~/.bash_profile
source ~/.bash_profile

pushd $LFS
tar xvf $LFS/sources.tar.xz

pushd $LFS/sources
tar xvf $LFS/sources/lfs-sources.tar.xz
tar xvf $LFS/sources/blfs-sources.tar.xz
popd #$LFS/sources

chmod -v a+wt $LFS/sources/lfs-sources
mkdir lfs && pushd lfs
for tar_file in `ls $LFS/sources/lfs-sources`
do
	echo $tar_file
	if [ "$tar_file" != "tzdata2021a.tar.gz" ] && \
		[ "$tar_file" != "tcl8.6.11-html.tar.gz" ]
	then
		#tar xvf $LFS/sources/lfs-sources/$tar_file && rm $LFS/sources/lfs-sources/$tar_file
		tar xf $LFS/sources/lfs-sources/$tar_file
	fi
done
popd #lfs

popd #$lfs
