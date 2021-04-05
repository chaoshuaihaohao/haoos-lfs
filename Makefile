all:

check:
	./scripts/version-check.sh
dep-install:
	#安装依赖软件包
	./scripts/dep_install.sh
lfs-env-build:
	#挂载lfs分区和swap分区
	./scripts/mount_lfs_swap.sh
	#解压缩获取源代码
	./scripts/tar_xvf_sources.sh
	#lfs账户配置
	./scripts/adduser_lfs.sh

build:
	#源码包安装
	./scripts/build_5.sh
	./scripts/build_6.sh

#chroot
chroot:
	./scripts/chroot.sh
chroot1:
	./scripts/chroot1.sh
chroot-do:
	./scripts/chroot_do.sh
build-lfs:
	./scripts/build_lfs_system.sh
build-lfs1:
	./scripts/build_lfs_system1.sh
chroot-again:
	./scripts/chroot_again.sh


unload-chroot:
	./scripts/unload-chroot.sh


clean:
	rm sources lfs lfs-sources.tar.gz -rf
	rm /mnt/lfs/* -rf
	@-umount /dev/sdb
	@-umount /dev/sdc
