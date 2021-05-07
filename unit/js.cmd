mountpoint -q /dev/shm || mount -t tmpfs devshm /dev/shm

mkdir obj &&
pushd    obj &&

CC=gcc CXX=g++ \
../js/src/configure --prefix=/usr            \
                    --with-intl-api          \
                    --with-system-zlib       \
                    --with-system-icu        \
                    --disable-jemalloc       \
                    --disable-debug-symbols  \
                    --enable-readline        &&
make

#rm -fv /usr/lib/libmozjs-78.so

make install &&
rm -v /usr/lib/libjs_static.ajs &&
sed -i '/@NSPR_CFLAGS@/d' /usr/bin/js78-config

popd