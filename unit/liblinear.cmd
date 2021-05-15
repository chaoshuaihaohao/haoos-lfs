make lib

install -vm644 linear.h /usr/include 
install -vm755 liblinear.so.4 /usr/lib 
ln -sfv liblinear.so.4 /usr/lib/liblinear.so