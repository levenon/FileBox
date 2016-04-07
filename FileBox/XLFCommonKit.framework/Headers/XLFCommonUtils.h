//
//  XLFCommonUtils.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-10-11.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "XLFConstants.h"

#pragma mark 类型转换


@interface XLFCommonUtils : NSObject
/**
 *  打开HTTP连接
 *
 *  @param url 链接地址
 */
+(void)openURL:(NSString*)url;

/**
 *  拨打电话
 *
 *  @param phoneNumber 电话号码
 */
+(void)dialPhoneNumber:(NSString*)phoneNumber enableBack:(BOOL)enable;

/**
 *  拨打电话
 *
 *  @param phoneNumber 电话号码
 */
+(void)dialPhoneNumber:(NSString*)phoneNumber;

/**
 *  获取随机数
 *
 *  @param from 开始
 *  @param to   结束
 *
 *  @return 数字
 */
+(int)randomNumber:(int)from to:(int)to;


/**
 *  获取mac地址
 *
 *  @return mac地址
 */
+(NSString *)macAddress;

@end
