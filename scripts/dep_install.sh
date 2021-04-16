#!/bin/bash
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

DEP_PACKETS="\
	automake \
	texinfo \
	g++ \
	bison \
	flex \
	binutils \
	binutils-dev \
	libiberty-dev \
	gawk \
	libisl-dev \
	"
for i in $DEP_PACKETS
do
	dpkg -s $i > /dev/null
	if [ $? -ne 0 ];then
		echo dpkg -s $i
		apt -y $i
	fi
done
