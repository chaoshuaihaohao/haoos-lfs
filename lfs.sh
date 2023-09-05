#!/bin/bash

source ./configuration

BOOK=${BOOK:=$JHALFSDIR/book-source}
PRO=$(pwd)
declare -r COMMANDS=lfs-commands


# These are boolean vars generated from Config.in.
# ISSUE: If a boolean parameter is not set to y(es) there
# is no variable defined by the menu app. This can
# cause a headache if you are not aware.
#  The following variables MUST exist. If they don't, the
#  default value is n(o).
RUNMAKE=${RUNMAKE:-n}
GETPKG=${GETPKG:-n}
COMPARE=${COMPARE:-n}
RUN_ICA=${RUN_ICA:-n}
PKGMNGT=${PKGMNGT:-n}
WRAP_INSTALL=${WRAP_INSTALL:-n}
STRIP=${STRIP:=n}
REPORT=${REPORT:=n}
NCURSES5=${NCURSES5:-n}
DEL_LA_FILES=${DEL_LA_FILES:-n}
FULL_LOCALE=${FULL_LOCALE:-n}
GRSECURITY_HOST=${GRSECURITY_HOST:-n}
CUSTOM_TOOLS=${CUSTOM_TOOLS:-n}
REBUILD_MAKEFILE=${REBUILD_MAKEFILE:-n}
INSTALL_LOG=${INSTALL_LOG:-n}
CLEAN=${CLEAN:=n}
SET_SSP=${SET_SSP:=n}
SET_ASLR=${SET_ASLR:=n}
SET_PAX=${SET_PAX:=n}
SET_HARDENED_TMP=${SET_HARDENED_TMP:=n}
SET_WARNINGS=${SET_WARNINGS:=n}
SET_MISC=${SET_MISC:=n}
SET_BLOWFISH=${SET_BLOWFISH:=n}
UNICODE=${UNICODE:=n}
LOCAL=${LOCAL:=n}
REALSBU=${REALSBU:=n}
SAVE_CH5=${SAVE_CH5:=n}

#create build dir
if [ ! -d "$BUILDDIR" ];then
	sudo mkdir -p "$BUILDDIR"
fi

#download-lfs-book: 
echo "Getting the LFS book sources..."
git clone git://git.linuxfromscratch.org/lfs.git lfs-book || true

#download-blfs-book:
echo "Getting the BLFS book sources..."
git clone git://git.linuxfromscratch.org/blfs.git blfs-book || true

#copy the book sources to build_dir
if [ ! -d "$BOOK" ];then
	sudo mkdir -p "$BOOK"
fi
if [ $BOOK_LFS_SYSD = "y" ];then
	sudo cp -a ./lfs-book "$BOOK"/
fi

if [ "$BOOK_BLFS"  = "y" ];then
	sudo cp -a ./blfs-book "$BOOK"/
fi

#parse lfs/blfs book
#generate lfs sources build command xml
if [ ! -d "$JHALFSDIR/$COMMANDS" ];then
	sudo mkdir -p "$JHALFSDIR/$COMMANDS"
	sudo chmod a+x "$JHALFSDIR/$COMMANDS"
fi
source ./parse-lfs-book.sh

#generate blfs sources build command xml
#source ./parse-lfs-book.sh


#download lfs sources
source ./download-lfs-source.sh


#download blfs sources
#source ./download-lfs-source.sh

#generate build Makefile
source ./build_Makefile.sh

#chapter04
sudo make -f ./build_Makefile LFS=$BUILD_DIR

#build sources, pass 1
#>su lfs

#build sources, pass 2
#>chroot

#build sources,pass 3
#>chroot


