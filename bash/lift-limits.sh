#!/bin/bash
setenforce 0
echo SELINUX=disabled > /etc/selinux/config

grep 8.8.8.8 /etc/resolv.conf || echo nameserver 8.8.8.8 > /etc/resolv.conf

sync && echo 3 > /proc/sys/vm/drop_caches

cat > /etc/security/limits.conf << EOF
* hard nofile 100000
* soft nofile 100000
* hard nproc  100000
* hard npro   100000
EOF

