#!/bin/bash

set -x

root=/tmp/chroot
release=http://mirror.centos.org/centos/6/os/i386/Packages/centos-release-6-10.el6.centos.12.3.i686.rpm

# 准备 RPM 目录
mkdir -p "$root"/var/lib/rpm
rpm --rebuilddb --root="$root"/var/lib/rpm

# 安装 release 包
rpm -ivh --root="$root" --nodeps "$release"

# 安装其他的
yum --installroot="$root" -y install yum httpd bash
