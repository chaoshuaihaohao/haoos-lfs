#!/bin/bash
set -e                                                                                                       
#                                                                            
if [ `id -u` != 0 ];then 
	echo Permission delay, Please run as root!
	exit
fi

rm -rf /lfs /sources /lfs-sources.tar.gz /haoos /tools
