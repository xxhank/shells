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

FileBaseName="$(basename "$File")"
FileName="${FileBaseName/.a/}"
echo "FileName: $FileName"

archs=$(lipo -info "$File" | sed -E "s/.*are: //")
echo "archs: $archs"

readonly temp_dir=$(mktemp -dt "${script_basename}")
mkdir -p "${temp_dir}/$FileName"
for arch in $archs; do
     #echo "word:$arch"
     lipo -thin "$arch" "$File" -output "${temp_dir}/$FileName/$arch"
     if [[ -z "$Objects" ]]; then
        echo "Contents:"
        ar -t "${temp_dir}/$FileName/$arch"
     else
        echo "Delete: ar -dv "${temp_dir}/$FileName/$arch" $Objects"
        ar -dv "${temp_dir}/$FileName/$arch" $Objects
     fi
done

#cd "${temp_dir}FileName" || exit 1
libs=""
for arch in $archs; do
    libs="$libs ${temp_dir}/$FileName/$arch"
done
#echo "$libs"
lipo -create $libs -output "${temp_dir}/$FileName/$FileBaseName" &&  open "${temp_dir}/$FileName"