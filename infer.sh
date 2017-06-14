#!/usr/bin/env bash

ROOTDIR="$1"
CLEAN="${2:-""}"
WORKSPACE="Le123PhoneClient"
SCHEME="sdsp"
pushd "$ROOTDIR"

#-derivedDataPath ./build
XCODEBUILD="xcodebuild -workspace $WORKSPACE.xcworkspace -scheme $SCHEME -configuration Debug -sdk iphoneos"
if [[ "$CLEAN" == "--clean" ]]; then
    $XCODEBUILD clean 2>&1 | grep -v "Plug-ins"
fi

# shellcheck disable=
infer run --reactive \
 --infer-blacklist-path-regex "Pods/.*"\
 --infer-blacklist-path-regex "lib/.*"\
 --infer-blacklist-path-regex "Tests/.*"\
 --infer-blacklist-path-regex ".*\.framework/.*"\
 -- $XCODEBUILD build 2>&1 | grep -v "Plug-ins"
popd

inferTraceBugs --html
open "./infer-out/report.html/index.html"
