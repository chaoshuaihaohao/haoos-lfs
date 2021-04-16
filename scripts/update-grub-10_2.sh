#!/bin/bash
set -e
#Chapter 10. Making the LFS System Bootable

#10.4. 使用 GRUB 设定引导过程
pushd /tmp
grub-mkrescue --output=grub-img.iso
#xorriso -as cdrecord -v dev=/dev/cdrw blank=as_needed grub-img.iso
#grub-install --grub-setup=/bin/true /dev/vdb -v
#grub-install --boot-directory=/boot/grub --efi-directory=/boot/efi /dev/vdb -v
grub-install /dev/vdb -v
grub-mkconfig -o /boot/grub/grub.cfg
popd
