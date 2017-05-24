#!/usr/bin/env bash
set -o nounset
#set -o errexit
#set -o pipefail

export LANG=en_US.UTF-8

function die(){
    echo "$*"
    exit 1
}

export POD='/usr/local/bin/pod'
export XCODEBUILD='/usr/bin/xcodebuild'
export XCPRETTY="$HOME/.rbenv/shims/xcpretty"

SOURCE_DIR="."
CONFIGURATION=$Configuration
PLATEFORM=$TARGET
DISTRIBUTION="DEV"
script_dir=$WORKSPACE/${SOURCE_DIR}
PROJECT_NAME="Le123PhoneClient"
CLEAN=$Clean

CODE_SIGN_IDENTITY="iPhone Developer: shuangying wang (782627JM2T)"
PROVISIONING_PROFILE="5ea64830-f420-4621-9596-df530ffbe5f8" #SARRS All Application

# 拉取子模块
git submodule update --init

if [[ -z "$CONFIGURATION" ]]; then
  CONFIGURATION="Release"
fi

if [[ $CONFIGURATION == "Release" ]]; then
  CODE_SIGN_IDENTITY="iPhone Distribution: Beijing tiancheng technology co., LTD (L65SY27KXF)"
  PROVISIONING_PROFILE="652ed74c-4d3b-4d80-a4fc-bf9f8385656f" #SARRS ADHOC
fi

DERIVED_PATH=$WORKSPACE/build
OUTPUT_PATH=$WORKSPACE/builds/${BUILD_NUMBER}
OUTPUT_SUFFIX=${BUILD_NUMBER} #$(date +"%Y%m%d-%H%M%S")-
OUTPUT_NAME=${TARGET}-${OUTPUT_SUFFIX}-${CONFIGURATION}

echo "${BUILD_NUMBER}" > "$WORKSPACE/BUILD_NUMBER"

EXPORT_OPTIONS="${script_dir}/export-options/development.plist"
mkdir -p "${OUTPUT_PATH}"
if [[ -d "${OUTPUT_PATH}" ]]; then
  if [[ ${BuildFramework:-false} == "true" ]]; then
    "${script_dir}/FrameworkBuilder/build_framework" --clean --pod=install
  fi

  rm -rf Podfile.lock
  rm -rf -- *.xcworkspace
  $POD update --no-repo-update
  if [[ $? != 0 ]]; then
    echo "pod update failed"
  fi

  # 移除编译时间统计
  # sed -i "" -E 's/-Xfrontend -debug-time-function-bodies//' "${script_dir}/SARRS.xcodeproj/project.pbxproj"
  # sed -i "" -E 's/-Xfrontend -debug-time-function-bodies//' "${script_dir}/Pods/Pods.xcodeproj/project.pbxproj"

  if [[ $CLEAN == "true" ]]; then
    echo "clean derived data"
    rm -rf "${DERIVED_PATH}"
  fi

  #INFO_PLIST="${script_dir}/${PROJECT_NAME}/Info.plist"
  # update build number
  #if [[ $BUILD_NUMBER != "" ]]; then
  #  /usr/libexec/PlistBuddy -c "Set CFBundleVersion ${BUILD_NUMBER}" "${INFO_PLIST}" # -c "Print"
  #fi

  #BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${INFO_PLIST}")
  #BUNDLE_IDENTIFIER=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "${INFO_PLIST}")

  if [[ $DISTRIBUTION == "DEV" ]]; then
      EXPORT_OPTIONS="${script_dir}/export-options/development.plist"
  elif [[ $DISTRIBUTION == "ADHOC" ]]; then
      EXPORT_OPTIONS="${script_dir}/export-options/ad-hoc.plist"
  else
      echo -n #BUNDLE_IDENTIFIER=$(grep PRODUCT_BUNDLE_IDENTIFIER -- *.xcodeproj/project.pbxproj | head -n 1 | awk -F " = |;" '{print $2}')
  fi
fi

if [[ -e "$XCPRETTY" ]] ; then
    FORMATTER=$XCPRETTY
else
    FORMATTER="tee /dev/null"
fi

ARCHIVE_FILE=${OUTPUT_NAME}.xcarchive
IPA_FILE=${OUTPUT_NAME}.ipa

if [[ -d "${OUTPUT_PATH}" ]]; then
  cat <<-EOM
  xcodebuild archive \
  -workspace "${PROJECT_NAME}.xcworkspace" \
  -scheme ${TARGET} \
  -archivePath "${OUTPUT_PATH}/${ARCHIVE_FILE}" \
  -configuration ${CONFIGURATION}  \
  -derivedDataPath "${DERIVED_PATH}" \
  DEBUG_INFORMATION_FORMAT="dwarf-with-dsym" \
  ONLY_ACTIVE_ARCH="No" \
  ARCHS="armv7 arm64"
EOM
  # archive
  xcodebuild archive \
  -workspace "${PROJECT_NAME}.xcworkspace" \
  -scheme ${TARGET} \
  -archivePath "${OUTPUT_PATH}/${ARCHIVE_FILE}" \
  -configuration ${CONFIGURATION}  \
  -derivedDataPath "${DERIVED_PATH}" \
  DEBUG_INFORMATION_FORMAT="dwarf-with-dsym" \
  ONLY_ACTIVE_ARCH="No" \
  ARCHS="armv7 arm64" \
  | tee ./archive.log.txt | $FORMATTER

  # 获取管道状态码
  echo "PIPESTATUS ${PIPESTATUS[0]}"
  #if [[ ${PIPESTATUS[0]} != 0 ]]; then
  #  die "archive failed"
  #fi
fi

if [[ -e "${OUTPUT_PATH}/${ARCHIVE_FILE}" ]]; then
    echo "export ipa"
    xcodebuild -exportArchive \
    -archivePath "${OUTPUT_PATH}/${ARCHIVE_FILE}" \
    -exportOptionsPlist "${EXPORT_OPTIONS}" \
    -exportPath "${OUTPUT_PATH}" || die "export ipa failed"

    echo "zip archive"
    pushd "${OUTPUT_PATH}"
    zip -q -r "${ARCHIVE_FILE}.zip" "${ARCHIVE_FILE}" || die "zip failed"
    rm -rf "${ARCHIVE_FILE}"
    popd
else
  die "${OUTPUT_PATH}/${ARCHIVE_FILE} not exist"
fi

find "${OUTPUT_PATH}" -type f -name "*.ipa" -exec mv {} "${OUTPUT_PATH}/${IPA_FILE}" \;

if [[ -f "${OUTPUT_PATH}/${IPA_FILE}" ]]; then
  echo "publish to fir.im"
  "$HOME/.rbenv/shims/fir" publish --verbose \
  --token=95756caaa025ca7c4641e663f904f80e \
  "${OUTPUT_PATH}/${IPA_FILE}"  || die "publish failed"
else
  die "${OUTPUT_PATH}/${IPA_FILE} not exist"
fi

rm -rf "$WORKSPACE/builds/lastSuccessfulBuild"
ln -s "$WORKSPACE/builds/${BUILD_NUMBER}" "$WORKSPACE/builds/lastSuccessfulBuild"