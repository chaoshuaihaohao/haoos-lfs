#!/bin/bash
set -e
#Chapter 8
#8.77. Cleaning Up

find /usr/lib /usr/libexec -name \*.la -delete
find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
rm -rf /tools
userdel -rf tester
