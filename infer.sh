#!/usr/bin/env bash

pushd "$1"

xcodebuild -workspace Le123PhoneClient.xcworkspace -scheme sdsp -configuration Debug -sdk iphonesimulator clean 2>&1 | grep -v "Plug-ins"
infer -- xcodebuild -workspace Le123PhoneClient.xcworkspace -scheme sdsp -configuration Debug -sdk iphonesimulator 2>&1 | grep -v "Plug-ins"
popd