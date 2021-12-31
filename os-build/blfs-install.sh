#!/bin/bash
if [ -n $JOBS ];then
	JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
	if [ ! $JOBS ];then
		JOBS="1"
	fi
fi
export MAKEFLAGS=-j$JOBS

Usage()
{
	echo "Usage: -f <file>"
	echo "		从文件获取软件包安装列表"
	echo "       -p <package>"
	echo "		安装指定的package"
}

GITHUB_PATH=$(readlink -f . | awk -F 'haoos-lfs' '{print $1}')
HAOOS_PATH=$GITHUB_PATH/haoos-lfs
PACKAGES_PATH=$HAOOS_PATH/build/pkg/blfs/packages.pkg
if [ -z $PACKAGES_PATH ];then echo "Error: No packages.pkg file!" ;exit; fi

pre_install()
{
	#current in uncompress_name dir path
	#hook for linux kernel
	if [ `basename $1` = kernel.cmd ];
	then
		#TODO:adaptor aufs auto
		#current path is in ./build/src/lfs/$uncompress_name
		pwd
		cp -v ../../../../scripts/x86_64_desktop_defconfig arch/x86/configs/
		sed -i 's/-lfs-//' $1		
		sed -i 's/make modules_install/make INSTALL_MOD_STRIP=1 modules_install/' $1
		sed -i 's/-lfs-//' $1
		sed -i 's/make mrproper//' $1
		sed -i 's/make menuconfig//' $1
		grep -r x86_64_desktop_defconfig $1
		if [ $? -ne 0 ];then
			sed '1s/^/make x86_64_desktop_defconfig&/g' $1
		fi
		make x86_64_desktop_defconfig
	fi
}

install_pkg()
{
#切换到源码压缩包所在目录
pushd ./build/src/blfs
#解压包.先删除目录,再重新解压,避免多次编译造成影响
#清除软件包目录,防止上次构建的残留造成影响。可以做成一个选项
rm -rf $uncompress_name
#解压软件包
tar -xf $tar_pkg
#进入解压后的目录
pushd $uncompress_name
#pre-install hook
pre_install ../../../../$CMD_FILE_PATH

#执行软件包安装命令
bash -e ../../../../$CMD_FILE_PATH
if [ $? -ne 0 ];then echo "Error: exec '$CHAPTER/$pkg.cmd' failed!";exit; fi
popd #$uncompress_name

#清除软件包目录
rm -rf $uncompress_name
popd #./build/cmd
}

uncompress_pkg()
{
#通过$pkg_flag找到pkg url.方法是通过grep命令进行过滤
#获取本地软件压缩包路径
#对于python这样的有doc压缩包，匹配不精确会有两个下载链接
#url=$(grep -A 3 -i "^$1" $PACKAGES_PATH | grep Download | head -1)
#if [ -z "$url" ];then echo Error: No "$1" url found in $PACKAGES_PATH!; exit; fi

#根据url获取压缩包名
#tar_pkg=$(echo $url | awk -F '/' '{print $NF}')
tar_pkg=$(find $HAOOS_PATH/build/src/blfs -name "$1*")
echo $tar_pkg
#pkg_dir=$(echo $tar_pkg | awk -F '.tar.gz' '{print $1}')
#转换压缩后的包目录名
uncompress_name=$(echo $tar_pkg | awk -F '.tar' '{print $1}')
echo $uncompress_name
#解压缩后的包名hook
case "$uncompress_name" in
tcl8.6.11-src)
	uncompress_name="tcl8.6.11"
	;;
vim-8.2.3458)
	uncompress_name="vim-tags-v8.2.3458"
	;;
procps-ng-3.3.17)
	uncompress_name="procps-3.3.17"
	;;
esac

#执行安装步骤
install_pkg $cmd_flag.cmd
}

trans_name()
{
	#$1 is the .cmd name
#	echo $1;
#	CMD_FILE_PATH=$(find $HAOOS_PATH/build/src/blfs -name $1*)
#	echo $CMD_FILE_PATH
#	exit
	#忽略-list文件中'#'开头的行
	echo $1 | grep "^#"
	if [ $? -eq 0 ];then continue; fi
	CMD_FILE_PATH=$(find -name $1.cmd | grep blfs)
	CHAPTER=$(echo "$CMD_FILE_PATH" | awk -F '/' '{print $(NF-1)}')
	#fix包名，如binutils-pass1修复成binutils.源码包都一样，只是.cmd安装脚本不一样
	cmd_flag=$(basename -s -pass1 $1)
	cmd_flag=$(basename -s -pass2 $cmd_flag)
	case $cmd_flag in
	linux-headers)
		pkg_flag=linux
		;;
	libstdc++)
		pkg_flag=gcc
		;;
	xz)
		pkg_flag="Xz Utils"
		;;
	pkgconfig)
		pkg_flag="pkg-config"
		;;
	libelf)
		pkg_flag="Elfutils"
		;;
	dbus)
		pkg_flag="D-Bus"
		;;
	kernel)
		pkg_flag="Linux"
		;;
	*)
		pkg_flag=$cmd_flag
		;;
	esac
	#没有“”,xz utils入参会被判定为两个,$1=xz,$2=utils,报错
	uncompress_pkg "$pkg_flag";
}

case $1 in
	-f)
		#文件存在性检测
		if [ -z $2 ]
		then
			Usage;
			exit
		fi
		#$2格式是lfs-list-chapter05-part01这种
		#CHAPTER=$(echo $2 | awk -F '-' '{printf $4}')
		#echo $CHAPTER | grep ^chapter
		#if [ $? -ne 0 ];then echo "Error: "$2" file name not right(lfs-list-chapter08-part2)!"; exit; fi

		#lfs-list-chapter文件中包含.cmd文件对应的文件名cmd_flag,也是html网页地址的名称
		for cmd_flag in `cat $2`
		do
			trans_name $cmd_flag;
		done
		;;
	-p)
		#文件存在性检测
		if [ -z $2 ]
		then
			Usage;
			exit
		fi
		trans_name $2;
		;;
	*)
		Usage;
		exit
		;;
esac

