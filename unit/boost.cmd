./bootstrap.sh --prefix=/usr --with-python=python3 &&
./b2 stage -j<N> threading=multi link=shared
./b2 install threading=multi link=shared
