#!/bin/bash

declare -A osInfo
osInfo[/etc/redhat-release]=yum
osInfo[/etc/arch-release]=pacman
osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/SuSE-release]=zypp
osInfo[/etc/debian_version]=apt-get

for f in ${!osInfo[@]}
do
	if [[ -f $f ]];then
		echo Package manager: ${osInfo[$f]}
	fi
done
