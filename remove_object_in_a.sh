#!/usr/bin/env bash
if [[ $# -lt 1 ]]; then
    echo "usage:$(FrameworkFile "$0") framework-file|lib-file object1 object2 object3 ..."
    exit 1
fi

FrameworkPath="$1"; shift;
Objects="$*"

if [[ -f "$FrameworkPath" ]]; then
    echo -n
else
    echo "\"$FrameworkPath\" does not exist"
    exit 1
fi

FrameworkFile="$(FrameworkFile "$FrameworkPath")"
FrameworkName="${FrameworkFile%%.*}" # 移除扩展名
echo "FrameworkName: $FrameworkName"

# lipo -info返回如下结果
# Architectures in the fat FrameworkPath: LeTVMobilePlayer are: armv7 i386 x86_64 arm64
archs=$(lipo -info "$FrameworkPath" | sed -E "s/.*are: //")
echo "archs: $archs"

readonly TEMP_DIR=$(mktemp -dt "${script_FrameworkFile}")
mkdir -p "${TEMP_DIR}/$FrameworkName"
for arch in $archs; do
     #echo "word:$arch"
     lipo -thin "$arch" "$FrameworkPath" -output "${TEMP_DIR}/$FrameworkName/$arch"
     if [[ -z "$Objects" ]]; then
        echo "Contents:"
        ar -t "${TEMP_DIR}/$FrameworkName/$arch"
     else
        echo "Delete: ar -dv "${TEMP_DIR}/$FrameworkName/$arch" $Objects"
        ar -dv "${TEMP_DIR}/$FrameworkName/$arch" $Objects
     fi
done

#cd "${TEMP_DIR}FrameworkName" || exit 1
libs=""
for arch in $archs; do
    libs="$libs ${TEMP_DIR}/$FrameworkName/$arch"
done
#echo "$libs"
lipo -create $libs -output "${TEMP_DIR}/$FrameworkName/$FrameworkFile" &&  open "${TEMP_DIR}/$FrameworkName"