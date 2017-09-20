#!/usr/bin/env bash

ROOTDIR="$1"
WORKSPACE="$2"
SCHEME="$3"

echo "dir: $ROOTDIR"
echo "workspace: $WORKSPACE"
echo "scheme: $SCHEME"

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
        ANALYZE=YES
        FIXHTML=YES
        shift
        ;;

    *)
        # unknown option
        ;;
esac
done

if [[ "$CLEAN" == "YES" ]]; then
    echo "will clean ..."
fi

if [[ "$BUILD" == "YES" ]]; then
    echo "will build ..."
fi

if [[ "$ANALYZE" == "YES" ]]; then
    echo "will analyze ..."
fi

if [[ "$FIXHTML" == "YES" ]]; then
    echo "will beautify html ..."
fi

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

    #     -enable-global-analysis
    "$script_dir/oclint/bin/oclint-json-compilation-database" \
    -v -e sharepods -e Pods -e lib  -e Vendor --  \
    -report-type=html -o=lint.html\
    -disable-rule=BitwiseOperatorInConditional  \
    -disable-rule=ConstantIfExpression\
    -disable-rule=UnusedMethodParameter\
    -disable-rule=RedundantIfStatement\
    -disable-rule=UselessParentheses\
    -disable-rule=TooManyParameters\
    -disable-rule=UnnecessaryElseStatement\
    -max-priority-1=999999 \
    -max-priority-2=999999 \
    -max-priority-3=999999 \
    -rc CYCLOMATIC_COMPLEXITY=15 \
    -rc NPATH_COMPLEXITY=300 \
    -rc LONG_LINE=200 \
    -rc LONG_METHOD=400 \
    -rc LONG_VARIABLE_NAME=40 \
    -rc NCSS_METHOD=200
fi

if [[ $FIXHTML == "YES" ]]; then
    if [[ -e ./lint.html ]]; then
        echo "fix html...."
        #sourceText='<\/style><\/head>'
        #targetText='<\/style><script src=\"jquery-3.2.1.min.js\" type="text\/javascript"><\/script><script src=\"lint-fix.js\" type=\"text\/javascript\"><\/script><\/head>'
        #sed -i .bak -E "s/$sourceText/$targetText/" ./lint.html

        "$script_dir/run-oclint-fix-html.sh" --source=./lint.html --target=./lint.html
    else
        echo "Cannot find lint.html"
    fi
fi