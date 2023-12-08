#!/bin/bash

cd "$(dirname "$0")"
set -ex -o pipefail

function build_apktool()
{
	base=$(pwd)
	dest=$(mktemp -d)
	cd "$dest"

	trap "echo; echo Clean up; rm -rf $dest; exit" INT ERR

    curl -L https://github.com/iBotPeaches/Apktool/archive/master.zip -o master.zip
	unzip -qq master.zip

	cd Apktool-master
	./gradlew build shadowJar -x test

	mkdir -p /root/bin
	install -m755 ./brut.apktool/apktool-cli/build/libs/apktool-cli-all.jar /root/bin/apktool.jar

	cd / && rm -rf "$dest"
}

build_apktool
