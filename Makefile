all:

check:
	./scripts/version-check-2_1.sh
dep-install:
	#安装依赖软件包
	./scripts/dep_install.sh
lfs-env-build:
	#挂载lfs分区和swap分区
	./scripts/mount_lfs_swap-2_2.sh
	#lfs账户配置/拷贝haoos-lfs到/home/lfs目录
	./scripts/adduser_lfs-4.sh

build:
	#源码包安装
	./scripts/build-5_6.sh

chroot:
	./scripts/chroot-7.sh
chroot1:
	./scripts/chroot-7_1.sh
chroot-do:
	./scripts/chroot_do-7_6.sh
build-lfs:
	./scripts/lfs_install-8_1.sh
system-conf:
	./scripts/system_config.sh
build-lfs1:
	./scripts/lfs_install-8_2.sh
	./scripts/clean_up.sh

#begin 构建blfs系统包
chroot-again:
	./scripts/chroot_again.sh
build-blfs:
	./scripts/source.sh
	./pkg-install -i all
	./scripts/other_install.sh
#end 构建blfs系统包

symbol-clean:
	./scripts/clean_up.sh
	./scripts/lfs_symbol_clean.sh

bootable:
	./scripts/linux_compile.sh
	./scripts/bootable-10.sh
	./scripts/ramfsdisk-10_1.sh
	./scripts/update-grub-10_2.sh
end:
	./scripts/end-11.sh

ramfs:
	./scripts/ramfsdisk-10_1.sh

unload-chroot:
	./scripts/unload-chroot.sh

clean:
	rm sources lfs lfs-sources.tar.gz -rf
	rm /mnt/lfs/* -rf
	@-umount /dev/sdb
	@-umount /dev/sdc

iso:
	./scripts/live.sh

backup:
	./scripts/backup_sources.sh
