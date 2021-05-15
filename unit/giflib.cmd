make


make PREFIX=/usr install

find doc \( -name Makefile\* -o -name \*.1 \
         -o -name \*.xml \) -exec rm -v {} \; &&

install -v -dm755 /usr/share/doc/giflib-5.2.1 &&
cp -v -R doc/* /usr/share/doc/giflib-5.2.1

