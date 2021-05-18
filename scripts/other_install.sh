#!/bin/bash
set -e
#Part IV. Building the LFS System
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi
#Chapter 8. Installing Basic System Software

if [ -n $JOBS ];then
        JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
        if [ ! $JOBS ];then
                JOBS="1"
        fi
fi
export MAKEFLAGS=-j$JOBS

export OTHER_SRC_DIR=$LFS/sources/other-sources

pushd /lfs

#安装truetype字体
tar xvf  $OTHER_SRC_DIR/fonts.tar.xz -C /usr/share/fonts/

#安装默认背景图
cp -av /sources/other-sources/saigepengkegirl.jpg /usr/share/backgrounds/
set +e
grep -rn "saigepengkegirl" /usr/share/gnome-background-properties/gnome-backgrounds.xml
if [ $? != 0 ];then
sed -i '3a\        <wallpaper deleted="false">\n                <name>Light Waves</name>\n                <filename>/usr/share/backgrounds/gnome/saigepengkegirl.jpg</filename>\n                <options>zoom</options>\n    <pcolor>#ffffff</pcolor>\n    <scolor>#000000</scolor>\n        </wallpaper>\n        <wallpaper deleted="false">' /usr/share/gnome-background-properties/gnome-backgrounds.xml
fi
set -e

popd #/lfs
