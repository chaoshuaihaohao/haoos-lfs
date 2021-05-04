all:

check:
	./scripts/version-check-2_1.sh
dep-install:
	#安装依赖软件包
	./scripts/dep_install.sh
lfs-env-build:
	#挂载lfs分区和swap分区
	./scripts/mount_lfs_swap-2_2.sh
	#解压缩获取源代码
	./scripts/tar_xvf_sources-3.sh
	#lfs账户配置
	./scripts/adduser_lfs-4.sh

build:
	#源码包安装
	./scripts/build-5.sh
	./scripts/build-6.sh

#chroot
chroot:
	./scripts/chroot-7.sh
chroot1:
	./scripts/chroot-7_1.sh
chroot-do:
	./scripts/chroot_do-7_6.sh
build-lfs:
	./scripts/lfs_install-8_1.sh
build-lfs1:
	./scripts/lfs_install-8_2.sh
	./scripts/blfs_env_config.sh
	./pkg-install
	./scripts/lfs_symbol_clean.sh
chroot-again:
	./scripts/chroot_again.sh

system-conf:
	./scripts/system_config.sh
bootable:
	./scripts/linux_compile.sh
	./scripts/bootable-10.sh
	./scripts/ramfsdisk-10_1.sh
	./scripts/update-grub-10_2.sh
end:
	./scripts/end-11.sh
end1:
	#移除lfs文件系统不再使用的多余文件
	./scripts/clean_used_file.sh
	./scripts/end-11_1.sh

ramfs:
	./scripts/ramfsdisk-10_1.sh


unload-chroot:
	./scripts/unload-chroot.sh

clean:
	rm sources lfs lfs-sources.tar.gz -rf
	rm /mnt/lfs/* -rf
	@-umount /dev/sdb
	@-umount /dev/sdc


livecd:
	./scripts/livecd.sh
liveusb:
	./scripts/liveusb.sh

backup:
	./scripts/backup_sources.sh
