sed -i s/3000/5000/ libxslt/transform.c doc/xsltproc.{1,xml} 
./configure --prefix=/usr --disable-static --without-python  
make

sed -e 's@http://cdn.docbook.org/release/xsl@https://cdn.docbook.org/release/xsl-nons@' \
    -e 's@\$Date\$@31 October 2019@' -i doc/xsltproc.xml 
xsltproc/xsltproc --nonet doc/xsltproc.xml -o doc/xsltproc.1

#make check

make install -j1
