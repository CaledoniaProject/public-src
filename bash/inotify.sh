#!/bin/bash

DIR="$PWD/user1"

inotifywait -m --format "%e %f" "$DIR" | awk '$1 ~ "CREATE" { print $2; fflush() }' | 
while read file
do
	FILE="${DIR}"/"${file}"
	echo "${FILE} is created !"
done
