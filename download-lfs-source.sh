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

# Create $BUILDDIR/sources
  if [[ ! -d $BUILDDIR/sources ]]; then
    sudo mkdir -p "$BUILDDIR/sources"
    sudo chmod a+wt "$BUILDDIR/sources"
  fi


  if [ $GETPKG == "y" ];then
  echo -n "Parse URLs file and download sources... "
__label:
missing_files=0
pid_array=()

while IFS=" " read -r url md5; do  
    file_name=$(basename "$url")  
  
    if [[ -f "$file_name" ]]; then  
        computed_md5=$(md5sum "$file_name" | awk '{print $1}')  
  
        if [[ "$computed_md5" == "$md5" ]]; then  
            #echo "File $file_name exists and MD5 check passed."
            continue  
        else  
            echo "MD5 check failed for file $file_name . computed: $computed_md5, expected: $md5"  
	    wget -P "$BUILDDIR/sources" -N -c $url &
        fi  
    else  
        echo "File $file_name is missing. Downloads it..."  
	missing_files=1
	wget -P "$BUILDDIR/sources" -N -c $url &
	pid=$!
	pid_array+=($pid)
    fi  
done < $JHALFSDIR/urls.lst

if [ $missing_files -eq 0 ]; then
    echo "All packets have downloaded."
fi
  echo "OK"
fi

sudo chown -R lfs:lfs $BUILDDIR/sources
