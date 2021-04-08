#!/bin/bash
set -e
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi
apt -y install automake
apt -y install texinfo
apt -y install g++
apt -y install bison
apt -y install flex
apt -y install binutils
apt -y install binutils-dev
apt -y install libiberty-dev
apt -y install gawk
##other
#sudo apt-get install libgcc1 lib32gcc1 libx32gcc1
#sudo apt-get install build-essential autoconf automake libtool

#ubuntu
#apt -y install lib32gcc-10-dev libx32gcc-10-dev 
apt -y install libisl-dev
