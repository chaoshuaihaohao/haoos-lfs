cat > wpa_supplicant/.config << "EOF"
CONFIG_BACKEND=file
CONFIG_CTRL_IFACE=y
CONFIG_DEBUG_FILE=y
CONFIG_DEBUG_SYSLOG=y
CONFIG_DEBUG_SYSLOG_FACILITY=LOG_DAEMON
CONFIG_DRIVER_NL80211=y
CONFIG_DRIVER_WEXT=y
CONFIG_DRIVER_WIRED=y
CONFIG_EAP_GTC=y
CONFIG_EAP_LEAP=y
CONFIG_EAP_MD5=y
CONFIG_EAP_MSCHAPV2=y
CONFIG_EAP_OTP=y
CONFIG_EAP_PEAP=y
CONFIG_EAP_TLS=y
CONFIG_EAP_TTLS=y
CONFIG_IEEE8021X_EAPOL=y
CONFIG_IPV6=y
CONFIG_LIBNL32=y
CONFIG_PEERKEY=y
CONFIG_PKCS12=y
CONFIG_READLINE=y
CONFIG_SMARTCARD=y
CONFIG_WPS=y
CFLAGS += -I/usr/include/libnl3
EOF

cat >> wpa_supplicant/.config << "EOF"
CONFIG_CTRL_IFACE_DBUS=y
CONFIG_CTRL_IFACE_DBUS_NEW=y
CONFIG_CTRL_IFACE_DBUS_INTRO=y
EOF

cd wpa_supplicant 
make BINDIR=/sbin LIBDIR=/lib

#如果已安装Qt-5.15.2，并希望构建WPA Supplicant GUI程序，请运行以下命令：
pushd wpa_gui-qt4 
qmake wpa_gui.pro 
make 
popd

install -v -m755 wpa_{cli,passphrase,supplicant} /sbin/ 
install -v -m644 doc/docbook/wpa_supplicant.conf.5 /usr/share/man/man5/ 
install -v -m644 doc/docbook/wpa_{cli,passphrase,supplicant}.8 /usr/share/man/man8/

install -v -m644 systemd/*.service /lib/systemd/system/

install -v -m644 dbus/fi.w1.wpa_supplicant1.service \
                 /usr/share/dbus-1/system-services/ 
install -v -d -m755 /etc/dbus-1/system.d 
install -v -m644 dbus/dbus-wpa_supplicant.conf \
                 /etc/dbus-1/system.d/wpa_supplicant.conf

systemctl enable wpa_supplicant

install -v -m755 wpa_gui-qt4/wpa_gui /usr/bin/ 
install -v -m644 doc/docbook/wpa_gui.8 /usr/share/man/man8/ 
install -v -m644 wpa_gui-qt4/wpa_gui.desktop /usr/share/applications/ 
install -v -m644 wpa_gui-qt4/icons/wpa_gui.svg /usr/share/pixmaps/

#该软件包将桌面文件安装到/usr/share/applications层次结构中，您可以通过更新来提高系统性能和内存使用率 /usr/share/applications/mimeinfo.cache。要执行更新，您必须安装了desktop-file-utils-0.26并以root用户身份发出以下命令：
update-desktop-database -q

install -v -dm755 /etc/wpa_supplicant 
wpa_passphrase SSID SECRET_PASSWORD > /etc/wpa_supplicant/wpa_supplicant-wifi0.conf

#systemctl start wpa_supplicant@wlan0

#systemctl enable wpa_supplicant@wlan0