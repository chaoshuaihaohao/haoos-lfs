# haoos-lfs

# 构建步骤

## 下载lfs-sources.tar.gz源码压缩包

百度网盘下载地址：

链接: https://pan.baidu.com/s/1uzpjr-wnRAp4mlVUr5RuGQ  密码: v3j6

下载到物理机的～目录下。

## 安装虚拟机

推荐使用ubuntu作为虚拟机iso镜像。iso下载地址：

https://ubuntu.com/download/desktop/thank-you/?version=20.10&architecture=amd64

虚拟机需要新增一块磁盘/dev/vdb，建议**大小为40G+**（越大越好），linux内核编译比较耗费空间(20多G) 。

磁盘分区规划为grub分区 300M, 交换分区2G, 其余的作为lfs构建分区。

虚拟机中查看是否有vdb设备：

```
ls /dev/vdb
```

注：这里使用的磁盘总线类型都是VIRTIO，不是SATA。所以ubuntu20.10中的新增磁盘设备名不是/dev/sdb，是/dev/vdb。

## 2. 准备虚拟机宿主环境

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

## LFS磁盘分区

注意：通过fdisk -l查看，宿主虚拟机的分区如下--》

```vb
Disk /dev/vda：15 GiB，16106127360 字节，31457280 个扇区
单元：扇区 / 1 * 512 = 512 字节
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：gpt
磁盘标识符：D6D29393-0ABB-4E45-8EC3-32021B8980BA

设备          起点     末尾     扇区  大小 类型
/dev/vda1     2048     4095     2048    1M BIOS 启动
/dev/vda2     4096  1054719  1050624  513M EFI 系统
/dev/vda3  1054720 31455231 30400512 14.5G Linux 文件系统
```

在virt-manager启动ubuntu的系统中，通过findmnt命令发现，宿主机创建了三个分区，但只用到了两个分区，

```vb
root@virt-PC:/boot/efi# findmnt | grep vda
/                                     /dev/vda3  ext4            rw,relatime,errors=remount-ro
└─/boot/efi                           /dev/vda2  vfat            rw,relatime,fmask=0077,dmask=0077,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro
```

分别是vda3作为根文件系统分区， vda2作为EFI系统分区。

**宿主机GRUB是安装在根文件系统下的，不是安装在单独的分区中**。不需要为/boot目录单独创建一个分区进行挂载。

参照宿主虚拟机的分区方式进行分区。vdb1 1M, vdb2 512M,其余的作为根文件系统分区。fdisk /dev/vdb：

![image-20210410201123933](/home/uos/.config/Typora/typora-user-images/image-20210410201123933.png)

注：

​	本人的物理机上，/boot目录是单独作为一个分区的，grub安装在其中。虚拟机中，chroot到/mnt/lfs后，/dev/vdb1类型为BIOS boot时，grub-install 才会成功。

### 创建lfs账户

#解压缩获取lfs应用程序源代码

#修改/mnt/lfs和/home/lfs下的文件owner和group为lfs

#lfs账户配置，这一步会进入新创建的lfs账户目录。

```
make lfs-env-build
```

## 新建的lfs环境

#在lfs账户目录下执行，源码包安装

## 5. 编译交叉工具链 && 6. 交叉编译临时工具

```
lfs@virt-PC:~$make build
```

## 构建 LFS 系统

### 7. 1进入 Chroot，chroot到/mnt/lfs环境

`logout`切换到root@virt-PC:/home/virt/haoos-lfs#。

```
logout
```

#chroot到/mnt/lfs

```
root@virt-PC:/home/virt/haoos-lfs# make chroot
```

#执行完后是：(lfs chroot) I have no name!:/#
#切换到haoos项目目录

```
(lfs chroot) I have no name!:/#cd haoos
(lfs chroot) I have no name!:/#make chroot1
```

#执行完后是：bash-5.1#

### 7. 2构建其他临时工具

```
bash-5.1#make chroot-do
```

## 8. 安装基本系统软件

```
bash-5.1#make build-lfs
```

结尾输出如下：

rm
accept
csv
cut

...

以上输出结束后，**会进入新的bash环境**，目录是/lfs/bash-5.1，之后安装各种系统应用软件

```
cd /haoos
make build-lfs1
```

![image-20210410164222444](/home/uos/.config/Typora/typora-user-images/image-20210410164222444.png)

## 再次chroot

首先退出当前的"bash-5.1#"环境到虚拟宿主机"virt@virt-PC:~/haoos-lfs$"

```
logout
logout
logout
```

进入chroot环境

```
root@virt-PC:/home/virt/haoos-lfs#make chroot-again
```

## 9.系统配置

