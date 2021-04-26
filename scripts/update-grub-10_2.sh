#!/bin/bash
set -e
#Chapter 10. Making the LFS System Bootable

#10.4. 使用 GRUB 设定引导过程
pushd /tmp
grub-mkrescue --output=grub-img.iso
grub-install /dev/vdb -v
#给lfs系统添加grub字体文件
tar xf /sources/other-sources/grub-fonts.tar.xz -C /lfs
mv -v -T /lfs/grub-fonts /boot/grub/fonts
grub-mkconfig -o /boot/grub/grub.cfg
popd
