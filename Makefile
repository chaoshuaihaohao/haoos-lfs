all:
	@sudo rm cmd.txt cmd -rf
	@./parse-blfs-book.sh
	@cat cmd.txt
	@./build_blfs_Makefile.sh

lfs: check dep-install menuconfig
	./lfs.sh

blfs-menu:
	@CONFIG_="" KCONFIG_CONFIG=blfs-configuration	\
		       python3 ./libs/menu/menuconfig.py cmd.txt

menuconfig:
	@cp -a configuration configuration.old 2>/dev/null || true
	@CONFIG_="" KCONFIG_CONFIG=configuration	\
		       python3 ./libs/menu/menuconfig.py Config.in

check:
	@./scripts/version-check-2_1.sh
	@touch $@
dep-install: check
	#安装依赖软件包
	@./scripts/dep_install.sh
	@touch $@
lfs-env-build: dep-install
	#挂载lfs分区和swap分区
	./scripts/mount_lfs_swap-2_2.sh
	#lfs账户配置/拷贝haoos-lfs到/home/lfs目录
	./scripts/adduser_lfs-4.sh

download-lfs-book: 
	@echo "Getting the LFS book sources..."
	@git clone git://git.linuxfromscratch.org/lfs.git lfs-book || true

download-blfs-book:
	@echo "Getting the BLFS book sources..."
	@git clone git://git.linuxfromscratch.org/blfs.git blfs-book
	#copy book to build dir
	#todo

parse-lfs-book: download-lfs-book
	#parse lfs-book, output urls and downloads it, output sources build cmd
	./parse-lfs-book.sh

parse-blfs-book: download-blfs-book

download-lfs-sources: parse-lfs-book

download-blfs-sources: parse-blfs-book


mnt-lfs-build: lfs-env-build
	#源码包安装,生成的文件在/mnt/lfs/tools目录下
	./scripts/build-5_6.sh

chroot: mnt-lfs-build
	./scripts/chroot-7.sh
chroot1: chroot
	./scripts/chroot-7_1.sh
chroot-do: chroot1
	./scripts/chroot_do-7_6.sh
build-lfs: 
	./scripts/lfs_install-8_1.sh
build-lfs1:
	./scripts/lfs_install-8_2.sh
#	./scripts/clean_up.sh
system-conf:
	./scripts/system_config.sh

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
