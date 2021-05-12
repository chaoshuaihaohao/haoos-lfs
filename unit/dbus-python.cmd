mkdir python3 &&
pushd python3 &&
PYTHON=/usr/bin/python3    \
../configure --prefix=/usr --docdir=/usr/share/doc/dbus-python-1.2.16 &&
make &&
popd

#make -C python3 check

make -C python3 install