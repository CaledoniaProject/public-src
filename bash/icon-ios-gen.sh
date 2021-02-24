#!/usr/local/homebrew/mybin/bash

function go()
{
    file=$1
    name=$(basename "$file")
    name=${name%%.*}

    echo "-> ${name}@2x.png"
    convert -resize 120x120 "$file" "${name}@2x.png"
    
    echo "-> ${name}@3x.png"
    convert -resize 180x180 "$file" "${name}@3x.png"
}

for x in "$@"
do
    echo converting $x
    go $x
done
