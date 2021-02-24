#!/bin/bash

cd "$(dirname "$0")"
set -x

# shutdown vpn
nmcli con down purevpn

# clear existing rules
sudo iptables -F
sudo iptables -P OUTPUT ACCEPT

# restore dns
sudo cp dns/offline.conf /etc/resolv.conf
