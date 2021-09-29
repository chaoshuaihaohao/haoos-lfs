#!/bin/bash
LFS_PATH=/home/uos/Backup/github/lfs-git/
XML_PARSE=./xml_parse/xml

CUR_PATH=$(dirname $(readlink -f "$0"))
#echo $CUR_PATH

XML_FILE_SET=`find $LFS_PATH -name "*.xml"`

mkdir -pv ./tmp

for file in $XML_FILE_SET
do
	#$XML_PARSE $file;
	XML_NAME=$(basename $file)
	BASENAME=$(basename -s .xml $XML_NAME)
	$XML_PARSE $file > ./tmp/$BASENAME.cmd
	if [ ! -s ./tmp/$BASENAME.cmd ]
	then
		rm ./tmp/$BASENAME.cmd
	fi
	echo $XML_PARSE $file

done

#rm -rf ./tmp
