#!/bin/bash

cd "$(dirname "$0")"
set -ex -o pipefail

function build_ysoserial()
{
	base=$(pwd)
	dest=$(mktemp -d)
	cd "$dest"

	trap "echo; echo Clean up; rm -rf $dest; exit" INT ERR

    curl -L https://github.com/frohoff/ysoserial/archive/master.zip -o master.zip
	unzip -qq master.zip

	cd ysoserial-master

	# 删除 class 特征
	sed 's/ysoserial.Pwner/Hello.World/' -i ./src/main/java/ysoserial/payloads/util/Gadgets.java
	mvn package -Dmaven.test.skip=true

	mkdir -p /root/bin
	install -m755 target/ysoserial-*-all.jar /root/bin/ysoserial.jar

	cd / && rm -rf "$dest"
}

build_ysoserial
