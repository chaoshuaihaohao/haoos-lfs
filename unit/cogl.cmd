./configure --prefix=/usr  \
            --enable-gles1 \
            --enable-gles2 \
            --enable-{kms,wayland,xlib}-egl-platform \
            --enable-wayland-egl-server              
make
#make check
make install -j1
