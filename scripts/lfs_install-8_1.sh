#!/bin/bash
set -e
#第 8 章 安装基本系统软件
if [ -n $JOBS ];then
        JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
        if [ ! $JOBS ];then
                JOBS="1"
        fi
fi
export MAKEFLAGS=-j$JOBS

./os-build/install.sh -f ./os-build/lfs-list-chapter08
#8.3. Man-pages-5.10
#执行新编译的 bash 程序 (替换当前正在执行的版本)：
#exec /bin/bash --login +h -c "cd /haoos && make system-conf && make build-lfs1"
#popd
