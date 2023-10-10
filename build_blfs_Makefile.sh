#!/bin/bash

#build_Makefile=$JHALFSDIR/blfs_Makefile
build_Makefile=./blfs_Makefile
: > $build_Makefile

python3 libs/menu/blfs.py >> $build_Makefile

CHROOT_TGT="CHROOT:"
for script in $(grep  "=y" blfs-configuration | sed 's/=y//')
do
	CHROOT_TGT="$CHROOT_TGT $script"
done
echo $CHROOT_TGT >> $build_Makefile
