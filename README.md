# haoos-lfs

# 构建步骤

## 安装虚拟机

虚拟机需要有三个磁盘分区，/dev/sdb 20G作为lfs构建分区，/dev/sdc 2G作为交换分区。

开设两个shell终端。

## 虚拟机宿主机环境

```
#make distclean
make clean
```

#检查宿主机器的环境，针对结果安装不同的包

```
make check
```

#安装依赖的软件包

```
make dep-install
```

#挂载lfs分区和swap分区
#解压缩获取源代码
#lfs账户配置，这一步会进入新创建的lfs账户目录。

```
make lfs-env-build
```

## 新建的lfs环境

#在lfs账户目录下执行，源码包安装

```
make build
```

## chroot到/mnt/lfs环境

这里切换到另一个终端。

#chroot到/mnt/lfs

```
make chroot
#执行完后是：(lfs chroot) I have no name!:/#
#切换到haoos项目目录
cd haoos
make chroot1
#执行完后是：bash-5.1#
```

## build lfs系统

```
bash-5.1#make build-lfs
```

进入新的bash环境后

```
cd /haoos

make build-lfs1
```



# 参考文献

[Linux From Scratch Version 10.1-systemd Published March 1st, 2021]

http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter06/bash.html

[Linux From Scratch版本 20210326-systemd，中文翻译版发布于 2021 年 3 月 26 日]

https://bf.mengyan1223.wang/lfs/zh_CN/systemd/index.html

# 文献错误勘误

1:Patch编译报错，需要打一个补丁

2:6.3.1. Installation of Ncurses

```
mkdir build
pushd build
  ../configure
  make -C include
  make -C progs tic
popd
```

不应该创建build目录，会造成make -C progs tic编译路径报错，需要修改为：

```
mkdir build
pushd build
  ../configure
popd
make -C build/include
make -C build/progs tic
```





1.安装命令里的相对路径../也需要注意修改：



2.不同构建步骤中都有编译的软件包，第二次编译的时候，需要重新移除，并获取干净的软件包再进行编译。还要注意解压后的文件权限问题，owner是lfs还是root。

