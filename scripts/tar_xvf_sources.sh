#!/bin/bash
if [ `id -u` != 0 ];then
        echo Permision deley, Please run as root!
        exit
fi
echo "export LFS=/mnt/lfs" >  ~/.bash_profile
source ~/.bash_profile
pushd $LFS
tar xvf $LFS/lfs-sources.tar.gz
chmod -v a+wt $LFS/sources
mkdir lfs && cd lfs
for tar_file in `ls $LFS/sources`
do
	echo $tar_file
	if [ "$tar_file" != "tzdata2021a.tar.gz" ] && \
		[ "$tar_file" != "mpfr-4.1.0.tar.xz" ] && \
		[ "$tar_file" != "gmp-6.2.1.tar.xz" ] && \
		[ "$tar_file" != "mpc-1.2.1.tar.gz" ]
	then
		#tar xvf $LFS/sources/$tar_file && rm $LFS/sources/$tar_file
		tar xvf $LFS/sources/$tar_file
	fi
done
popd
