#!/bin/bash
HAOOS_PATH=$PWD
LFS_PATH=$HAOOS_PATH/lfs-git
OS_BUILD_PATH=$(readlink -f .)/os-build
XML_PATH=$OS_BUILD_PATH/xml_parse
XML_PARSE=$XML_PATH/xml
BUILD_PATH=$(readlink -f .)/build
CMD_PATH=$BUILD_PATH/cmd
PKG_PATH=$BUILD_PATH/pkg
#下载的源码包和patch的存放位置，需要在.cmd文件的上级目录
SRC_PATH=$BUILD_PATH/cmd

Usage()
{
	echo "-x" "解析xml文件内容并导出到文件:1.cmd内容;2.pkg内容"
		echo "解析所有xml文件内容并导出到文件;2.解析指定的xml文件内容并导出到文件"
	echo "-d" "下载文件:1.软件包文件+2.patch文件"
		echo "      1.all;2.指定;3.packages;4.patches"
	echo "-i" "安装软件包"
		echo "      1.all;2.指定"
	echo "-f <file>" "安装文件列表中的软件包"
	echo "-h" "显示该帮助信息"
	echo "You can os-build/build.sh -x all and os-build/build.sh -d all to make the repo"
}

#找到包含软件包下载信息的文件
PKG_FILE=`find $LFS_PATH -name packages.xml`
#找到包含patches下载信息的文件
PATCH_FILE=`find $LFS_PATH -name patches.xml`

get_packages()
{
#获取安装包
PACKAGES=`grep -r Download $PKG_PATH/$(basename -s .xml $PKG_FILE).pkg | awk -F ': ' '{print $2}'`
if [ -z "$PACKAGES" ];then echo "No packages url found!"; exit; fi
for pkg in $PACKAGES
do
	if [ -z "$1" ];then
		#-N:只获取比本地文件新的文件,避免重复下载
		#下载所有软件包
		wget -N -c $pkg -P $SRC_PATH
	else
		#下载指定的单个软件包
		pkg_name=$(echo $pkg | awk -F '/' '{print $(NF-1)}')
		if [ $pkg_name = "$1" ];then
			wget -N -c $pkg -P $SRC_PATH
		fi
	fi
done
}

get_patches()
{
#获取patch
PACKAGES=`grep -r Download $PKG_PATH/$(basename -s .xml $PATCH_FILE).pkg | awk -F ': ' '{print $2}'`
if [ -z "$PACKAGES" ];then echo "No patches url found!"; exit; fi
for pkg in $PACKAGES
do
	if [ -z "$1" ];then
			echo download all packages
		#-N:只获取比本地文件新的文件,避免重复下载
		wget -N -c $pkg -P $SRC_PATH
	else
		if [ $pkg = "$1" ];then
			wget -N -c $pkg -P $SRC_PATH
		fi
	fi
done
}

#入参检查/处理
case $1 in
	-x)
		if [ -z $2 ];then	Usage;exit;	fi
		make -C $XML_PATH
		if [ $? -ne 0 ];then echo "Error: make xml failed!";exit; fi

		case $2 in
		all)
			CUR_PATH=$(dirname $(readlink -f "$0"))
			#echo $CUR_PATH

			XML_FILE_SET=`find $LFS_PATH -name "*.xml"`

			mkdir -pv $BUILD_PATH

			#生成.cmd文件
			if [ ! -d $CMD_PATH ];then mkdir -pv $CMD_PATH; fi
			find $CMD_PATH -name *.cmd -delete
			for file in $XML_FILE_SET
			do
				XML_NAME=$(basename $file)
				CHAPTER=$(echo $file | awk -F '/' '{print $(NF-1)}')
				BASENAME=$(basename -s .xml $XML_NAME)
				if [ ! -d $CMD_PATH/$CHAPTER ];then mkdir -pv $CMD_PATH/$CHAPTER; fi
				CMD_FILE_PATH=$CMD_PATH/$CHAPTER/$BASENAME.cmd
				echo parsing $file
				$XML_PARSE -n cmd $file > $CMD_FILE_PATH
				if [ ! -s $CMD_FILE_PATH ]
				then
					rm $CMD_FILE_PATH
				fi
			done

			#生成.pkg文件,包含包的信息
			rm -rf $PKG_PATH
			mkdir -pv $PKG_PATH

			$XML_PARSE -n pkg $PKG_FILE > $PKG_PATH/$(basename -s .xml $PKG_FILE).pkg
			$XML_PARSE -n pkg $PATCH_FILE > $PKG_PATH/$(basename -s .xml $PATCH_FILE).pkg

			exit;
			;;
		*)
			Usage;exit;
		esac
		exit;
		;;
	-d)
		if [ -z $2 ];then	Usage;exit;	fi
		mkdir -pv $SRC_PATH
		#wget下载软件包url
		case $2 in
		all)
			#获取安装包
			get_packages
			#获取patch
			get_patches
			exit;
			;;
		packages)
			#获取安装包
			get_packages
			exit;
			;;
		patches)
			#获取patch
			get_patches
			exit;
			;;
		*)
			get_packages $2
			get_patches $2
			exit;
		esac
		exit;
		;;
	-f)
		if [ -z $2 ];then	Usage;exit;	fi
		;;
	-h)
		Usage;exit;
		;;
	*)
		Usage;exit;
		exit;
esac




#rm -rf $PKG_PATH
#rm -rf $CMD_PATH
#rm -rf $BUILD_PATH
make -C ./xml_parse clean

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@build
#解压/安装软件包




