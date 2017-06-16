#!/usr/bin/env bash

ROOTDIR="$1"
CLEAN="${2:-""}"
WORKSPACE="Le123PhoneClient"
SCHEME="sdsp"
pushd "$ROOTDIR"

XCODEBUILD="xcodebuild -workspace $WORKSPACE.xcworkspace -scheme $SCHEME -configuration Debug -sdk iphoneos"
if [[ "$CLEAN" == "--clean" ]]; then
    $XCODEBUILD clean 2>&1 | grep -v "Plug-ins"
fi

# shellcheck disable=
$XCODEBUILD build 2>&1 | xcpretty -r json-compilation-database | grep -v "Plug-ins"
popd

./shells/oclint/bin/oclint-json-compilation-database ./compile_commands.json
#inferTraceBugs --html
#open "./infer-out/report.html/index.html"
