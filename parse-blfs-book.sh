#!/bin/bash
BOOK=/home/hao/github/haoos-lfs/
pushd $BOOK/blfs-book
#bash process-scripts.sh
#bash git-version.sh systemd


: << 'END'
echo "Starting parse lfs book ..."
  # First profile the book, for revision and arch. Note that
  # MULTIBLIB is set to "default" if pure 64 bit book. In this case,
  # profiling on arch is useless, but does not hurt either.
xsltproc --nonet                                      \
	--xinclude                                   \
	--stringparam url "" \
	--stringparam profile.revision "systemd"    \
	--stringparam profile.arch     "default"   \
	--output prbook.xml                          \
	"${BOOK}"/blfs-book/stylesheets/lfs-xsl/profile.xsl        \
	"${BOOK}"/blfs-book/index.xml 
  # Use the profiled book for generating the scriptlets
sudo  xsltproc --nonet                                      \
           --stringparam testsuite      "$TEST"         \
           --stringparam ncurses5       "$NCURSES5"     \
           --stringparam strip          "$STRIP"        \
           --stringparam del-la-files   "$DEL_LA_FILES" \
           --stringparam full-locale    "$FULL_LOCALE"  \
           --stringparam timezone       "$TIMEZONE"     \
           --stringparam page           "$PAGE"         \
           --stringparam lang           "$LANG"         \
           --stringparam pkgmngt        "$PKGMNGT"      \
           --stringparam wrap-install   "$WRAP_INSTALL" \
           --stringparam hostname       "$HOSTNAME"     \
           --stringparam interface      "$INTERFACE"    \
           --stringparam ip             "$IP_ADDR"      \
           --stringparam gateway        "$GATEWAY"      \
           --stringparam prefix         "$PREFIX"       \
           --stringparam broadcast      "$BROADCAST"    \
           --stringparam domain         "$DOMAIN"       \
           --stringparam nameserver1    "$DNS1"         \
           --stringparam nameserver2    "$DNS2"         \
           --stringparam font           "$FONT"         \
           --stringparam fontmap        "$FONTMAP"      \
           --stringparam unicode        "$UNICODE"      \
           --stringparam keymap         "$KEYMAP"       \
           --stringparam local          "$LOCAL"        \
           --stringparam log-level      "$LOG_LEVEL"    \
           --stringparam script-root    "$SCRIPT_ROOT"  \
           --output "${JHALFSDIR}/${COMMANDS}/"                    \
	   $PRO/lfs.xsl                                        \
           prbook.xml

  echo "${JHALFSDIR}/${COMMANDS}/"
  echo $PRO
END
  # Use the profiled book for generating the scriptlets
sudo rm -rf /home/hao/github/haoos-lfs/output.txt
sudo  xsltproc --nonet                                      \
           --output "/home/hao/github/haoos-lfs/cmd.txt"                    \
	   /home/hao/github/haoos-lfs/blfs.xsl                                        \
           prbook.xml 

find  "/mnt/build_dir/jhalfs/blfs-commands"  -type f | xargs sudo chmod a+x
echo "Parse blfs book done."
popd
