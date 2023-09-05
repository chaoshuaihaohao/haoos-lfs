#!/bin/bash
sudo echo -n "all: " > build_Makefile

for script in $(find ${JHALFSDIR}/${COMMANDS}/chapter04/ -type f | sort -n)
do
	name=$(basename "$script")
	echo -n "$name " >> build_Makefile
done

echo -e "\n" >> build_Makefile

tmp=""
for script in $(find ${JHALFSDIR}/${COMMANDS}/chapter04/ -type f | sort -n)
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
	echo -e "\tbash $script\n" >> build_Makefile
done
