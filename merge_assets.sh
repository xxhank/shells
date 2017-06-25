#!/usr/bin/env bash
#

set -o errexit
set -o pipefail
set -o nounset

readonly root_path="${SRCROOT}"

# readonly root_path="/Users/dhl/workspace/git/ysdq-ios"
readonly common_assets_path="SARRS/Resource/CommonUI.xcassets"
readonly des_path="SARRS/Targets/${1}/resource/${1}.xcassets/merged"
readonly src_path="SARRS/Targets/${1}/resource/${1}-custom.xcassets"

echo -e "src: $src_path\ndes: $des_path"

readonly common_path="$root_path/$common_assets_path"
readonly script_src_path="$root_path/$src_path"
readonly script_dest_path="$root_path/$des_path"


if [[ -e "$script_dest_path" ]]; then
	rm -rf "$script_dest_path"
fi

mkdir -p "$script_dest_path"
echo '{"info" : {"version" : 1,"author" : "xcode"}}' > "$script_dest_path/Contents.json"

#find "$script_dest_path" ! -name "Contents.json" -depth 1 -exec rm -rf "{}" \;

find $common_path -name "*.imageset" -exec cp -rf {} $script_dest_path \;
find $script_src_path -name "*.imageset" -exec cp -rf {} $script_dest_path \;

