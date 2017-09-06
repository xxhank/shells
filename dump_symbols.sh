#!/usr/bin/env bash
#
# 导出应用的的符号
#

set -o errexit
set -o pipefail
set -o nounset

if [[ $# -lt 1 ]]; then
    echo "usage:$(basename "$0") search-path"
    exit 1
fi

readonly script_path="${BASH_SOURCE[0]}"
readonly script_dir="$( cd "$( dirname "${script_path}" )" && pwd )"
readonly script_name="${script_path##*/}"
readonly script_basename="${script_name%\.*}"

SOURCE="$1"

if [[ -z $SOURCE ]]; then
    echo "Useage:$script_basename dir"
    exit -1;
fi

# find . \( -name "*.a" -or -name "*.framework" \)
unwrap(){
    if [[ "$1" == *.framework ]]; then
        name=$(basename "$1")
        name=${name/.framework/}
        #echo "$1/$name"
        nm -A -arch x86_64 "$1/$name"
    elif [[ "$1" == *.a ]]; then
        #echo -n
        nm -A -arch x86_64 "$1"
    else
        echo "unknown $1"
    fi
}

FILES="$(\
    find "${SOURCE}" \( -name "*.a" -or -name "*.framework" \) \
    )"
while read -r line;do
    unwrap "$line"
done <<< "$FILES"
