make

make prefix=/usr install                                 
mv /usr/bin/traceroute /bin                              
ln -sv -f traceroute /bin/traceroute6                    
ln -sv -f traceroute.8 /usr/share/man/man8/traceroute6.8 
rm -fv /usr/share/man/man1/traceroute.1