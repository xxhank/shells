#!/usr/bin/env bash

STYLE_BOLD=$(tput bold)
STYLE_UNDERLINE=$(tput sgr 0 1)
STYLE_END=$(tput sgr0)

COLOR_PURPLE=$(tput setaf 171)
COLOR_RED=$(tput setaf 1)
COLOR_GREEN=$(tput setaf 76)
COLOR_TAN=$(tput setaf 3)
COLOR_BLUE=$(tput setaf 38)

header()    { printf "${STYLE_BOLD}${COLOR_PURPLE}==========  %s  ==========${STYLE_END}\n" "$@"; }
arrow()     { printf "➜ \n" "$@";}
success()   { printf "${COLOR_GREEN}✔ %s${STYLE_END}\n" "$@"; }
error()     { printf "${COLOR_RED}✖ %s${STYLE_END}\n" "$@"; }
warning()   { printf "${COLOR_TAN}➜ %s${STYLE_END}\n" "$@"; }
underline() { printf "${STYLE_UNDERLINE}${STYLE_BOLD}%s${STYLE_END}\n" "$@"; }
bold()      { printf "${STYLE_BOLD}%s${STYLE_END}\n" "$@"; }
note()      { printf "${STYLE_UNDERLINE}${STYLE_BOLD}${COLOR_BLUE}Note:${STYLE_END}  ${COLOR_BLUE}%s${STYLE_END}\n" "$@"; }

function die() {
  local -r last_error=$?
  local stack_paths=""
  for ((i = ${#FUNCNAME[@]} - 1;i > 0;i--)); do
    if [[ -z "${stack_paths}" ]]; then
      stack_paths="${FUNCNAME[i]}"
    else
      stack_paths="${stack_paths}>${FUNCNAME[i]}"
    fi
  done
  error "${stack_paths}(${last_error}):$*" >&2
  clean_up ${last_error}
  exit ${last_error}
}

# 获取管道状态码
# if [[ ${PIPESTATUS[0]} != 0 ]]; then
#   die "build workspace failed"
# fi

IFS=$'\n\t'

trap '[[ -d "${temp_dir}" ]] && rm -r "${temp_dir}"' EXIT SIGHUP SIGINT SIGTERM SIGFPE

set -o errexit
set -o pipefail

readonly version="1.0.0"
readonly script_path="${BASH_SOURCE[0]}"
readonly script_dir="$( cd "$( dirname "${script_path}" )" && pwd )"
readonly script_name="${script_path##*/}"
readonly script_basename="${script_name%\.*}"

readonly temp_dir=$(mktemp -dt "${script_basename}")
readonly log_file="$HOME/Library/Logs/${script_basename}.log"

# Print usage
usage() {
  cat <<- EOF
  $(bold Usage:) ${script_basename} [OPTION] [--scheme|-s=SCHEME] [--publish|-p]
  编译当前工程,并生成ipa

  $(bold Options:)
  -d, --debug       Runs script in BASH debug mode (set -x)
  -h, --help        Display this help and exit

  $(bold Actions:)
  --scheme|-s: 要编译的scheme
  --publish|-p:编译成功后发布到fir
  $(bold Version:)
  ${version}
EOF
  exit "${1:-0}"
}

PUSH_TO_FIR=false
declare -a args=()
for i in "$@"; do
  #echo $i
  case $i in
    -d|--debug)     debug=true;   shift;;
    -h|--help)      usage 0 >&2;    shift;;

    -v=*|--value=*) value="${i#*=}"; shift;;
    -s=*|--scheme=*) SCHEME="${i#*=}"; shift;;
    --publish|-p) PUSH_TO_FIR=true; shift;;
    # --flag) flag=true;   shift;;
    --*=*|-*=*)
      key="${i%=*}"; key=${key//-/}; value="${i#*=}";
      warning "unused: $(bold "$key $value")"
      shift;;
    *)
    args=("${args[@]}" "$i") ;;
  esac
done

if [[ ${debug:false} == true ]]; then
  set -x
  export PS4='+$BASH_SOURCE:$LINENO:$FUNCNAME: '
  trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND?")' DEBUG
