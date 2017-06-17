#!/usr/bin/env bash

ROOTDIR="$1";shift;

WORKSPACE="Le123PhoneClient"
SCHEME="sdsp"

for i in "$@"
do
case $i in
    --analyze)
    ANALYZE=YES
    FIXHTML=YES
    shift
    ;;

    --clean)
    CLEAN=YES
    shift
    ;;

    --fix-html)
    FIXHTML=YES
    shift
    ;;

    --build)
    BUILD=YES
    FIXHTML=YES
    ANALYZE=YES
    shift
    ;;
    *)
    # unknown option
    ;;
esac
done


XCODEBUILD="xcodebuild -workspace $WORKSPACE.xcworkspace -scheme $SCHEME -configuration Debug -sdk iphoneos"

pushd "$ROOTDIR"
if [[ "$CLEAN" == "YES" ]]; then
    echo "blean..."
    $XCODEBUILD clean 2>&1 | grep -v "Plug-ins"
fi

if [[ "$BUILD" == "YES" ]]; then
    echo "build...."
    # shellcheck disable=
    $XCODEBUILD build 2>&1 | xcpretty -r json-compilation-database | grep -v "Plug-ins"
    mv -f ./build/reports/compilation_db.json ./compile_commands.json
fi
popd

if [[ "$ANALYZE" == "YES" ]]; then
    echo "analyze...."
    ./shells/oclint/bin/oclint-json-compilation-database -e sharepods -e Pods -e lib -- -o=lint.html -report-type=html
fi

if [[ $FIXHTML == "YES" ]]; then
    if [[ -e ./lint.html ]]; then
        echo "fix html...."
        sourceText='<\/style><\/head>'
        targetText='<\/style><script src=\"jquery-3.2.1.min.js\" type="text\/javascript"><\/script><script src=\"lint-fix.js\" type=\"text\/javascript\"><\/script><\/head>'
        sed -i .bak -E "s/$sourceText/$targetText/" ./lint.html
    fi
fi