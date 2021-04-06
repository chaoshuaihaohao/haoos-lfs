# haoos-lfs

# 构建步骤

## 安装虚拟机

虚拟机需要有三个磁盘分区，/dev/sdb 20G ，grub 300M, efi 300M, 交换分区2G, 其余的作为lfs构建分区。

虚拟机中查看是否有sdb设备：

```
ls /dev/sdb
```

**开设两个shell终端**。

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

进入新的bash环境后，安装各种系统应用软件

```
cd /haoos

make build-lfs1
```

## 再次chroot

首先退出当前的bash-5.1#环境到虚拟宿主机

```
logout
exit
```

进入chroot环境

```
make chroot-again
```



# 参考文献

[Linux From Scratch Version 10.1-systemd Published March 1st, 2021]

http://www.linuxfromscratch.org/lfs/view/stable-systemd/chapter06/bash.html

[Linux From Scratch版本 20210326-systemd，中文翻译版发布于 2021 年 3 月 26 日]

https://bf.mengyan1223.wang/lfs/zh_CN/systemd/index.html

[Beyond Linux® From Scratch (systemd Edition)Version 10.1]

http://www.linuxfromscratch.org/blfs/view/stable-systemd/



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



3./dev/sdb需要进行分区，例如grub分区 FAT文件格式，/mnt/lfs分区 EXT4文件格式。

fdisk /dev/sdb



```

```

```



#10.2. Creating the /etc/fstab File

cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/sdb     /            ext4    defaults            1     1
/dev/sdc     swap         swap     pri=1               0     0

# End /etc/fstab
EOF




cd /tmp 
grub-mkrescue --output=grub-img.iso 
xorriso -as cdrecord -v dev=/dev/cdrw blank=as_needed grub-img.iso
grub-install /dev/sda


#grub.cfg配置文件。config-5.10.17  grub  System.map-5.10.17  vmlinuz-5.10.17-lfs-10.1-systemd
cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod ext2
set root=(hd1,1)

menuentry "GNU/Linux, Linux 5.10.17-lfs-20210405-systemd" {
        linux   /boot/vmlinuz-5.10.17-lfs-10.1-systemd root=/dev/sdb ro
}
EOF

echo 20210405-systemd > /etc/lfs-release

cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="20210405-systemd"
DISTRIB_CODENAME="haoos"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="20210405-systemd"
DISTRIB_CODENAME="haoos"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

cat > /etc/os-release << "EOF"
NAME="Linux From Scratch"
VERSION="20210405-systemd"
ID=lfs
PRETTY_NAME="Linux From Scratch 20210405-systemd"
VERSION_CODENAME="haoos"
EOF


logout
#关闭所有终端，重开一个
export LFS=/mnt/lfs
umount -Rv $LFS

shutdown -r now
```

