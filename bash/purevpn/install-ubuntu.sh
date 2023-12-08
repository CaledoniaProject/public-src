#!/bin/bash

set -x

add-apt-repository -y ppa:eivnaes/network-manager-sstp
apt update
apt install -y sstp-client ppp

chmod -x /etc/ppp/ip-up.d/000resolvconf /etc/ppp/ip-up.d/0000usepeerdns
cat > /etc/ppp/ip-up.d/999-googledns << EOF
#!/bin/bash

echo nameserver 8.8.8.8 >  /etc/resolv.conf
echo nameserver 8.8.4.4 >> /etc/resolv.conf
EOF

cat > /etc/ppp/ip-up.d/888-sockd << EOF
#!/bin/bash
exit 0

EOF

chmod +x /etc/ppp/ip-up.d/999-googledns /etc/ppp/ip-up.d/888-sockd
