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

pushd /lfs
#10.3. Linux-5.10.17
rm -rf linux-5.10.17
tar xf $LFS_SRC_DIR/linux-5.10.17.tar.xz
pushd linux-5.10.17
#make mrproper
#need to copy a .config file from other place.
##use the defconfig in linux kernel.
#make x86_64_defconfig
patch -Np1 -i $LFS_SRC_DIR/0001-linux-support-aufs-file-system.patch
make x86_desktop_defconfig
#sed -i 's/CONFIG_SYSTEM_TRUSTED_KEYS\=\"debian\/canonical-certs.pem\"/CONFIG_SYSTEM_TRUSTED_KEYS\=\"\"/' .config
#disable BTF
#sed -i 's/CONFIG_DEBUG_INFO_BTF=y/#\ CONFIG_DEBUG_INFO_BTF\ is\ not\ set/' .config
#change lz4 to xz
#sed -i 's/CONFIG_KERNEL_LZ4=y/#\ CONFIG_KERNEL_LZ4\ is\ not\ set/' .config
#sed -i 's/#\ CONFIG_KERNEL_XZ\ is\ not\ set/CONFIG_KERNEL_XZ=y' .config


#make menuconfig

make
make INSTALL_MOD_STRIP=1 modules_install

cp -ivf arch/x86/boot/bzImage /boot/vmlinuz-5.10.17
cp -ivf System.map /boot/System.map-5.10.17
cp -ivf .config /boot/config-5.10.17
install -d /usr/share/doc/linux-5.10.17
cp -rf Documentation/* /usr/share/doc/linux-5.10.17
popd #linux-5.10.17
#rm -rf linux-5.10.17

#install linux-firmware
rm -rf linux-firmware-20210315
tar xf $LFS_SRC_DIR/linux-firmware-20210315.tar.xz
pushd linux-firmware-20210315
make install
popd
rm -rf linux-firmware-20210315

popd #/lfs
