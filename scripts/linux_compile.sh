#!/bin/bash
set -e
#Chapter 10. Making the LFS System Bootable
export MAKEFLAGS='-j4'

pushd /lfs
#10.3. Linux-5.10.17
pushd linux-5.10.17
#make mrproper
#need to copy a .config file from other place.
#cp /haoos/scripts/defconfig arch/x86/configs/x86_desktop_defconfig
#make x86_desktop_defconfig
##use the defconfig in linux kernel.
make x86_64_defconfig
#sed -i 's/CONFIG_SYSTEM_TRUSTED_KEYS\=\"debian\/canonical-certs.pem\"/CONFIG_SYSTEM_TRUSTED_KEYS\=\"\"/' .config
#make menuconfig

make
make INSTALL_MOD_STRIP=1 modules_install

cp -iv arch/x86/boot/bzImage /boot/vmlinuz-5.10.17-lfs-20210326-systemd
cp -iv System.map /boot/System.map-5.10.17
cp -iv .config /boot/config-5.10.17
install -d /usr/share/doc/linux-5.10.17
cp -r Documentation/* /usr/share/doc/linux-5.10.17
popd #linux-5.10.17

#install linux-firmware
pushd linux-firmware-20210315
make install
popd

popd #/lfs
