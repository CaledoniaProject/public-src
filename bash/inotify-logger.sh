#!/bin/bash
# inotify 监控脚本

monitor=/var/lib/mysql/
whitelist='^/usr/libexec/mysqld$'

# report threshold
interval=60

lastrun=

report ()
{
    if [[ -z "$lastrun" ]]; then
        lastrun=$(date +%s)
    elif [[ $(( $(date +%s) - $lastrun )) -gt $interval ]]; then
        lastrun=$(date +%s)
    else
        return
    fi
        

    # Slow !!
    while read owner link symbol exec
    do
        exec=${exec%%\'}; exec=${exec##*\`};
        if ! [[ "$exec" =~ "$whitelist" ]]; then
            echo '>>> Unauthorized access to mysql database file <<<'
            echo Date: $(date +"%Y-%m-%d %H:%M")
            echo User: $owner
            echo Cmd:  $exec
            echo
        fi
    done < <(
    for x in /proc/[0-9]*/fd/*; do 
        filepath="$(readlink -e "$x")"
        if [[ "$filepath" =~ $monitor ]]; then
            stat -c "%U %N" "${x%%/fd*}/exe"
        fi
    done | sort -u
    )
}

inotifywait -m -e open "$monitor" | while read x
do
    report
done

