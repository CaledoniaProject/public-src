#!/bin/bash

cd "$(dirname "$0")"
set -ex -o pipefail

function build_binnavi()
{
	base=$(pwd)
	dest=$(mktemp -d)
	cd "$dest"

	trap "echo; echo Clean up; rm -rf $dest; exit" INT ERR

    curl -L https://github.com/google/binnavi/archive/master.zip -o master.zip
	unzip -qq master.zip

	cd binnavi-master
    mvn dependency:copy-dependencies
	ant build-binnavi-fat-jar

	mkdir -p /root/bin
	install -m755 target/binnavi-all.jar /root/bin/binnavi.jar

	cd / && rm -rf "$dest"
}

build_binnavi
