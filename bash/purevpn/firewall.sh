#!/bin/bash

if [[ $(id -u) != 0 ]]; then
    exec sudo $0 "$@"
    exit
fi

cd "$(dirname "$0")"

# clear existing rules
iptables -F
iptables -P OUTPUT ACCEPT
ipset destroy vpn_out

ipset -N vpn_out iphash
# googledns
ipset -A vpn_out 8.8.8.8
ipset -A vpn_out 8.8.4.4
ipset -A vpn_out 4.2.2.2
# opendns
ipset -A vpn_out 208.67.222.222
ipset -A vpn_out 208.67.220.220
# 114 dns
ipset -A vpn_out 114.114.114.114
# verisign dns
ipset -A vpn_out 64.6.64.6
ipset -A vpn_out 64.6.65.6

# purevpn
cat purevpn/iplist | while read x
do
    ipset -A vpn_out $x
done

iptables -P OUTPUT DROP
iptables -I OUTPUT -o eth0 -m set --match-set vpn_out dst -j ACCEPT
iptables -I OUTPUT -o eth0 -d 192.168.154.1 -j ACCEPT
iptables -I OUTPUT -o ppp+ -j ACCEPT
iptables -I OUTPUT -o tun+ -j ACCEPT
iptables -I OUTPUT -o lo+ -j ACCEPT
