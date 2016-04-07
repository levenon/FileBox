//
//  XLFConfigManager.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-9-4.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define BUILD_ENVIRONMENT_TEST                      0
#define BUILD_ENVIRONMENT_PREPARE_PRODUCTION        1
#define BUILD_ENVIRONMENT_PRODUCTION                2

#pragma mark 配置文件路径
/**
 *  省市区数据库文件路径
 */
#define SANDBOX_DATABASE_PATH                               @"region"
/**
 *  颜色配置文件路径
 */
#define SANDBOX_COLOR_PATH                                  @"colors"
/**
 *  字体配置文件路径
 */
#define SANDBOX_FONT_PATH                                   @"fonts"
/**
 *  系统配置文件路径
 */
#define SANDBOX_CONFIG_PATH                                 @"config"
/**
 *  联系我们配置文件路径
 */
#define SANDBOX_CONTACTUS_PATH                              @"contactus"

/**
 *  取颜色
 *
 *  @param key
 *
 */
#define UIColorFromKey(key)                                 [[XLFConfigManager shareConfigManager] colorForKey:key]
/**
 *  取字体大小
 *
 *  @param key
 *
 */
#define UIFontFromKey(key)                                  [[XLFConfigManager shareConfigManager] fontForKey:key]

@interface XLFConfigManager : NSObject

+ (id)shareConfigManager;

//取色系
- (UIColor *)colorForKey:(NSString *)key;
//取字体大小
- (UIFont *)fontForKey:(NSString *)key;

//取内网服务器地址
- (NSString *)debugServerUrl;
//取准生产环境服务器地址
- (NSString *)prepareReleaseServerUrl;
//取生产环境服务器地址
- (NSString *)releaseServerUrl;
//取服务器地址
- (NSString *)serverUrl;

//取内网服务器图片地址
- (NSString *)debugImageUrl;
//取外网服务器图片地址
- (NSString *)releaseImageUrl;
//取服务器图片地址
- (NSString *)imageServerUrl;

- (NSString *)debugImageServerHost;
- (NSString *)releaseImageServerHost;
- (NSString *)imageServerHost;

//取内网聊天服务器主机
- (NSString *)debugServerHost;
//取外网聊天服务器主机
- (NSString *)releaseServerHost;
//取聊天服务器主机
- (NSString *)serverHost;

//取内网聊天服务器端口
- (NSString *)debugServerPort;
//取外网聊天服务器端口
- (NSString *)releaseServerPort;
//取聊天服务器端口
- (NSString *)serverPort;

//用户配置
- (NSDictionary *)customConfiguration;
//取应用id－－唯一标示应用
- (NSString *)identifier;
//取app版本
- (NSString *)appVersion;
//取版本
- (NSString *)appFileVersion;
//取联系我们信息
- (NSArray *)contactUsInfo;

@end
