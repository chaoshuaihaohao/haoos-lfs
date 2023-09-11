#!/bin/bash
build_Makefile=$JHALFSDIR/Makefile
: > $build_Makefile

  # Add chroot commands
  CHROOT_LOC="`whereis -b chroot | cut -d " " -f2`"
  i=1
  #for file in $BOOK/charpter07/*chroot* ; do
  for file in /mnt/build_dir/jhalfs/book-source/lfs-book/chapter07/*chroot* ; do
    chroot=`cat $file | \
            perl -pe 's|\\\\\n||g' | \
            tr -s [:space:] | \
            grep chroot | \
	    grep -o '>[^<]*<' | \
	    grep sbin | \
	    tr -d '><' | \
            sed -e "s|chroot|$CHROOT_LOC|" \
                -e 's|\\$|&&|g' \
                -e 's|"$$LFS"|$(MOUNT_PT)|'
`
    echo -e "CHROOT$i= $chroot\n" >> $build_Makefile
    i=`expr $i + 1`
  done


(
    cat << EOF
.NOTPARALLEL:

SHELL = /bin/bash
SRC            = /sources
MOUNT_PT       = /mnt/build_dir
PKG_LST        = unpacked
LUSER          = lfs
LGROUP         = lfs
LHOME          = /home
SCRIPT_ROOT    = jhalfs

BASEDIR        = \$(MOUNT_PT)
SRCSDIR        = \$(BASEDIR)/sources
CMDSDIR        = \$(BASEDIR)/\$(SCRIPT_ROOT)/lfs-commands
LOGDIR         = \$(BASEDIR)/\$(SCRIPT_ROOT)/logs
TESTLOGDIR     = \$(BASEDIR)/\$(SCRIPT_ROOT)/test-logs

crCMDSDIR      = \$(SCRIPT_ROOT)/lfs-commands
crLOGDIR       = \$(SCRIPT_ROOT)/logs
crTESTLOGDIR   = \$(SCRIPT_ROOT)/test-logs
crFILELOGDIR   = \$(SCRIPT_ROOT)/installed-files

SU_LUSER       = sudo -H -u \$(LUSER) sh -c

EOF
) >> $build_Makefile

(
    cat << EOF

all: make_SETUP make_LUSER make_CHROOT

#host build
make_SETUP:
	make -C $JHALFSDIR SETUP

#lfs build
make_LUSER:
	\$(SU_LUSER) "make -C $JHALFSDIR LUSER"

make_SUDO:
	sudo "make -C $JHALFSDIR SUDO"


#chroot build
make_CHROOT:
	@( sudo \$(CHROOT1) -c "cd \$(SCRIPT_ROOT) && make CHROOT")

EOF
) >> $build_Makefile

PRE=""
SETUP_TGT=""
LUSER_TGT=""
SUDO_TGT=""
CHROOT_TGT=""
for script in $(find ${JHALFSDIR}/${COMMANDS}/chapter*/* -type f | sort -n)
do
	name=$(basename "$script")
	echo -e "$name: $PRE" >> $build_Makefile

	case "$name" in
	401-creatingminlayout | 402-addinguser)
		SETUP_TGT="$SETUP_TGT $name"
(cat << EOF
	export LFS=\$(MOUNT_PT) && bash $script > /dev/null && \\
	touch $name

EOF
) >> $build_Makefile
		;;
	403-settingenvironment) #403-settingenvironment need to be processed by lfs user count
		LUSER_TGT="$LUSER_TGT $name"
(cat << EOF
	@cd && function source() { true; } && \\
	export -f source && \\
        bash $script > /dev/null && \\
        sed 's|/mnt/lfs|\$(MOUNT_PT)|' -i .bashrc && \\
	cd - && \\
	touch $name

EOF
) >> $build_Makefile
		;;
	5*|6*)
		LUSER_TGT="$LUSER_TGT $name"
(cat << EOF
	@source ~/.bashrc && \\
	bash $script > /dev/null && \\
	touch $name

EOF
) >> $build_Makefile
		;;
	701*|702*)
		SUDO_TGT="$SUDO_TGT $name"
(cat << EOF
	export LFS=\$(MOUNT_PT) && bash $script > /dev/null && \\
	touch $name

EOF
) >> $build_Makefile
		;;
	7*|8*)
		CHROOT_TGT="$CHROOT_TGT $name"
(cat << EOF
	bash $script > /dev/null && \\
	touch $name

EOF
) >> $build_Makefile
		;;
	*) 
		;;
	esac

	PRE=$name
done

(cat << EOF
SETUP: $SETUP_TGT

LUSER: $LUSER_TGT

SUDO: $SUDO_TGT

CHROOT: $CHROOT_TGT
EOF
) >> $build_Makefile
