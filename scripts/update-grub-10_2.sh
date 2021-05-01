#!/bin/bash
set -e
#Chapter 10. Making the LFS System Bootable

#10.4. 使用 GRUB 设定引导过程
pushd /tmp
grub-mkrescue --output=grub-img.iso
popd

grub-install /dev/vdb -v
#给lfs系统添加grub字体文件
tar xf /sources/other-sources/grub-fonts.tar.xz -C /lfs
rm -rf /boot/grub/fonts
mv -v -T /lfs/grub-fonts /boot/grub/fonts

#给lfs系统添加grub主题文件
tar xf /sources/other-sources/grub-theme.tar.xz -C /lfs
unzip /lfs/grub-theme/Cyberpunk-Theme-v0.5-1080.zip

#THEME_DIR="/usr/share/grub/themes"
THEME_NAME=Cyberpunk
#[[ -d ${THEME_DIR}/${THEME_NAME} ]] && rm -rf ${THEME_DIR}/${THEME_NAME}
#mkdir -p "${THEME_DIR}/${THEME_NAME}"
#cp -a ${THEME_NAME}/* ${THEME_DIR}/${THEME_NAME}
rm -rf /boot/grub/themes
mkdir /boot/grub/themes
cp -a ${THEME_NAME} /boot/grub/themes

set +e
#grep will cause scripts exit becasue of `set -e`
grep "${THEME_NAME}" /etc/grub.d/00_header 2>&1 > /dev/null
if [ $? != 0 ];then
	sed -i "/grub_lang\=/a\\GRUB_THEME=/boot/grub/themes/${THEME_NAME}/theme.txt" /etc/grub.d/00_header
fi
set -e

grub-mkconfig -o /boot/grub/grub.cfg
