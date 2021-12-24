#!/bin/bash
set -e
#Chapter 9. System Configuration

:<<!
#9.2. General Network Configuration
#9.2.1.1. Network Device Naming
ln -s /dev/null /etc/systemd/network/99-default.link

cat > /etc/systemd/network/10-ether0.link << "EOF"
[Match]
# 将 MAC 地址替换为适用于您的网络设备的值
MACAddress=12:34:45:78:90:AB

[Link]
Name=ether0
EOF
#9.2.1.2. Static IP Configuration
cat > /etc/systemd/network/10-eth-static.network << "EOF"
[Match]
Name=<network-device-name>

[Network]
Address=192.168.0.2/24
Gateway=192.168.0.1
DNS=192.168.0.1
Domains=<Your Domain Name>
EOF

#9.2.1.3. DHCP Configuration
cat > /etc/systemd/network/10-eth-dhcp.network << "EOF"
[Match]
Name=<network-device-name>

[Network]
DHCP=ipv4

[DHCP]
UseDomains=true
EOF
!

#9.2.2. Creating the /etc/resolv.conf File
#9.2.2.1. systemd-resolved Configuration
#ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf
#9.2.2.2. Static resolv.conf Configuration
cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

#domain <Your Domain Name>
#nameserver <IP address of your primary nameserver>
#nameserver <IP address of your secondary nameserver>
nameserver 10.20.0.10
nameserver 10.20.0.52
nameserver 8.8.8.8
nameserver 8.8.4.4

# End /etc/resolv.conf
EOF

#9.2.3. Configuring the system hostname
echo "haoos" > /etc/hostname

#9.2.4. Customizing the /etc/hosts File
cat > /etc/hosts << "EOF"
# Begin /etc/hosts

#127.0.0.1 localhost.localdomain localhost
127.0.0.1       localhost
#127.0.1.1 <FQDN> <HOSTNAME>
127.0.1.1 haoos
#<192.168.0.2> <FQDN> <HOSTNAME> [alias1] [alias2] ...
#::1       localhost ip6-localhost ip6-loopback
#ff02::1   ip6-allnodes
#ff02::2   ip6-allrouters

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# End /etc/hosts
EOF

#9.8. Creating the /etc/inputrc File
. ./build/cmd/lfs/chapter09/inputrc.cmd

#9.9. Creating the /etc/shells File
. ./build/cmd/lfs/chapter09/etcshells.cmd

#9.10.2. Disabling Screen Clearing at Boot Time

#9.10.3. Disabling tmpfs for /tmp
#. ./build/cmd/lfs/chapter09/systemd-custom.cmd


