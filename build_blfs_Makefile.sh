#!/bin/bash

#build_Makefile=$JHALFSDIR/blfs_Makefile
build_Makefile=./blfs_Makefile
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
SCRIPT_ROOT    = jhalfs/blfs

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

all: make_CHROOT

point:
	@( sudo \$(CHROOT1) -c "cd \$(SCRIPT_ROOT) && make \$(TARGET)")

#chroot build
make_CHROOT:
	@( sudo \$(CHROOT1) -c "cd \$(SCRIPT_ROOT) && make CHROOT")

EOF
) >> $build_Makefile


python3 libs/menu/blfs.py >> $build_Makefile
