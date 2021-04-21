# haoos-lfs

# 构建步骤

## 下载lfs-sources.tar.gz源码压缩包

百度网盘下载地址：

链接: https://pan.baidu.com/s/1lybURDdTHm5wu5Q9k9etZQ  密码: gvc1

下载到物理机的～目录下。

## 安装虚拟机

推荐使用ubuntu作为虚拟机iso镜像。iso下载地址：

https://ubuntu.com/download/desktop/thank-you/?version=20.10&architecture=amd64

虚拟机需要新增一块磁盘/dev/vdb用于lfs构建，建议**大小为40G+**（越大越好），linux内核编译比较耗费空间(20多G) 。

磁盘分区规划为grub分区 300M, 交换分区2G, 其余的作为lfs构建分区。

虚拟机中查看是否有vdb设备：

```
ls /dev/vdb
```

注：这里使用的磁盘总线类型都是VIRTIO，不是SATA。所以ubuntu20.10中的新增磁盘设备名不是/dev/sdb，是/dev/vdb。

## 2. 准备虚拟机宿主环境

#安装工具

```
sudo apt update && sudo apt install git make vim
```

#下载haoos仓库

```
git clone https://github.com/chaoshuaihaohao/haoos-lfs.git
```

如果之前构建过lfs系统，可以执行如下命令清除构建文件（该步骤可选）：

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

`logout`或exit切换到root@virt-PC:/home/virt/haoos-lfs#。

```
lfs@virt-PC:/home/virt/haoos-lfs$ logout
bash: logout: 不是登录 shell: 使用 `exit'
lfs@virt-PC:/home/virt/haoos-lfs$ exit
exit
virt@virt-PC:~/haoos-lfs$ 
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
bash-5.1# make build-lfs
```

结尾输出如下：

![image-20210416103212830](/home/uos/.config/Typora/typora-user-images/image-20210416103212830.png)

以上输出结束后，**会进入新的bash环境**，目录是/lfs/bash-5.1，之后安装各种系统应用软件

```
bash-5.1# cd /haoos
bash-5.1# make build-lfs1
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
virt@virt-PC:~/haoos-lfs$ sudo make chroot-again
```

## 9.系统配置

```
(lfs chroot) root:/# cd haoos/
(lfs chroot) root:/haoos# make system-conf
```

## 10. 使 LFS 系统可引导

创建 `/etc/fstab` 文件，

为新的 LFS 系统构建内核，

制作initramfs.img

以及安装 GRUB 引导加载器，(需要fdisk /dev/vdb1分区为)

使得系统引导时可以选择进入 LFS 系统。

```
(lfs chroot) root:/haoos# make bootable
```

注：

​	initrd.img-`uname -r`和linux内核匹配的时候，grub-mkconfig生成的grug.cfg文件才会添加initrd部分。并且“root=”也是使用UUID而不是/dev/vdb。

## 11. 尾声（可以不进行此步）

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

## LIVECD制作

```
root@virt-PC:/home/virt/haoos-lfs# make livecd
```

![image-20210413160936269](/home/uos/.config/Typora/typora-user-images/image-20210413160936269.png)

# 参考文献

[Linux From Scratch Version 10.1-systemd Published March 1st, 2021]

http://www.linuxfromscratch.org/lfs/view/stable-systemd/index.html

[Linux From Scratch版本 20210326-systemd，中文翻译版发布于 2021 年 3 月 26 日]

https://bf.mengyan1223.wang/lfs/zh_CN/systemd/index.html

[Beyond Linux® From Scratch (systemd Edition)Version 10.1]

http://www.linuxfromscratch.org/blfs/view/stable-systemd/

[手把手教你构建自己的操作系统-孙海勇]

[initrd/initramfs]

http://www.linuxfromscratch.org/hints/downloads/files/initramfs.txt

http://www.linuxfromscratch.org/hints/downloads/files/ATTACHMENTS/initramfs-scripts.tar.gz





[BLFS-BOOK-10.1-systemd-nochunks.html](http://www.linuxfromscratch.org/blfs/downloads/10.1-systemd/BLFS-BOOK-10.1-systemd-nochunks.html)

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

### 内核配置文件

使用的ubuntu的配置文件，修改

Kernel compression mode 为(xz)

### 内核aufs文件系统适配

git clone https://github.com/sfjro/aufs5-standalone.git

pushd aufs5-standalone

git checkout remotes/origin/aufs5.10

cp -a fs/aufs linux-5.10.17/fs/

cp -a include/* linux-5.10.17/include/

patch -Np1 -i ../aufs5-standalone/aufs5-mmap.patch

patch -Np1 -i ../aufs5-standalone/aufs5-standalone.patch

patch -Np1 -i ../aufs5-standalone/aufs5-base.patch

popd

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

## initramfs

### 按需加载固件

获取ko依赖的firmware：

modinfo ./kernel/drivers/net/wireless/intel/iwlwifi/iwlwifi.ko | grep firmware: | awk '{print $2}'

```
//todo
```

### break跳不出二重循环

bash shell script (bash脚本)中，break是退出一层循环，break 2是退出2层循环（当有相互嵌套时）,....break: **break [n]** Exit for, while, or until loops. Exit a FOR, WHILE or UNTIL loop. If N is specified, break N enclosing loops. Exit.

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



#通过GRUB设置Linux终端分辨率

[https://blog.csdn.net/Watanuki2006/article/details/52558318]

linux 命令后面跟gfxpayload=1024x968x8,800x600

## squashfs有报错

Unrecognised xattr prefix system.posix_acl_access

![image-20210420094138599](/home/uos/.config/Typora/typora-user-images/image-20210420094138599.png)

## 脚本命令行修改密码

```
chpasswd user_name:password
```

https://blog.csdn.net/weixin_33912453/article/details/91556417

# BLFS

## 1)genisoimage编译报错

[ 76%] Linking C executable genisoimage
/usr/bin/ld: CMakeFiles/genisoimage.dir/apple.o:(.bss+0x0): multiple definition of `outfile'; CMakeFiles/genisoimage.dir/genisoimage.o:(.bss+0x0): first defined here

