#!/usr/bin/env bash
#  script module-name
set -o errexit
set -o pipefail
set -o nounset

readonly script_path="${BASH_SOURCE[0]}"
readonly script_dir="$( cd "$( dirname "${script_path}" )" && pwd )"

ModuleName="$1"
ModuleRoot="$PWD/SARRS/Service"
if [[ ! -d "$ModuleRoot" ]]; then
    echo "$ModuleRoot not exist"
    exit 1
fi

mkdir -p "$ModuleRoot/$ModuleName"
pushd  "$ModuleRoot/$ModuleName"
mkdir -p "Interface"
mkdir -p "APIs"
mkdir -p "Model"
mkdir -p "Storage"

touch "Storage/README.md"
touch "APIs/README.md"
touch "Model/README.md"

function dump_to_file(){
    FILE="$1"
    if [[ -e "$FILE" ]]; then
        echo "$FILE" exist
        return
    fi
    shift
    echo "$1" > "$FILE"
}

# interface
COMPNENT="Interface"
FILE="$COMPNENT/${ModuleName}.h"
dump_to_file "$FILE" "$(cat <<-EOF
//
//  ${ModuleName}.h
//  SARRS
//
//  Created by $(whoami) on $(date +"%Y/%m/%d").
//  Copyright © 2017年 $(whoami). All rights reserved.
//

#import <Foundation/Foundation.h>

///  Notification定义
// extern NSNotificationName const ${ModuleName}Notification
// extern NSNotificationName const ${ModuleName}Notification
// extern NSNotificationName const ${ModuleName}Notification

@interface ${ModuleName} : NSObject
+ (instancetype)shared;
@end
EOF)"


FILE="$COMPNENT/${ModuleName}.m"
dump_to_file "$FILE" "$(cat <<-EOF
//
//  ${ModuleName}.m
//  SARRS
//
//  Created by $(whoami) on $(date +"%Y/%m/%d").
//  Copyright © 2017年 $(whoami). All rights reserved.
//
#import "${ModuleName}.h"

///  Notification定义
//  NSNotificationName const ${ModuleName}Notification = @"";
//  NSNotificationName const ${ModuleName}Notification = @"";
//  NSNotificationName const ${ModuleName}Notification = @"";

@interface ${ModuleName} ()

@end

@implementation ${ModuleName}
 + (instancetype)shared
{
    Class exceptClass = [${ModuleName} class];

    if ([[[self class] superclass] isSubclassOfClass:exceptClass])
    {
        @throw [NSException exceptionWithName:@"call singleton from unexcept class"
                                       reason:@"不要在子类上调用该单例方法"
                                     userInfo:@{@"except class":NSStringFromClass(exceptClass)
                                                , @"actual class":NSStringFromClass([self class])}];
    }

    static ${ModuleName}             * instance;
    static dispatch_once_t          onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[[exceptClass class] alloc] init];
    });

    return instance;
}
@end
EOF)"

popd