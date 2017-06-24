#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

readonly script_path="${BASH_SOURCE[0]}"
readonly script_dir="$( cd "$( dirname "${script_path}" )" && pwd )"

ModuleName="$1"
ModuleRoot="$PWD/SARRS/Modules"
if [[ ! -d "$ModuleRoot" ]]; then
    echo "$ModuleRoot not exist"
    exit 1
fi

mkdir -p "$ModuleRoot/$ModuleName"
pushd  "$ModuleRoot/$ModuleName"
mkdir -p "Interface"
mkdir -p "ViewController"
mkdir -p "View"
mkdir -p "APIs"
mkdir -p "ViewModel"
mkdir -p "Business"

touch "View/README.md"
touch "ViewModel/README.md"
touch "APIs/README.md"

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
FILE="$COMPNENT/${ModuleName}Module.h"
dump_to_file "$FILE" "$(cat <<-EOF
//
//  ${ModuleName}Module.h
//  SARRS
//
//  Created by $(whoami) on $(date +"%Y/%m/%d").
//  Copyright © 2017年 $(whoami). All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  管理程序的主界面
 */

/// 模块名称
extern NSString* const Module${ModuleName};

/// Notification定义
// extern NSNotificationName const ${ModuleName}Notification
// extern NSNotificationName const ${ModuleName}Notification
// extern NSNotificationName const ${ModuleName}Notification

/// Options Key的定义
// extern NSString* const ${ModuleName}OptionsKey;
// extern NSString* const ${ModuleName}OptionsKey;
// extern NSString* const ${ModuleName}OptionsKey;

/// 模块工厂方法
@interface ${ModuleName}Factory : NSObject
+ (UIViewController*)viewControllerWithOptions:(NSDictionary*)options;
@end
EOF)"


FILE="$COMPNENT/${ModuleName}Module.m"
dump_to_file "$FILE" "$(cat <<-EOF
//
//  ${ModuleName}Module.m
//  SARRS
//
//  Created by $(whoami) on $(date +"%Y/%m/%d").
//  Copyright © 2017年 $(whoami). All rights reserved.
//
#import "${ModuleName}Module.h"

/// 模块名称
NSString* const Module${ModuleName} = @"";

/// Options Key的定义
// NSString* const ${ModuleName}OptionsKey = @"";
// NSString* const ${ModuleName}OptionsKey = @"";
// NSString* const ${ModuleName}OptionsKey = @"";

/// 模块工厂方法
@implementation ${ModuleName}Factory
+ (UIViewController*)viewControllerWithOptions:(NSDictionary*)options {
    return nil;
}
@end
EOF)"

# ViewController
COMPNENT="ViewController"
FILE="$COMPNENT/${ModuleName}ViewController.h"
dump_to_file "$FILE" "$(cat <<-EOF
//
//  ${ModuleName}ViewController.h
//  SARRS
//
//  Created by $(whoami) on $(date +"%Y/%m/%d").
//  Copyright © 2017年 $(whoami). All rights reserved.
//

#import <UIKit/UIKit.h>

@class ${ModuleName}Business;

@interface ${ModuleName}ViewController : UIViewController
@property (nonatomic,strong) ${ModuleName}Business*business;
@end
EOF)"

FILE="$COMPNENT/${ModuleName}ViewController.m"
dump_to_file "$FILE" "$(cat <<-EOF
//
//  ${ModuleName}ViewController.m
//  SARRS
//
//  Created by $(whoami) on $(date +"%Y/%m/%d").
//  Copyright © 2017年 $(whoami). All rights reserved.
//
#import "${ModuleName}ViewController.h"
#import "${ModuleName}Business.h"

#pragma mark - Constant

@interface ${ModuleName}ViewController ()
@end

@implementation ${ModuleName}ViewController

#pragma mark - Object Cycle
- (instancetype)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc {
}

#pragma mark - Override
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 功能1

#pragma mark - 功能2

#pragma mark - Delegate & DataSource

#pragma mark - Helper
@end
EOF)"

# Business
COMPNENT="Business"
FILE="${COMPNENT}/${ModuleName}Business.h"
dump_to_file "$FILE" "$(cat <<-EOF
//
//  ${ModuleName}Business.h
//  SARRS
//
//  Created by $(whoami) on $(date +"%Y/%m/%d").
//  Copyright © 2017年 $(whoami). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ${ModuleName}Business : NSObject

@end
EOF)"

FILE="${COMPNENT}/${ModuleName}Business.m"
dump_to_file "$FILE" "$(cat <<-EOF
//
//  ${ModuleName}Business.m
//  SARRS
//
//  Created by $(whoami) on $(date +"%Y/%m/%d").
//  Copyright © 2017年 $(whoami). All rights reserved.
//
#import "${ModuleName}Business.h"

@implementation ${ModuleName}Business

@end
EOF)"

popd