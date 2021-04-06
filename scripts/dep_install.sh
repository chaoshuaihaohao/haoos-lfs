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

