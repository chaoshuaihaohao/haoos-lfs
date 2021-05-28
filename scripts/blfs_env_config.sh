#!/bin/sh
set -e
#
if [ `id -u` != 0 ];then
        echo Permission delay, Please run as root!
        exit
fi

if [ -n $JOBS ];then
        JOBS=`grep -c ^processor /proc/cpuinfo 2>/dev/null`
        if [ ! $JOBS ];then
                JOBS="1"
        fi
fi
export MAKEFLAGS=-j$JOBS
export BLFS_SRC_DIR=/sources/blfs-sources
pushd /lfs

#Chapter 3. After LFS Configuration Issues
#The Bash Shell Startup Files
cat > /etc/profile << "EOF"
# Begin /etc/profile
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# modifications by Dagmar d'Surreal <rivyqntzne@pbzpnfg.arg>

# System wide environment variables and startup programs.

# System wide aliases and functions should go in /etc/bashrc.  Personal
# environment variables and startup programs should go into
# ~/.bash_profile.  Personal aliases and functions should go into
# ~/.bashrc.

# Functions to help us manage paths.  Second argument is the name of the
# path variable to be modified (default: PATH)
pathremove () {
        local IFS=':'
        local NEWPATH
        local DIR
        local PATHVARIABLE=${2:-PATH}
        for DIR in ${!PATHVARIABLE} ; do
                if [ "$DIR" != "$1" ] ; then
                  NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
                fi
        done
        export $PATHVARIABLE="$NEWPATH"
}

pathprepend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

pathappend () {
        pathremove $1 $2
        local PATHVARIABLE=${2:-PATH}
        export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
}

export -f pathremove pathprepend pathappend

# Set the initial path
export PATH=/bin:/usr/bin

if [ $EUID -eq 0 ] ; then
        pathappend /sbin:/usr/sbin
        unset HISTFILE
fi

# Setup some environment variables.
export HISTSIZE=1000
export HISTIGNORE="&:[bf]g:exit"

# Set some defaults for graphical systems
export XDG_DATA_DIRS=${XDG_DATA_DIRS:-/usr/share/}
export XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-/etc/xdg/}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/xdg-$USER}

# Setup a red prompt for root and a green one for users.
NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
  PS1="$RED\u [ $NORMAL\w$RED ]# $NORMAL"
else
  PS1="$GREEN\u [ $NORMAL\w$GREEN ]\$ $NORMAL"
fi

