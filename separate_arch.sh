#!/usr/bin/env bash
if [[ $# -lt 1 ]]; then
    echo "usage:$(basename "$0") framework-file|lib-file object1 object2 object3 ..."
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

FrameworkFile="$(basename "$FrameworkPath")"
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
done

#cd "${TEMP_DIR}FrameworkName" || exit 1
archs="armv7 arm64"
libs=""
for arch in $archs; do
    libs="$libs ${TEMP_DIR}/$FrameworkName/$arch"
done
#echo "$libs"
lipo -create $libs -output "${TEMP_DIR}/$FrameworkName/${FrameworkFile}_device" &&  open "${TEMP_DIR}/$FrameworkName"

archs="i386 x86_64"
libs=""
for arch in $archs; do
    libs="$libs ${TEMP_DIR}/$FrameworkName/$arch"
done
#echo "$libs"
lipo -create $libs -output "${TEMP_DIR}/$FrameworkName/${FrameworkFile}_simulator" &&  open "${TEMP_DIR}/$FrameworkName"