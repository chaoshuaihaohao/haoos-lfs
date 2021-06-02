groupadd -g 21 gdm 
useradd -c "GDM Daemon Owner" -d /var/lib/gdm -u 21 \
        -g gdm -s /bin/false gdm 
passwd -ql gdm

mkdir build 
pushd    build 

meson --prefix=/usr               \
      -Dplymouth=disabled         \
      -Dgdm-xsession=true         \
      -Dpam-mod-dir=/lib/security .. 
ninja

ninja install

systemctl enable gdm

popd