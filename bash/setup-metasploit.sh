#!/bin/bash
# 自动安装 metasploit，只支持 Ubuntu 16.04

set -ex
dest=/root/metasploit/

echo '[-] Installing packages'
apt install -y ruby2.3 ruby2.3-dev libpcap-dev libsqlite3-dev postgresql-server-dev-all postgresql-9.5

echo '[-] Installing databases'
cat > /tmp/msf.sql << EOF
drop database if exists msf3;
drop user if exists msf3;

create user msf3 with password 'msf3';
create database msf3;
grant all privileges on database msf3 to msf3;
alter role msf3 with login;
EOF
su - postgres -c "psql < /tmp/msf.sql"

echo '[-] Configuring GEM sources'
gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
gem install bundle
bundle config mirror.https://rubygems.org https://gems.ruby-china.com

echo '[-] Downloading metasploit'
git clone https://github.com/rapid7/metasploit-framework.git "$dest"

echo '[-] Installing required GEMs'
cd "$dest"
gem install bundler
bundle install

echo '[-] Configuring metasploit'
mkdir -p ~/.msf4/
echo 'db_connect msf3:msf3@127.0.0.1/msf3' > ~/.msf4/msfconsole.rc

echo '[-] Installation completed, start with msfconsole now'

