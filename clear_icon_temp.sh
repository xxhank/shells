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
  error "${stack_paths}:$*(${last_error})" >&2
  clean_up ${last_error}
}

# 获取管道状态码
# if [[ ${PIPESTATUS[0]} != 0 ]]; then
#   died "build workspace failed"
# fi

IFS=$'\n\t'

trap '[[ -d "${temp_dir}" ]] && rm -r "${temp_dir}"' EXIT SIGHUP SIGINT SIGTERM SIGFPE

#set -o errexit
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
  $(bold Usage:) ${script_basename} [OPTION]... action
  a shell template

  $(bold Options:)
    -d, --debug       Runs script in BASH debug mode (set -x)
    -h, --help        Display this help and exit

  $(bold Actions:)
    switch branch [source-branch]
  $(bold Version:)
    ${version}
EOF
  exit "${1:-0}"
}

declare -a args=()
for i in "$@"; do
  #echo $i
  case $i in
      -d|--debug)     debug=true;   shift;;
      -h|--help)      usage 0 >&2;    shift;;

      -v=*|--value=*) value="${i#*=}"; shift;;
      --flag) flag=true;   shift;;
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

main() {
    $(find "$HOME/var/version_icon" -type d -depth 1 -exec rm -rf {} \;)
    ls -l "$HOME/var/version_icon"
}

main "$@"