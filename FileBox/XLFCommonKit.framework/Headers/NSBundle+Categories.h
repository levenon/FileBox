//
//  NSBundle+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-10-27.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle(Categories)

/**
 *  获取应用名称
 *  @return 应用名称
 */

+ (NSString *)bundleDisplayName;

/**
 *  获取应用标识号
 *  @return 标识号
 */

+ (NSString *)bundleIdentifier;

/**
 *  获取应用版本
 *  @return 版本号
 */

+ (NSString *)appVersion;

/**
 *  获取Bundle版本
 *  @return 版本号
 */

+ (NSString *)bundleVersion;
@end
