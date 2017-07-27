#!/usr/bin/env bash

ROOTDIR="$1"
WORKSPACE="$2"
SCHEME="$3"

if [[  -z "$WORKSPACE" ||  $WORKSPACE  == "-*" || -z "$SCHEME" ||  $SCHEME  == -* ]]; then
    echo "$(basename "$0") folder workspace scheme --analyze|--clean|--fix-html|--build"
    exit 0
fi

readonly script_path="${BASH_SOURCE[0]}"
readonly script_dir="$( cd "$( dirname "${script_path}" )" && pwd )"


shift;shift;shift;
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
    if [[ ! -e ./compile_commands.json ]]; then
         echo "build...."
        # shellcheck disable=
        $XCODEBUILD build 2>&1 | xcpretty -r json-compilation-database | grep -v "Plug-ins"
        mv -f ./build/reports/compilation_db.json ./compile_commands.json
    fi
    echo "analyze...."
    "$script_dir/oclint/bin/oclint-json-compilation-database" -e sharepods -e Pods -e lib -- -o=lint.html -report-type=html
fi

if [[ $FIXHTML == "YES" ]]; then
    if [[ -e ./lint.html ]]; then
        echo "fix html...."
        sourceText='<\/style><\/head>'
        targetText='<\/style><script src=\"jquery-3.2.1.min.js\" type="text\/javascript"><\/script><script src=\"lint-fix.js\" type=\"text\/javascript\"><\/script><\/head>'
        sed -i .bak -E "s/$sourceText/$targetText/" ./lint.html
    fi
fi