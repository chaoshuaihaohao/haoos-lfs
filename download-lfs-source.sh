#!/bin/bash
  echo -n "Creating URLs file... "
 sudo xsltproc --nonet --xinclude                \
           --stringparam server "$SERVER"    \
           --stringparam family lfs          \
           --stringparam pkgmngt "$PKGMNGT"  \
           --stringparam revision "$INITSYS" \
           --output $JHALFSDIR/urls.lst      \
           urls.xsl                          \
           $BOOK/lfs-book/chapter03/chapter03.xml 
  echo "OK"


