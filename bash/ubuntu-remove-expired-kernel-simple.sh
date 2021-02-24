#!/bin/bash

packages=$(dpkg -l | awk '/linux-(headers|images|modules|modules-extra)-[0-9]/ {print $2}' | grep -v $(uname -r | sed 's/-generic//'))

if [[ -z "$packages" ]]; then
	echo Nothing to uninstall
	exit
fi

echo Kernel version
uname -r

echo Going to remove the following packages
echo $packages

apt --purge --no-install-recommends autoremove $packages
