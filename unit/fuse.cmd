sed -i '/^udev/,$ s/^/#/' util/meson.build 

mkdir build 
pushd    build 

meson --prefix=/usr .. 
ninja

#doxygen doc/Doxyfile

ninja install                                             

mv -vf   /usr/lib/libfuse3.so.3*     /lib                 
ln -sfvn ../../lib/libfuse3.so.3.10.2 /usr/lib/libfuse3.so 

mv -vf /usr/bin/fusermount3  /bin         
mv -vf /usr/sbin/mount.fuse3 /sbin        
chmod u+s /bin/fusermount3                

#install -v -m755 -d /usr/share/doc/fuse-3.10.2      
#install -v -m644    ../doc/{README.NFS,kernel.txt} \
#                    /usr/share/doc/fuse-3.10.2      
#cp -Rv ../doc/html  /usr/share/doc/fuse-3.10.2

popd

cat > /etc/fuse.conf << "EOF"
# Set the maximum number of FUSE mounts allowed to non-root users.
# The default is 1000.
#
#mount_max = 1000

# Allow non-root users to specify the 'allow_other' or 'allow_root'
# mount options.
#
#user_allow_other
EOF