else
  set -o nounset
fi

trap 'clean_up' EXIT SIGHUP SIGINT SIGTERM SIGFPE

clean_up(){
  echo -n #add your clean up code here
}

xcodebuild_fix(){
  ## xcodebuild "$@" 2>&1  | grep -v "Xcode/Plug-ins"
  xcodebuild -showsdks 2>&1|grep -v "/Plug-ins"
}

main() {
  if [[ -z "${WORKSPACE:-}" ]]; then
    # 尝试搜索当前目录下的xcworkspace文件
    WORKSPACE="$(find . -name '*.xcworkspace' -depth 1)"
    if [[ -z "$WORKSPACE" ]]; then
      die "请指定xcworkspace"
    else
      echo "find: $WORKSPACE"
    fi
  fi

  if [[ -z "${SCHEME:-}" ]]; then
    # 尝试获取scheme
    SCHEME=$(xcodebuild -list 2>/dev/null | pcregrep -M -o -e "(?:Schemes:\n\s+)\w+" | pcregrep "(?:^\s+)\w+" | sed -E "s/[[:space:]]//g")

    if [[ -z "$SCHEME" ]]; then
       die "请指定scheme"
      else
        echo "find: $SCHEME"
    fi
  fi

  CONFIG="Debug"
  CODE_SIGN_IDENTITY=""
  PROVISIONING_PROFILE=""

  STAMP="$(date '+%y%M%d%H%m%S')"

  DerivedDataPath="$temp_dir/derive"
  ArchivePath="./archive/$STAMP"

  OUTNAME="$SCHEME"
  rm -rf "$DerivedDataPath"
  mkdir -p "$DerivedDataPath" "$ArchivePath"

  if [[ -n "$CODE_SIGN_IDENTITY" && -n "$PROVISIONING_PROFILE" ]]; then
    xcodebuild_fix \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -derivedDataPath "$DerivedDataPath" \
    -archivePath "$ArchivePath/$OUTNAME.xcarchive" \
    -destination 'generic/platform=iOS' \
    archive \
    DEBUG_INFORMATION_FORMAT="dwarf-with-dsym" \
    CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" \
    PROVISIONING_PROFILE="${PROVISIONING_PROFILE}" # 2>&1  | grep -v "Xcode/Plug-ins"
  else
    xcodebuild_fix \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration "$CONFIG" \
    -derivedDataPath "$DerivedDataPath" \
    -archivePath "$ArchivePath/$OUTNAME.xcarchive" \
    -destination 'generic/platform=iOS' \
    archive \
    DEBUG_INFORMATION_FORMAT="dwarf-with-dsym" # 2>&1  | grep -v "Xcode/Plug-ins"
    #ONLY_ACTIVE_ARCH="No" \
    #ARCHS="armv7 arm64" \
    #CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" \
    #PROVISIONING_PROFILE="${PROVISIONING_PROFILE}"
  fi

  EXPORT_OPTIONS=/tmp/exportPlist.plist
  cat > "$EXPORT_OPTIONS"  <<- EOM
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
    <dict>
      <key>method</key>
      <string>development</string>
    </dict>
  </plist>
EOM

  xcodebuild_fix -exportArchive \
    -archivePath "$ArchivePath/$OUTNAME.xcarchive" \
    -exportOptionsPlist "${EXPORT_OPTIONS}" \
    -exportPath "$ArchivePath"

  echo "ipa: $ArchivePath/$OUTNAME.ipa"

  if [[ "$PUSH_TO_FIR" == "true" ]]; then
       IPA_FILE=$(find "$ArchivePath" -name "*.ipa")
      if [[ -f "${IPA_FILE}" && -e "$HOME/.rbenv/shims/fir" ]]; then
        echo "publish to fir.im"
        "$HOME/.rbenv/shims/fir" publish --verbose \
        --token=95756caaa025ca7c4641e663f904f80e \
        "${IPA_FILE}" || die "publish failed"
      else
        die "${IPA_FILE} not exist"
      fi
  else
    open "$ArchivePath"
  fi
}

main "$@"