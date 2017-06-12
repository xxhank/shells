#!/usr/bin/env bash
#
# 初始化项目
#
#
set -o errexit
set -o pipefail
set -o nounset

readonly script_path="${BASH_SOURCE[0]}"
readonly script_dir="$( cd "$( dirname "${script_path}" )" && pwd )"

SOURCE="$script_dir/../codestyle/uncrustify.cfg"
TARGET="$script_dir/../uncrustify.cfg"

if [[ -e "$TARGET" ]]; then
    if [[ -L "$TARGET" ]]; then
        rm -rf "$TARGET"
        ln -s "$SOURCE" "$TARGET"
    else
        echo "$TARGET is not a symbol link"
    fi
else
    ln -s "$SOURCE" "$TARGET"
fi

TARGET="$HOME/uncrustify.cfg"
if [[ -e "$TARGET" ]]; then
    if [[ -L "$TARGET" ]]; then
        rm -rf "$TARGET"
        ln -s "$SOURCE" "$TARGET"
    else
        mv "$TARGET" "$TARGET.bak"
        ln -s "$SOURCE" "$TARGET"
        echo "$TARGET is not a symbol link"
    fi
else
    ln -s "$SOURCE" "$TARGET"
fi