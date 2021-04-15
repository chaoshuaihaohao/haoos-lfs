#!/bin/bash
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

echo "export LFS=/mnt/lfs" >  ~/.bash_profile
source ~/.bash_profile

pushd $LFS

tar xvf $LFS/lfs-sources.tar.gz
chmod -v a+wt $LFS/sources
mkdir lfs && pushd lfs
for tar_file in `ls $LFS/sources`
do
	echo $tar_file
	if [ "$tar_file" != "tzdata2021a.tar.gz" ] && \
		[ "$tar_file" != "tcl8.6.11-html.tar.gz" ]
	then
		echo "tar xf $LFS/sources/$tar_file ......"
		tar xf $LFS/sources/$tar_file
	fi
done
popd #lfs

popd
