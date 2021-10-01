#!/bin/bash
if [ -n $JOBS ];then
	JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
	if [ ! $JOBS ];then
		JOBS="1"
	fi
fi
export MAKEFLAGS=-j$JOBS

PACKAGES_PATH=build/pkg/packages.pkg
if [ -z $PACKAGES_PATH ];then echo "Error: No packages.pkg file!" ;exit; fi

install_pkg()
{
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@build
#获取本地软件压缩包路径
url=$(grep $1 $PACKAGES_PATH)
echo $url
tar_pkg=$(echo $url | awk -F '/' '{print $NF}')
#echo $tar_pkg
#pkg_dir=$(echo $tar_pkg | awk -F '.tar.gz' '{print $1}')
pkg_dir=$(echo $tar_pkg | awk -F '.tar' '{print $1}')

pushd ./build
#清除软件包目录,防止上次构建的残留造成影响。可以做成一个选项
rm -rf $pkg_dir
#解压软件包
tar -xf $tar_pkg
pushd $pkg_dir
#执行软件包安装命令
bash -e ../cmd/$pkg.cmd
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
			echo "		从文件获取软件包安装列表"
			exit
		fi

		for pkg in `cat $2`
		do
			#fix包名，如binutils-pass1修复成binutils.源码包都一样，只是.cmd安装脚本不一样
			pkg_name=$(basename -s -pass1 $pkg)
			pkg_name=$(basename -s -pass2 $pkg_name)
			install_pkg $pkg_name;
		done
		;;
esac

