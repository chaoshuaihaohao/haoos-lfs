#!/bin/bash
set -e
#Chapter 8. Installing Basic System Software
if [ -n $JOBS ];then
        JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
        if [ ! $JOBS ];then
                JOBS="1"
        fi
fi
export MAKEFLAGS=-j$JOBS

./os-build/install.sh -f ./os-build/lfs-list-chapter09
#8.35. Libtool-2.4.6
#8.36. GDBM-1.19
#8.37. Gperf-3.1
#8.38. Expat-2.2.10
#8.39. Inetutils-2.0
#8.40. Perl-5.32.1
#8.41. XML::Parser-2.46
#8.42. Intltool-0.51.0
#8.43. Autoconf-2.71
#8.44. Automake-1.16.3
#8.45. Kmod-28
#8.46. Libelf from Elfutils-0.183
#8.47. Libffi-3.3
#8.48. OpenSSL-1.1.1j
#8.49. Python-3.9.2
#8.50. Ninja-1.10.2
#8.51. Meson-0.57.1
#8.52. Coreutils-8.32
#8.53. Check-0.15.2
#8.54. Diffutils-3.7
#8.55. Gawk-5.1.0
#8.56. Findutils-4.8.0
#8.57. Groff-1.22.4
#8.58. GRUB-2.04
#8.59. Less-563
#8.60. Gzip-1.10
#8.61. IPRoute2-5.10.0
#8.62. Kbd-2.4.0
#8.63. Libpipeline-1.5.3
#8.64. Make-4.3
#8.65. Patch-2.7.6
#8.66. Man-DB-2.9.4
#8.67. Tar-1.34
#8.68. Texinfo-6.7
#8.69. Vim-8.2.2433
#8.70. Systemd-247
#8.71. D-Bus-1.12.20
#8.72. Procps-ng-3.3.17
#8.73. Util-linux-2.36.2
#8.74. E2fsprogs-1.46.1
