#unzip -d ./ -q $BLFS_SRC_DIR/sqlite-doc-3340100.zip

./configure --prefix=/usr     \
            --disable-static  \
            --enable-fts5     \
            CFLAGS="-g -O2                    \
            -DSQLITE_ENABLE_FTS3=1            \
            -DSQLITE_ENABLE_FTS4=1            \
            -DSQLITE_ENABLE_COLUMN_METADATA=1 \
            -DSQLITE_ENABLE_UNLOCK_NOTIFY=1   \
            -DSQLITE_ENABLE_DBSTAT_VTAB=1     \
            -DSQLITE_SECURE_DELETE=1          \
            -DSQLITE_ENABLE_FTS3_TOKENIZER=1" &&
make

make install

#install -v -m755 -d /usr/share/doc/sqlite-3.34.1 &&
#cp -v -R sqlite-doc-3340100/* /usr/share/doc/sqlite-3.34.1