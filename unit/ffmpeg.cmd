sed -i 's/-lflite"/-lflite -lasound"/' configure &&

./configure --prefix=/usr        \
            --enable-gpl         \
            --enable-version3    \
            --enable-nonfree     \
            --disable-static     \
            --enable-shared      \
            --disable-debug      \
            --enable-avresample  \
            --enable-libass      \
            --enable-libfdk-aac  \
            --enable-libfreetype \
            --enable-libmp3lame  \
            --enable-libopus     \
            --enable-libtheora   \
            --enable-libvorbis   \
            --enable-libvpx      \
            --enable-libx264     \
            --enable-libx265     \
            --enable-openssl     \
            --docdir=/usr/share/doc/ffmpeg-4.3.2 &&

make &&

gcc tools/qt-faststart.c -o tools/qt-faststart




:<<eof
pushd doc &&
for DOCNAME in `basename -s .html *.html`
do
    texi2pdf -b $DOCNAME.texi &&
    texi2dvi -b $DOCNAME.texi &&

    dvips    -o $DOCNAME.ps   \
                $DOCNAME.dvi
done &&
popd &&
unset DOCNAME
eof




make install &&

install -v -m755    tools/qt-faststart /usr/bin &&
install -v -m755 -d           /usr/share/doc/ffmpeg-4.3.2 &&
install -v -m644    doc/*.txt /usr/share/doc/ffmpeg-4.3.2


#install -v -m644 doc/*.pdf /usr/share/doc/ffmpeg-4.3.2 &&
#install -v -m644 doc/*.ps  /usr/share/doc/ffmpeg-4.3.2



#install -v -m755 -d /usr/share/doc/ffmpeg-4.3.2/api                     &&
#cp -vr doc/doxy/html/* /usr/share/doc/ffmpeg-4.3.2/api                  &&
#find /usr/share/doc/ffmpeg-4.3.2/api -type f -exec chmod -c 0644 \{} \; &&
#find /usr/share/doc/ffmpeg-4.3.2/api -type d -exec chmod -c 0755 \{} \;


