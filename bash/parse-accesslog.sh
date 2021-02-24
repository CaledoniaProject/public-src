#!/bin/bash
# 解析access.log的例子

# Sample:
# 1.2.3.4 2013-09-10 22:10:11 www.com "GET / HTTP/1.1" 0.296
# 1.2.3.4 2013-09-10 22:10:21 www.com "GET / HTTP/1.1" 0.294

reg='^[^ ]+ ([^ ]+ [^ ]+) [^ ]+ "[^"]+" ([0-9.]+)$'
declare -A hash
declare -A count

while read line
do
    if [[ $line =~ $reg ]];then
        started=${BASH_REMATCH[1]}
        length=${BASH_REMATCH[2]}

        minute=$(date --date="$started" +"%Y-%m-%d_%H:%M")
        if [[ -z ${hash[$minute]} ]]; then
            hash[$minute]=$length
            count[$minute]=1
        else
            hash[$minute]="${hash[$minute]} + $length"
            count[$minute]=$(( ${count[$minute]} + 1 ))
        fi
    fi

done

for i in ${!hash[@]}; do
    echo $i $(echo "scale=3; ( ${hash[$i]} )" / ${count[$i]} | bc)
done
