#!/usr/bin/env bash
if [[ $# -lt 1 ]]; then
    echo "usage:$(basename "$0") lib object"
    exit 1
fi

File="$1"; shift;
Objects="$*"

if [[ -f "$File" ]]; then
    echo -n
else
    echo "file:\"$File\" does not exist"
    exit 1
fi

FileName="${File/.a/}"
echo "$FileName"
archs=$(lipo -info "$File" | sed -E "s/.*are: //")
echo "$archs"

mkdir -p "./$FileName"
for arch in $archs; do
     #echo "word:$arch"
     lipo -thin "$arch" "$File" -output "./$FileName/$arch"
     if [[ -z "$Objects" ]]; then
        echo "Contents:"
        ar -t "./$FileName/$arch"
     else
        echo "Delete:"
        ar -dv "./$FileName/$arch" $Objects
     fi

done

#cd "./$FileName" || exit 1
libs=""
for arch in $archs; do
    libs="$libs $PWD/$FileName/$arch"
done
#echo "$libs"
lipo -create $libs -output "$PWD/$FileName/$File"