#!/bin/bash


echo -n "all: " > build_Makefile

for dir in $(find /mnt/build_dir/jhalfs/lfs-commands/* -type d | sort -n)
do
	for script in $(find $dir -type f | sort -n)
	do
		name=$(basename "$script")
		echo -n "$name " >> build_Makefile
	done
done

echo -e "\n" >> build_Makefile

tmp=""
for dir in $(find /mnt/build_dir/jhalfs/lfs-commands/* -type d | sort -n)
do
	for script in $(find $dir -type f | sort -n)
	do
		name=$(basename "$script")
		if [ ! -z "$tmp" ] && [ $tmp != $name ];then
			echo -n "$name: " >> build_Makefile
			echo  "$tmp" >> build_Makefile
		else
			#the first packet doesn't has dependence.
			echo "$name: " >> build_Makefile
		fi
		tmp=$name
		#common build command for packets
		echo -e "\tbash -c $script\n" >> build_Makefile
	done
done
