#!/usr/bin/env bash

ROOTDIR="$1"
WORKSPACE="$2"
SCHEME="$3"
CLEAN="${4:-""}"
if [[ -z "$ROOTDIR" ]]; then
    echo "usage: $(basename "$0") dir workspace scheme [--clean]"
    exit 1
fi
pushd "$ROOTDIR"
#-derivedDataPath ./build
XCODEBUILD="xcodebuild -workspace $WORKSPACE.xcworkspace -scheme $SCHEME -configuration Debug -sdk iphoneos"
if [[ "$CLEAN" == "--clean" ]]; then
    $XCODEBUILD clean 2>&1 | grep -v "Plug-ins"
fi

# shellcheck disable=2086
infer run --reactive \
 --infer-blacklist-path-regex "Pods/.*"\
 --infer-blacklist-path-regex "lib/.*"\
 --infer-blacklist-path-regex "Tests/.*"\
 --infer-blacklist-path-regex ".*\.framework/.*"\
 --infer-blacklist-path-regex "Vendor/*.*"\
 -- $XCODEBUILD build 2>&1 | grep -v "Plug-ins"
popd

inferTraceBugs --html
open "./infer-out/report.html/index.html"
