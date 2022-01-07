#!/bin/bash
GITHUB_PATH=$(readlink -f . | awk -F 'haoos-lfs' '{print $1}')
HAOOS_PATH=$GITHUB_PATH/haoos-lfs

#编译blfs-xml工具

#获取blfs xml文件
for xml_file in $(find $HAOOS_PATH/blfs-git/ -name *.xml)
#xml_file=../blfs-git/general/sysutils/systemd.xml
do
	#获取包下载地址
	urls=$($HAOOS_PATH/os-build/xml_parse/blfs-xml -n cmd $xml_file | grep https)
	for url in $urls
	do
		echo $url
		wget -c "$url" -P $HAOOS_PATH/build/src/blfs
#		axel -n 10 -o $HAOOS_PATH/build/src/blfs $url
	done
	#wget下载
done
