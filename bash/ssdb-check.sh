#!/bin/bash

function check()
{
    port=$1
    path=$2

    if ps auxgww | grep "[s]sdb-$port" -q; then
        echo "OK   $port"
    else
        echo "FAIL $port"
        pid="$(dirname "$path")/var/ssdb.pid"; rm -f "$pid"
        $path
    fi
}

check 6000 /data/databases/ssdb-6000-db1/start.sh
check 6200 /data/databases/ssdb-6001-db2/start.sh
