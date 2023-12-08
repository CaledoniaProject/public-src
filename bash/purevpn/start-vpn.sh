#!/bin/bash

cd "$(dirname "$0")"

trap "set -; echo -ne '\nCleaning up ..\n'; exit" SIGINT

gateway=$1
if [[ -z "$gateway" ]]; then
    echo $0 opt-cn1
    exit
fi
set -x

sudo nmcli con modify purevpn vpn.data "refuse-pap = yes, gateway = ${gateway}.ptoserver.com, refuse-chap = yes, refuse-eap = yes, require-mppe-128 = yes, user = YOUR_VPN_ACCOUNT, password-flags = 1, ignore-cert-warn = yes"

if nmcli con show --active | grep purevpn; then
    nmcli con down purevpn
fi

while true
do
    if nmcli con up purevpn; then
        sudo cp dns/online.conf /etc/resolv.conf 
        sudo systemctl stop sockd
        sudo systemctl start sockd
        break
    else
        sudo cp dns/offline.conf /etc/resolv.conf 
        sleep 1
    fi
done
