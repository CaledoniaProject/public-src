#!/bin/bash

set -x

# ubuntu 18.04
release=bionic
path=/chroot/
arch=amd64
# arch=i386

# 安装基础包
debootstrap --variant=buildd --arch "$arch" bionic "$path" http://cn.archive.ubuntu.com/ubuntu

# 配置
cat > "$path"/etc/apt/sources.list << EOF
deb http://cn.archive.ubuntu.com/ubuntu/ ${release} main restricted universe multiverse 
deb http://cn.archive.ubuntu.com/ubuntu/ ${release}-updates main restricted universe multiverse 
deb http://cn.archive.ubuntu.com/ubuntu/ ${release}-backports main restricted universe multiverse 
EOF

chroot "$path" locale-gen en_US.UTF-8

