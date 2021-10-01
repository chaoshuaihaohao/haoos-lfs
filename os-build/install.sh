#!/bin/bash
if [ `id -u` != 0 ];then                                                                                                                                                  
        echo Permission delay, Please run as root!                                                                                                                        
        exit                                                                                                                                                              
fi

if [ -n $JOBS ];then
	JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
	if [ ! $JOBS ];then
		JOBS="1"
	fi
fi
export MAKEFLAGS=-j$JOBS

install_pkg()
{
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@build
url=$(grep $1 build/pkg/packages.pkg)
#echo $url
tar_pkg=$(echo $url | awk -F '/' '{print $NF}')
#echo $tar_pkg
#pkg_dir=$(echo $tar_pkg | awk -F '.tar.gz' '{print $1}')
pkg_dir=$(echo $tar_pkg | awk -F '.tar' '{print $1}')

#解压软件包
pushd ./build
#清除软件包目录
rm -rf $pkg_dir
tar xf $tar_pkg
pushd $pkg_dir
sudo bash -e ../cmd/$pkg.cmd
popd
#清除软件包目录
rm -rf $pkg_dir
pushd 
}

case $1 in
	-f)
		#文件存在性检测
		if [ -z $2 ]
		then
			echo "Usage: -f <file>"	
			exit
		fi

		for pkg in `cat $2`
		do
			install_pkg $pkg;
		done
		;;
esac

