./configure --prefix=/usr &&
make
make install &&
ln -svfn aspell-0.60 /usr/lib/aspell &&

install -v -m755 -d /usr/share/doc/aspell-0.60.8/aspell{,-dev}.html &&

install -v -m644 manual/aspell.html/* \
    /usr/share/doc/aspell-0.60.8/aspell.html &&

install -v -m644 manual/aspell-dev.html/* \
    /usr/share/doc/aspell-0.60.8/aspell-dev.html
install -v -m 755 scripts/ispell /usr/bin/
install -v -m 755 scripts/spell /usr/bin/