#!/bin/bash

set -x
name=${1:-opt-cn1}

trap 'poff purevpn; exit; echo' INT

cat > /etc/ppp/chap-secrets << EOF
* purevpn YOUR_VPN_PASSWORD *
EOF

cat > /etc/ppp/peers/purevpn << EOF
remotename      purevpn
linkname        purevpn
ipparam         purevpn
pty             "sstpc --cert-warn --ipparam purevpn --nolaunchpppd --save-server-route $name.ptoserver.com"
name            YOUR_VPN_ACCOUNT
plugin          sstp-pppd-plugin.so
sstp-sock       /var/run/sstpc/sstpc-purevpn
usepeerdns
refuse-eap
defaultroute
replacedefaultroute
debug
file /etc/ppp/options

noauth
nodetach
EOF

poff purevpn

while true
do
	sleep 1
	pppd call purevpn
done