for script in /etc/profile.d/*.sh ; do
        if [ -r $script ] ; then
                . $script
        fi
done

unset script RED GREEN NORMAL

# End /etc/profile
EOF

install --directory --mode=0755 --owner=root --group=root /etc/profile.d

cat > /etc/profile.d/bash_completion.sh << "EOF"
# Begin /etc/profile.d/bash_completion.sh
# Import bash completion scripts

# If the bash-completion package is installed, use its configuration instead
if [ -f /usr/share/bash-completion/bash_completion ]; then

  # Check for interactive bash and that we haven't already been sourced.
  if [ -n "${BASH_VERSION-}" -a -n "${PS1-}" -a -z "${BASH_COMPLETION_VERSINFO-}" ]; then

    # Check for recent enough version of bash.
    if [ ${BASH_VERSINFO[0]} -gt 4 ] || \
       [ ${BASH_VERSINFO[0]} -eq 4 -a ${BASH_VERSINFO[1]} -ge 1 ]; then
       [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion" ] && \
            . "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion"
       if shopt -q progcomp && [ -r /usr/share/bash-completion/bash_completion ]; then
          # Source completion code.
          . /usr/share/bash-completion/bash_completion
       fi
    fi
  fi

else

  # bash-completions are not installed, use only bash completion directory
  if shopt -q progcomp; then
    for script in /etc/bash_completion.d/* ; do
      if [ -r $script ] ; then
        . $script
      fi
    done
  fi
fi

# End /etc/profile.d/bash_completion.sh
EOF

install --directory --mode=0755 --owner=root --group=root /etc/bash_completion.d

#该脚本使用~/.dircolors 和/etc/dircolors文件控制目录列表中文件名的颜色。
#它们控制ls --color之类的东西的彩色输出。
cat > /etc/profile.d/dircolors.sh << "EOF"
# Setup for /bin/ls and /bin/grep to support color, the alias is in /etc/bashrc.
if [ -f "/etc/dircolors" ] ; then
        eval $(dircolors -b /etc/dircolors)
fi

if [ -f "$HOME/.dircolors" ] ; then
        eval $(dircolors -b $HOME/.dircolors)
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'
EOF

#该脚本向添加了一些有用的路径PATH，可用于自定义所有用户可能需要的其他与PATH相关的环境变量
#（例如LD_LIBRARY_PATH等）
cat > /etc/profile.d/extrapaths.sh << "EOF"
if [ -d /usr/local/lib/pkgconfig ] ; then
        pathappend /usr/local/lib/pkgconfig PKG_CONFIG_PATH
fi
if [ -d /usr/local/bin ]; then
        pathprepend /usr/local/bin
fi
if [ -d /usr/local/sbin -a $EUID -eq 0 ]; then
        pathprepend /usr/local/sbin
fi

# Set some defaults before other applications add to these paths.
pathappend /usr/share/man  MANPATH
pathappend /usr/share/info INFOPATH
EOF

cat > /etc/profile.d/readline.sh << "EOF"
# Setup the INPUTRC environment variable.
if [ -z "$INPUTRC" -a ! -f "$HOME/.inputrc" ] ; then
        INPUTRC=/etc/inputrc
fi
export INPUTRC
EOF

cat > /etc/profile.d/umask.sh << "EOF"
# By default, the umask should be set.
if [ "$(id -gn)" = "$(id -un)" -a $EUID -gt 99 ] ; then
  umask 002
else
  umask 022
fi
EOF

cat > /etc/bashrc << "EOF"
# Begin /etc/bashrc
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# updated by Bruce Dubbs <bdubbs@linuxfromscratch.org>

# System wide aliases and functions.

# System wide environment variables and startup programs should go into
# /etc/profile.  Personal environment variables and startup programs
# should go into ~/.bash_profile.  Personal aliases and functions should
# go into ~/.bashrc

# Provides colored /bin/ls and /bin/grep commands.  Used in conjunction
# with code in /etc/profile.

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Provides prompt for non-login shells, specifically shells started
# in the X environment. [Review the LFS archive thread titled
# PS1 Environment Variable for a great case study behind this script
# addendum.]

NORMAL="\[\e[0m\]"
RED="\[\e[1;31m\]"
GREEN="\[\e[1;32m\]"
if [[ $EUID == 0 ]] ; then
  PS1="$RED\u [ $NORMAL\w$RED ]# $NORMAL"
else
  PS1="$GREEN\u [ $NORMAL\w$GREEN ]\$ $NORMAL"
fi

unset RED GREEN NORMAL

# End /etc/bashrc
EOF

cat > ~/.bash_profile << "EOF"
# Begin ~/.bash_profile
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# updated by Bruce Dubbs <bdubbs@linuxfromscratch.org>

# Personal environment variables and startup programs.

# Personal aliases and functions should go in ~/.bashrc.  System wide
# environment variables and startup programs are in /etc/profile.
# System wide aliases and functions are in /etc/bashrc.

if [ -f "$HOME/.bashrc" ] ; then
  source $HOME/.bashrc
fi

if [ -d "$HOME/bin" ] ; then
  pathprepend $HOME/bin
fi

# Having . in the PATH is dangerous
#if [ $EUID -gt 99 ]; then
#  pathappend .
#fi

# End ~/.bash_profile
EOF

cat > ~/.profile << "EOF"
# Begin ~/.profile
# Personal environment variables and startup programs.

if [ -d "$HOME/bin" ] ; then
  pathprepend $HOME/bin
fi

# Set up user specific i18n variables
#export LANG=<ll>_<CC>.<charmap><@modifiers>
export LANG=zh_CN.UTF-8
# End ~/.profile
EOF

cat > ~/.bashrc << "EOF"
# Begin ~/.bashrc
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>

# Personal aliases and functions.

# Personal environment variables and startup programs should go in
# ~/.bash_profile.  System wide environment variables and startup
# programs are in /etc/profile.  System wide aliases and functions are
# in /etc/bashrc.

if [ -f "/etc/bashrc" ] ; then
  source /etc/bashrc
fi

# Set up user specific i18n variables
#export LANG=<ll>_<CC>.<charmap><@modifiers>
export LANG=zh_CN.UTF-8
# End ~/.bashrc
EOF

cat > ~/.bash_logout << "EOF"
# Begin ~/.bash_logout
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>

# Personal items to perform on logout.

# End ~/.bash_logout
EOF

dircolors -p > /etc/dircolors




#Chapter 14. Connecting to a Network网桥配置
cat > /etc/systemd/network/50-br0.netdev << EOF
[NetDev]
Name=br0
Kind=bridge
EOF

cat > /etc/systemd/network/51-eth0.network << EOF
[Match]
Name=$ETH

[Network]
Bridge=br0
EOF

cat > /etc/systemd/network/60-br0.network << EOF
[Match]
Name=br0

[Network]
DHCP=yes
EOF

cat > /etc/systemd/network/60-br0.network << EOF
[Match]
Name=br0

[Network]
Address=192.168.0.2/24
Gateway=192.168.0.1
DNS=192.168.0.1
EOF

systemctl restart systemd-networkd

#Chapter 24. X Window系统环境
export XORG_PREFIX="/usr"

export XORG_CONFIG="--prefix=$XORG_PREFIX --sysconfdir=/etc \
    --localstatedir=/var --disable-static"

mkdir -vp /etc/profile.d
touch /etc/profile.d/xorg.sh
cat > /etc/profile.d/xorg.sh << EOF
XORG_PREFIX="$XORG_PREFIX"
XORG_CONFIG="--prefix=\$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static"
export XORG_PREFIX XORG_CONFIG
EOF
chmod 644 /etc/profile.d/xorg.sh

#调整Fontconfig
mkdir -pv ~/.config/fontconfig &&
cat > ~/.config/fontconfig/fonts.conf << "EOF"
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>

  <match target="font" >
    <!-- autohint was the old automatic hinter when hinting was patent
    protected, so turn it off to ensure any hinting information in the font
    itself is used, this is the default -->
    <edit mode="assign" name="autohint">  <bool>false</bool></edit>

    <!-- hinting is enabled by default -->
    <edit mode="assign" name="hinting">   <bool>true</bool></edit>
    
    <!-- for the lcdfilter see http://www.spasche.net/files/lcdfiltering/ -->
    <edit mode="assign" name="lcdfilter"> <const>lcddefault</const></edit>
    
    <!-- options for hintstyle:
    hintfull: is supposed to give a crisp font that aligns well to the
    character-cell grid but at the cost of its proper shape.

    hintmedium: poorly documented, maybe a synonym for hintfull.
    hintslight is the default: - supposed to be more fuzzy but retains shape.
    
    hintnone: seems to turn hinting off.
    The variations are marginal and results vary with different fonts -->
    <edit mode="assign" name="hintstyle"> <const>hintslight</const></edit>
    
    <!-- antialiasing is on by default and really helps for faint characters
    and also for 'xft:' fonts used in rxvt-unicode -->
    <edit mode="assign" name="antialias"> <bool>true</bool></edit>
    
    <!-- subpixels are usually rgb, see
    http://www.lagom.nl/lcd-test/subpixel.php -->
    <edit mode="assign" name="rgba">      <const>rgb</const></edit>
    
    <!-- thanks to the Arch wiki for the lcd and subpixel links -->
  </match>

</fontconfig>
EOF


#禁用位图字体
mkdir -pv /etc/fonts/conf.d/
cat > /etc/fonts/conf.d/70-no-bitmaps.conf << "EOF"
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
<!-- Reject bitmap fonts -->
 <selectfont>
  <rejectfont>
   <pattern>
     <patelt name="scalable"><bool>false</bool></patelt>
   </pattern>
  </rejectfont>
 </selectfont>
</fontconfig>
EOF

#添加额外的字体目录
cat > /etc/fonts/conf.d/09-texlive.conf << "EOF"
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
  <dir>/opt/texlive/2020/texmf-dist/fonts/opentype/arkandis/berenisadf</dir>
  <dir>/opt/texlive/2020/texmf-dist/fonts/truetype/paratype</dir>
</fontconfig>
EOF

#首选特定字体
mkdir -pv ~/.config/fontconfig/conf.d &&
cat >  ~/.config/fontconfig/conf.d/35-prefer-nimbus-for-timesnew.conf << "EOF"
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
<!-- prefer Nimbus Roman No9 L for Times New Roman as well as for Times,
 without this Tinos and Liberation Serif take precedence for Times New Roman
 before fontconfig falls back to whatever matches Times -->
    <alias binding="same">
        <family>Times New Roman</family>
        <accept>
            <family>Nimbus Roman No9 L</family>
        </accept>
    </alias>
</fontconfig>
EOF


#优先选择CJK字体
cat > /etc/fonts/local.conf << "EOF"
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
    <alias>
        <family>serif</family>
        <prefer>
            <family>AR PL UMing</family>
            <family>IPAexMincho</family>
            <!-- WenQuanYi is preferred as Serif in 65-nonlatin.conf,
            override that so a real Korean font can be used for Serif -->
            <family>UnBatang</family>
        </prefer>
    </alias>
    <alias>
         <family>sans-serif</family>
         <prefer>
             <family>WenQuanYi Zen Hei</family>
             <family>VL Gothic</family>
             <family>IPAexGothic</family>
         </prefer>
    </alias>
    <alias>
         <family>monospace</family>
         <prefer>
             <family>VL Gothic</family>
             <family>IPAexGothic</family>
             <family>WenQuanYi Zen Hei</family>
         </prefer>
    </alias>
</fontconfig>
EOF


popd #LFS