报错原因参见：

https://code.sigidli.com/bitcoin/bitcoin/commit/c7b4968552c704f1e2e9a046911e1207f5af5fe0?lang=en-US

squashfs编译报错，同上。Makefile中添加CFLAGS +=-fcommon

/usr/bin/ld: action.o:(.bss+0x0): multiple definition of `fwriter_buffer'; read_fs.o:(.bss+0x0): first defined here
/usr/bin/ld: action.o:(.bss+0x8): multiple definition of `bwriter_buffer'; read_fs.o:(.bss+0x8): first defined here
/usr/bin/ld: sort.o:(.bss+0x100000): multiple definition of `fwriter_buffer'; read_fs.o:(.bss+0x0): first defined here



2)

Size of boot image is 256 sectors -> genisoimage: Error - boot image 'iso/boot/livecd.img' has not an allowable size.

修改

mkisofs -R -boot-info-table -b boot/livecd.img -V "mylivecd" \
        -o mylivecd.iso iso

为

mkisofs -R -boot-info-table -no-emul-boot -boot-load-size 4 -b boot/livecd.img -V "mylivecd" \
        -o mylivecd.iso iso





## 下载BLFS软件包源码

另存网页http://www.linuxfromscratch.org/blfs/downloads/stable-systemd/BLFS-BOOK-10.1-systemd-nochunks.html

为BLFS.html

grep -r "Download (HTTP)" Beyond-Linux-From-Scratch-systemd-Edition.html  | awk -F '["]' '{ print $4 }' >blfs-wget-list

wget -i blfs-wget-list



## LIVECD

### 找不到init文件

虚拟机给的内存只有1G太小了，调整为4G后可以找到init文件

### 没有/bin/bash文件，/bin/bash无法执行

缺少库文件

(lfs chroot) root:/haoos# ldd /opt/livecd/image/initramfs/bin/bash
	linux-vdso.so.1 (0x00007ffdd05d2000)
	libreadline.so.8 => /lib/libreadline.so.8 (0x00007f3d92141000)
	libhistory.so.8 => /lib/libhistory.so.8 (0x00007f3d92134000)
	libncursesw.so.6 => /lib/libncursesw.so.6 (0x00007f3d920c3000)
	libdl.so.2 => /lib/libdl.so.2 (0x00007f3d920bd000)
	libc.so.6 => /lib/libc.so.6 (0x00007f3d91ef4000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f3d9219d000)

需要拷贝/lib64/ld-linux-x86-64.so.2及其相关的链接原文件。

#cp -v /lib/ld-linux.so.2 lib/
cp -v /lib/ld-2.33.so lib/
cp -v /lib/ld-linux-x86-64.so.2 lib/
cp -v /lib64/ld-linux-x86-64.so.2 lib64/

注意：不是软链接的问题，软链接在chroot后也是有的。

