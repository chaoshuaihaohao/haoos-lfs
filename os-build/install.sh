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
#对于python这样的有doc压缩包，匹配不精确会有两个下载链接
url=$(grep -A 3 -i "^$1 (" $PACKAGES_PATH | grep Download | head -1)
if [ -z "$url" ];then echo Error: No "$1" url found in $PACKAGES_PATH!; exit; fi

tar_pkg=$(echo $url | awk -F '/' '{print $NF}')
#echo $tar_pkg
#pkg_dir=$(echo $tar_pkg | awk -F '.tar.gz' '{print $1}')
pkg_dir=$(echo $tar_pkg | awk -F '.tar' '{print $1}')

pushd ./build/cmd
#清除软件包目录,防止上次构建的残留造成影响。可以做成一个选项
rm -rf $pkg_dir
#解压软件包
tar -xf $tar_pkg
#解压缩后的包名hook
case "$pkg_dir" in
tcl8.6.11-src)
	pkg_dir="tcl8.6.11"
	;;
esac
pushd $pkg_dir
#执行软件包安装命令
bash -e ../$CHAPTER/$pkg.cmd
if [ $? -ne 0 ];then echo "Error: exec '$CHAPTER/$pkg.cmd' failed!";exit; fi
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
		#$2格式是lfs-list-chapter05这种
		CHAPTER=$(echo $2 | awk -F '-' '{printf $NF}')
		echo $CHAPTER | grep ^chapter
		if [ $? -ne 0 ];then echo "Error: lfs-list-chapter* file name not right!"; exit; fi

		for pkg in `cat $2`
		do
			#忽略-list文件中'#'开头的行
			echo $pkg | grep "^#"
			if [ $? -eq 0 ];then continue; fi
			#fix包名，如binutils-pass1修复成binutils.源码包都一样，只是.cmd安装脚本不一样
			pkg_name=$(basename -s -pass1 $pkg)
			pkg_name=$(basename -s -pass2 $pkg_name)
			#pkg_name：对应url源码压缩包;pkg：对应.cmd文件名
			case $pkg_name in
			linux-headers)
				pkg_name=linux
				;;
			libstdc++)
				pkg_name=gcc
				;;
			xz)
				pkg_name="Xz Utils"
				;;
			*)
				;;
			esac
			#没有“”,xz utils入参会被判定为两个,$1=xz,$2=utils,报错
			install_pkg "$pkg_name";
		done
		;;
esac