```
(lfs chroot) root:/# cd haoos/
(lfs chroot) root:/haoos# make system-conf
```

## 10. 使 LFS 系统可引导

创建 `/etc/fstab` 文件，

为新的 LFS 系统构建内核，

以及安装 GRUB 引导加载器，(需要fdisk /dev/vdb1分区为)

使得系统引导时可以选择进入 LFS 系统。

```
(lfs chroot) root:/haoos# make bootable
```

#生成initrd文件并修改grub.cfg

当前通过拷贝/mnt/lfs/lib/modules/5.10.17到虚拟主机/lib/modules/目录下，然后

```
mkinitramfs -o /boot/initrd.img-5.10.17-lfs-20210326-systemd '5.10.17'
```

生成指定内核版本的initrd文件。

grub.cfg需要添加：

```
initrd   /boot//boot/initrd.img-5.10.17-lfs-20210326-systemd
```

注：

​	initrd.img-`uname -r`和linux内核匹配的时候，grub-mkconfig生成的grug.cfg文件才会添加initrd部分。并且“root=”也是使用UUID而不是/dev/vdb。

## 11. 尾声

创建一个 `/etc/lfs-release` 文件。

创建一个文件/etc/lsb-release，根据 Linux Standards Base (LSB) 的规则显示系统状态。

创建一个文件/etc/os-release，systemd 和一些图形桌面环境会使用它。

```
(lfs chroot) root:/haoos# make end
```

```
logout
```

在宿主机中

```
root@virt-PC:/home/virt/haoos-lfs# update-grub
```

，之后重启电脑会有lfs系统的grub选择界面。

重启电脑：

```
root@virt-PC:/home/virt/haoos-lfs# make end1
```



# 参考文献

[Linux From Scratch Version 10.1-systemd Published March 1st, 2021]

http://www.linuxfromscratch.org/lfs/view/stable-systemd/index.html

[Linux From Scratch版本 20210326-systemd，中文翻译版发布于 2021 年 3 月 26 日]

https://bf.mengyan1223.wang/lfs/zh_CN/systemd/index.html

[Beyond Linux® From Scratch (systemd Edition)Version 10.1]

http://www.linuxfromscratch.org/blfs/view/stable-systemd/

[手把手教你构建自己的操作系统-孙海勇]

# 文献错误勘误

## 1:Patch编译报错，需要打一个补丁

## 2:6.3.1. Installation of Ncurses

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

## 5.5. Glibc-2.33

编译glibc时ld会报找不到-lgcc_s库文件，是因为gcc编译没有生成libgcc_s.so库文件，原因未知。需要自行拷贝库文件：

```
sudo cp /usr/lib/gcc/x86_64-linux-gnu/10/libgcc_s.so /mnt/lfs/tools/lib/gcc/x86_64-lfs-linux-gnu/10.2.0/
sudo cp /usr/lib/x86_64-linux-gnu/libgcc_s.so.1 /mnt/lfs/tools/lib/gcc/x86_64-lfs-linux-gnu/10.2.0/
```

## 10.3. Linux-5.11.10

内核版本不对，源码内核版本是5.10.17

编译出来的内核模块超大，module install后/lib/modules/5.10.17有5G左右，需要修改module install 为

```
make INSTALL_MOD_STRIP=1 modules_install
```



## 缺少firmware

需要自行下载linux-firmware安装



1.安装命令里的相对路径../也需要注意修改：

2.不同构建步骤中都有编译的软件包，第二次编译的时候，需要重新移除，并获取干净的软件包再进行编译。还要注意解压后的文件权限问题，owner是lfs还是root。

3./dev/sdb需要进行分区，例如efi分区 FAT文件格式，/mnt/lfs分区 EXT4文件格式。

## 找不到根文件设备/dev/vdb3

![image-20210410202739487](/home/uos/.config/Typora/typora-user-images/image-20210410202739487.png)

![image-20210411103925629](/home/uos/.config/Typora/typora-user-images/image-20210411103925629.png)

原因是initrd的init文件中，没有加载对应的磁盘驱动，需要在“mount -n -t devtmpfs devtmpfs /dev”之前加载磁盘驱动

```
modprobe virtio_blk
```

# 其他

貌似内核必须支持initrd/initramfs.img。



收集make日志可以使用如下方法（包括错误和正常打印）：

```
make xxx > build_output_all.txt 2>&1
```



去掉ubuntu系统磁盘，重启电脑加载haoos：

![image-20210411143614824](/home/uos/.config/Typora/typora-user-images/image-20210411143614824.png)

找不到/dev/vdb3的原因是因为只剩一个磁盘，内核启动后，vdb名称变为了vda。

grub.cfg要修改为通过UUID加载根文件系统增加容错性。

