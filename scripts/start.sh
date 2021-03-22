#!/bin/bash
HAOOS_DIR=/home/uos/Backup/github/haoos-lfs
pushd $HAOOS_DIR
tar xvf $HAOOS_DIR/lfs-sources.tar.gz
mkdir lfs && cd lfs
for tar_file in `ls $HAOOS_DIR/sources`
do
	echo $tar_file
	if [ "$tar_file" != "tzdata2021a.tar.gz" ];then
		tar xvf $HAOOS_DIR/sources/$tar_file && rm $HAOOS_DIR/sources/$tar_file

	fi
done
popd
